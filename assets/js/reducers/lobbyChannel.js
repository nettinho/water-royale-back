import buildSocket from '../socket'
import {
  joinLobby,
  afterJoinLobby,
  joinedGameLobby,
  leftGameLobby,
} from '../routines'

const socket = (state = null, {type}) => {
  if( type == '@@INIT'){
    return buildSocket()
  }
  return state
}

const connecting = (state = false, {type}) => {
  switch(type){
    case joinLobby.TRIGGER:
      return true
    case joinLobby.FAILURE:
      return false
    default:
      return state
  }
}

const lobbyChannel = (state = null, {type, payload}) => {
  switch(type){
    case joinLobby.SUCCESS:
      return payload.channel
    default:
      return state
  }
}

const lobbyChannelListener = (state = null, {type, payload}) => {
  switch(type){
    case joinLobby.SUCCESS:
      return payload.channelListener
    default:
      return state
  }
}

const lobbyChannelError = (state = null, {type, payload}) => {
  switch(type){
    case joinLobby.FAILURE:
      return payload.reason
    default:
      return state
  }
}

const myUser = (state = null, {type, payload}) => {
  switch(type){
    case afterJoinLobby.TRIGGER:
      return payload.player
    default:
      return state
  }
}

const myGameLobby = (state = null, {type, payload}) => {
  switch(type){
    case joinedGameLobby.SUCCESS:
      return payload
    case leftGameLobby.SUCCESS:
      return null
    default:
      return state
  }
}

export {
  socket,
  connecting,
  lobbyChannel,
  lobbyChannelListener,
  lobbyChannelError,
  myUser,
  myGameLobby,
}
