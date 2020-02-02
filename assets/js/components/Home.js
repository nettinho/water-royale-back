import React, {useState} from 'react'
import _ from 'lodash/fp'
import {connect} from 'react-redux'
import {bindActionCreators} from 'redux'

import { joinLobby } from '../routines'

const Home = ({
  socket,
  connecting,
  lobbyChannelError,
  joinLobby
}) => {
  const [username, setUsername] = useState("Username")
  const onClick = () => joinLobby({socket, username})
  return <>
      Username: 
      <input 
        value={username} 
        disabled={connecting}
        onChange={({target})=>setUsername(target.value)}
      />
      {!connecting
        ? <button onClick={onClick}>Connect</button>
        : <p>Connecting...</p>
      }
      
      {lobbyChannelError && "ERROR: " + lobbyChannelError}
  </>
}
const mapStateToProps = _.pick([
  'socket',
  'connecting',
  'lobbyChannelError'
]);
const mapDispatchToProps = dispatch => ({
  ...bindActionCreators({ joinLobby }, dispatch)
})

export default connect(mapStateToProps, mapDispatchToProps)(Home)
