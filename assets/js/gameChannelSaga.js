import { all, call, put, take, takeLatest, select } from 'redux-saga/effects'
import { eventChannel } from 'redux-saga'
import _ from 'lodash/fp'

import {
  startingGame,
  updatedGame,
  updatedCountdown,
  updatedPlayer
} from './routines'
import { push } from 'connected-react-router';

function createChannelListener(channel) {
  return eventChannel(emit => {

    channel.on('updated_game', p => emit(updatedGame(p)))
    channel.on('updated_countdown', p => emit(updatedCountdown(p)))
    channel.on('updated_player', p => emit(updatedPlayer(p)))

    return () => channel.leave()
  })
}

export function* gameChannelSaga({payload: {game_id}}) {

  let {
    myUser,
    myGameLobby,
    socket,
  } = yield select(_.pick([
    'myUser',
    'myGameLobby',
    'socket',
  ]));
  if(game_id != myGameLobby) return

  const channel = socket.channel('game:' + game_id, {id: myUser.id})
  const joinChannel = () => new Promise((resolve, reject) => {
    channel.join()
        .receive("ok", resolve)
        .receive("error", reject)
  })
  const channelListener = yield call(createChannelListener, channel)
  try{
    yield call(joinChannel)
    yield put(startingGame.success(channel))
    yield put(push('/game'))
    while (true) {
      try {
        const action = yield take(channelListener)
        yield put(action)
      } catch(err) {
        console.error('channel error:', err)
      }
    }
  } catch (error) {
    yield put(startingGame.failure(error))
  }
}


export default function* () {
  yield all([
    takeLatest(startingGame.TRIGGER, gameChannelSaga),
  ])
}
