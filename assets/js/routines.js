import { createRoutine } from 'redux-saga-routines'

export const joinLobby = createRoutine('JOIN_SERVER_LOBBY')

export const afterJoinLobby = createRoutine('AFTER_JOIN')
export const newGameLobby = createRoutine('NEW_GAME_LOBBY')
export const joinedGameLobby = createRoutine('JOINED_GAME_LOBBY')
export const updatedGameLobby = createRoutine('UPDATED_GAME_LOBBY')
export const leftGameLobby = createRoutine('LEFT_GAME_LOBBY')

export const startingGame = createRoutine('STARTING_GAME')
export const updatedGame = createRoutine('UPDATED_GAME')
export const updatedCountdown = createRoutine('UPDATED_COUNTDOWN')
export const updatedPlayer = createRoutine('UPDATED_PLAYER')