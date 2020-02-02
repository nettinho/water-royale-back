import { all, call, put, take, takeLatest, select } from 'redux-saga/effects'
import { eventChannel } from 'redux-saga'
import _ from 'lodash/fp'

import { 
  joinLobby,
  afterJoinLobby,
  newGameLobby,
  joinedGameLobby,
  updatedGameLobby,
  leftGameLobby,
  startingGame,
} from './routines'
import { push } from 'connected-react-router';

function createChannelListener(channel) {
  return eventChannel(emit => {

    channel.on('after_join_lobby', p => emit(afterJoinLobby(p)))
    channel.on('new_game_lobby', p => emit(newGameLobby(p)))
    channel.on('joined_game_lobby', p => emit(joinedGameLobby(p)))
    channel.on('updated_game_lobby', p => emit(updatedGameLobby(p)))
    channel.on('left_game_lobby', p => emit(leftGameLobby(p)))
    channel.on('starting_game', p => emit(startingGame(p)))
  
    return () => channel.leave()
  })
}

export function* lobbyChannelSaga({payload: {socket, username}}) {
    const channel = socket.channel("server:lobby", {username})
    const joinChannel = () => new Promise((resolve, reject) => {
      channel.join()
          .receive("ok", resolve)
          .receive("error", reject)
    })
    const channelListener = yield call(createChannelListener, channel)
    try{
      yield call(joinChannel)
      yield put(joinLobby.success({channel, channelListener}))
      yield put(push('/lobby'))
      while (true) {
        try {
          const action = yield take(channelListener)
          yield put(action)
        } catch(err) {
          console.error('channel error:', err)
          channelListener.close()
        }
      }
    } catch (error) {
      yield put(joinLobby.failure(error))
    }
}

export function* joinedGameSaga({payload: {game, player}}) {
  let {myUser} = yield select(_.pick(['myUser']));
  if( myUser.id != player.id ) return
  yield put(joinedGameLobby.success(game.id))
  yield put(push('/lobby/game/' + game.id))
}

export function* leftGameSaga({payload: {game, player}}) {
  let {myUser} = yield select(_.pick(['myUser']));
  if( myUser.id != player.id ) return
  yield put(leftGameLobby.success())
  yield put(push('/lobby'))
}

export function* leaveLobbySaga({payload: {game_id}}) {
  let {
    lobbyChannelListener,
    myGameLobby
  } = yield select(_.pick([
    'lobbyChannelListener',
    'myGameLobby'
  ]));
  if(game_id != myGameLobby) return
  lobbyChannelListener.close()
}

export default function* () {
  yield all([
    takeLatest(joinLobby.TRIGGER, lobbyChannelSaga),
    takeLatest(joinedGameLobby.TRIGGER, joinedGameSaga),
    takeLatest(leftGameLobby.TRIGGER, leftGameSaga),
    takeLatest(startingGame.TRIGGER, leaveLobbySaga),
  ])
}
