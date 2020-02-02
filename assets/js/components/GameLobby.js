import React from 'react'
import _ from 'lodash/fp'
import {connect} from 'react-redux'
import { compose } from 'redux'
import { withRouter } from 'react-router-dom'

const GameLobby = ({
  myUser,
  games,
  lobbyChannel,
  match: {params: {id}},
}) => {
  const game = _.find({id})(games)
  if(!game) return null

  const userReady = _.flow([
    _.get('players'),
    _.find({id: myUser.id}),
    _.get('ready'),
  ])(game)
  const allReady = _.get('all_ready')(game)

  const onLeaveGame = () => lobbyChannel.push("leave_game", {id})
  const onReadyGame = () => lobbyChannel.push("ready_game", {id})
  const onStartGame = () => lobbyChannel.push("start_game", {id})

  return (<>
    <h2>Game lobby : {game.name}</h2>
    Players:
    <ul>
      {game.players.map(p => <li key={p.id}>{p.username} {p.ready && "(Ready!)"}</li>)}
    </ul>
    <button onClick={onLeaveGame}>Leave game</button>
    <button onClick={onReadyGame}>I'm {userReady && "not "}ready</button>
    <button 
      disabled={!allReady}
      onClick={onStartGame}>Start game</button>
</>)
}
const mapStateToProps = _.pick([
  'games',
  'lobbyChannel',
  'myUser'
])

export default compose(
  withRouter,
  connect(mapStateToProps)
)(GameLobby)
