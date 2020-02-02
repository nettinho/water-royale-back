import { takeLatest, call, put, race, take } from 'redux-saga/effects'
import { eventChannel } from 'redux-saga'
import {
  WS_NEW_EVENT,
  USER_LOGOUT,
  WS_CONNECT_FAIL,
  WS_CONNECT
} from '../actions/types'

export function * handelWsConnection () {
  try {

    // Iniciamos a conexão com o socket
    const websocket = new WebSocket('wss://echo.websocket.org')
    
    // Criamos o channel
    const eventChannel = yield call(getWsChannel, websocket)

    // Iniciamos uma corrida que só irá terminar 
    // Quando houver um dispatch da ação USER_LOGOUT
    const { cancel } = yield race({
      task: call(watchMessages, eventChannel),
      cancel: take(USER_LOGOUT)
    })
    
    
    // Se a ação cancel vencer a corrida podemos
    // chamar o método close do channel.
    // Ele irá executar o websocket.close() 
    // visto anteriormente.
    if (cancel) {
      eventChannel.close()
    }
    
  } catch (error) {
    yield put({ type: WS_CONNECT_FAIL })
  }
}

function getWsChannel(websocket) {
  // Devemos retornar o channel pois é 
  // nele que iremos buscar os eventos emitidos
  return eventChannel(emitter => {
    websocket.onmessage = event => {
      emit(event.data)
    }
    
    // O channel tem um método close
    // que executa esta função ao ser chamado
    return () => {
      websocket.close()
    }
  
  })
}

export function * watchMessages (eventChannel) {
  // Executamos indefinidamente
  while (true) {
    // Usamos o effect take para ler os eventos do channel
    const event = yield take(eventChannel)
    
    // Enviamos uma ação para nossa store do redux
    yield put({ type: WS_NEW_EVENT, payload: JSON.parse(event) })
  }
}


// Criamos um watch para fazer a conexão com o ws.
// Esse watch será executado quando houver um disptach da ação de tipo WS_CONNECT
export default [
  takeLatest(WS_CONNECT, handelWsConnection)
]


function initWebsocket() {
  return eventChannel(emitter => {
    ws = new WebSocket(wsUrl + '/client')
    ws.onopen = () => {
      console.log('opening...')
      ws.send('hello server')
    }
    ws.onerror = (error) => {
      console.log('WebSocket error ' + error)
      console.dir(error)
    }
    ws.onmessage = (e) => {
      let msg = null
      try {
        msg = JSON.parse(e.data)
      } catch(e) {
        console.error(`Error parsing : ${e.data}`)
      }
      if (msg) {
        const { payload: book } = msg
        const channel = msg.channel
        switch (channel) {
          case 'ADD_BOOK':
            return emitter({ type: ADD_BOOK, book })
          case 'REMOVE_BOOK':
            return emitter({ type: REMOVE_BOOK, book })
          default:
            // nothing to do
        }
      }
    }
    // unsubscribe function
    return () => {
      console.log('Socket off')
    }
  })
}
export default function* wsSagas() {
const channel = yield call(initWebsocket)
while (true) {
    const action = yield take(channel)
    yield put(action)
  }
}