import BlondXPC
import Dispatch

let server = XPCConnection(name: nil)
let messageFromClient = XPCObject(["name" : "Tom"])

server.set { obj in
  print(obj)
  switch obj.type {
  case .connection:
    let conn = obj.unsafeConnection
    conn.set { message in
      print("receive:", message)
      precondition(message == messageFromClient)
      if let reply = message.dictionary?.createReply() {
        reply["message"] = "reply from anonymous listener"
        message.dictionary?.remoteConnection?.send(message: .init(reply))
      }
    }
    conn.resume()
  default: fatalError("unsupported type")
  }
}

server.resume()

DispatchQueue(label: "client queue").async {
  let client = XPCConnection(endpoint: server.endpoint)
  client.set { event in
    fatalError("connection closesd")
  }
  client.resume()
  while true {
    client.send(message: messageFromClient) // no reply
    let reply = client.waitReply(fromMessage: messageFromClient)
    print("reply:", reply)
    sleep(1)
  }
}

dispatchMain()
