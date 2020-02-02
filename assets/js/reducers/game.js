import _ from 'lodash/fp'
import {
  startingGame,
  updatedGame,
  updatedCountdown,
  updatedPlayer
} from '../routines'

const gameChannel = (state = null, {type, payload}) => {
  switch(type){
    case startingGame.SUCCESS:
      return payload
    default:
      return state
  }
}

const updatedPlayers = ({players}, player) => players.map(p => p.id != player.id ? p : {...player})
const game = (state = null, {type, payload}) => {
  switch(type){
    case updatedGame.TRIGGER:
      return payload
    case updatedPlayer.TRIGGER:
      return {...state, players: updatedPlayers(state, payload)}
    default:
      return state
  }
}

const countdown = (state = -1, {type, payload}) => {
  switch(type){
    case updatedCountdown.TRIGGER:
      return payload.count
    default:
      return state
  }
}

export { 
  gameChannel,
  game,
  countdown
}
