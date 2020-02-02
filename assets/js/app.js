import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import { ConnectedRouter } from 'connected-react-router'

import { store , history } from './store'

import AppRoutes from './AppRoutes'


const App = () => (
  <Provider store={store}>
      <ConnectedRouter history={history}> 
        <AppRoutes />
      </ConnectedRouter>
  </Provider>
)

var mountNode = document.getElementById('app')
ReactDOM.render(<App />, mountNode)
