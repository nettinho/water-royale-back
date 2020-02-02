import React from 'react'
import _ from 'lodash/fp'
import {connect} from 'react-redux'
import {bindActionCreators} from 'redux'

import { joinLobby } from '../routines'

const ServerLobby = ({
  myUser,
  games,
  lobbyChannel
}) => {

  const onCreateGame = () => lobbyChannel.push('create_game')
  const onJoinGame = id => lobbyChannel.push("join_game", {id})
  return (<>
    <h2>Server lobby</h2>
    {myUser 
      ? <p>Connected as '{myUser.username}'</p>
      : <p>You are not connected</p>
    }
    Games:
    <ul>
        {games.map((g, idx) => <li key={idx}>
          <button onClick={()=>onJoinGame(g.id)}>Join game</button> 
          ({g.players.length} players) {g.name}
        </li>)}
    </ul>
    <button onClick={onCreateGame}>Create game</button>
</>)
}
const mapStateToProps = _.pick([
  'myUser',
  'games',
  'lobbyChannel'
])
const mapDispatchToProps = dispatch => ({
  ...bindActionCreators({ joinLobby }, dispatch)
})

export default connect(mapStateToProps, mapDispatchToProps)(ServerLobby)
