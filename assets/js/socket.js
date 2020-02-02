import {Socket} from "phoenix"

export default () => {
  const socket = new Socket("/socket")
  socket.connect()
  return socket
}
