import { all } from 'redux-saga/effects'
import lobbyChannelSaga from './lobbyChannelSaga'
import gameChannelSaga from './gameChannelSaga'

export default function* sagas() {
  yield all([
    lobbyChannelSaga(),
    gameChannelSaga(),
  ])
}
