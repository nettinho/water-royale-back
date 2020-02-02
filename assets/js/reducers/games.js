import _ from 'lodash/fp'
import {
  afterJoinLobby,
  newGameLobby,
  joinedGameLobby,
  updatedGameLobby,
  leftGameLobby,
  startingGame,
} from '../routines'

const updateGame = (games, {game}) => (games
  .map(g => game.id != g.id ? g : {...game})
  .filter(g => g.players.length > 0)
)

const games = (state = [], {type, payload}) => {
  switch(type){
    case afterJoinLobby.TRIGGER:
      return payload.games
    case newGameLobby.TRIGGER:
      return [...state, payload.game]
    case joinedGameLobby.TRIGGER:
    case updatedGameLobby.TRIGGER:
    case leftGameLobby.TRIGGER:
      return updateGame(state, payload)
    case startingGame.TRIGGER:
      return state.filter(g => g.id != payload.game_id)
    default:
      return state
  }
}

export { games }
