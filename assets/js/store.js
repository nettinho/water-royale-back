import { createStore, combineReducers, applyMiddleware } from 'redux'
import createSagaMiddleware from 'redux-saga'
import { composeWithDevTools } from 'redux-devtools-extension'
import { createBrowserHistory } from 'history'
import { connectRouter, routerMiddleware } from 'connected-react-router'

import * as reducers from './reducers'
import sagas from './sagas'

export const history = createBrowserHistory()
const combinedReducers = combineReducers({
  ...reducers,
  router: connectRouter(history)
})
const composeEnhancers = composeWithDevTools({})
const sagaMiddleware = createSagaMiddleware()

export const store = createStore(
    combinedReducers,
    composeEnhancers(applyMiddleware(
      sagaMiddleware,
      routerMiddleware(history)
    ))
)

sagaMiddleware.run(sagas)