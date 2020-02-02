import React from 'react'
import _ from 'lodash/fp'
import {connect} from 'react-redux'

const GameSimulator = ({
  gameChannel,
  myUser,
  game,
  countdown
}) => {
  const myPlayer = _.flow([
    _.get('players'),
    _.find({id: myUser.id})
  ])(game) || {}
  const myTarget = _.flow([
    _.get('players'),
    _.find({id: myPlayer.target})
  ])(game)
  const otherPlayers = _.flow([
    _.get('players'),
    _.filter(p => p.id != myUser.id && p.id != myPlayer.target )
  ])(game)

  console.log("COUNTDOWN", countdown)

  const update_player = t => gameChannel.push("update", {transformation: "Ole", water_level: 100})
  const hitting_valve = t => gameChannel.push("hitting_valve", {type: t})
  const release_valve = t => gameChannel.push("release_valve", {type: t})

  return (<>
    {countdown > 0 && <h1>GAME WILL START IN {countdown}</h1>}
    {countdown == 0 && <>
      <h2>Game running!</h2>
      <h3>My player {myPlayer.username}</h3>
      <p>Transformation: {myPlayer.transformation}</p>
      <p>Water Level: {myPlayer.water_level}</p>
      <p>Water Rate: {myPlayer.water_rate}</p>

      {myTarget && <>
        <h3>My target  {myTarget.username}</h3>
      <p>Transformation: {myTarget.transformation}</p>
      <p>Water Level: {myTarget.water_level}</p>
        <p>Water Rate: {myTarget.water_rate}</p>
        </>
      }

      <table>
        <thead><tr>
          <th>Player</th>
          <th>Transformation</th>
          <th>Water Level</th>
          <th>Water Rate</th>
        </tr></thead>
        <tbody>
          {otherPlayers.map((p, idx)=><tr key={idx}>
            <td>{p.username}</td>
            <td>{p.transformation}</td>
            <td>{p.water_level}</td>
            <td>{p.water_rate}</td>
          </tr>)}
        </tbody>
      </table>

      <p>

        <button onClick={()=>update_player()}>Update</button>
        <button onClick={()=>hitting_valve(1)}>Hit valve</button>
        <button onClick={()=>release_valve(1)}>Release valve</button>
      </p>

    </>}
</>)
}
const mapStateToProps = _.pick([
  'gameChannel',
  'myUser',
  'game',
  'countdown',
])

export default connect(mapStateToProps)(GameSimulator)
