import React from 'react'
import _ from 'lodash/fp'
import { compose } from 'redux'
import { withRouter, Redirect, Route, Switch } from 'react-router-dom'
import { connect } from 'react-redux'

import Home from './components/Home'
import ServerLobby from './components/ServerLobby'
import GameLobby from './components/GameLobby'
import GameSimulator from './components/GameSimulator'

export const AppRoutes = ({
  myUser,
  connecting,
  location: {pathname},
}) => {
  if( !connecting && pathname != '/' && !myUser)
    return <Redirect push to="/" />
  return <>
    <h1>Water Royale!</h1>
    <Switch>
      <Route exact path="/" component={Home} />
      <Route exact path="/lobby" component={ServerLobby} />
      <Route exact path="/lobby/game/:id" component={GameLobby} />
      <Route exact path="/game" component={GameSimulator} />
    </Switch>
  </>
}

const mapStateToProps = _.pick([
  'myUser',
  'connecting'
]);
export default compose(
  withRouter,
  connect(mapStateToProps)
)(AppRoutes)
