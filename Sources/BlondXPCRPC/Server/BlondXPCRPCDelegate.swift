import BlondXPC

public struct BlondXPCRPCResponse {
  let success: Bool
  let body: XPCObject
}

public extension BlondXPCRPCResponse {
  static func success(_ body: XPCObject) -> Self {
    .init(success: true, body: body)
  }
  static func error(_ body: XPCObject) -> Self {
    .init(success: false, body: body)
  }
}

public protocol BlondXPCRPCDelegate: XPCConnectionEventDelegate {
  func handle(method: String, body: XPCObject) -> BlondXPCRPCResponse
}

extension BlondXPCRPCDelegate {
  public func handle(event: XPCObject) {
    switch event.type {
    case .error:
      if event == .errorConnectionInvalid {

      } else if event == .errorTerminationImminent {

      }
    case .dictionary:
      print(event)
      let event = event.dictionary!
      let remote = event.remoteConnection()!

      if let reply = event.createReply() {
        reply["id"] = event["id"]

        let response = handle(method: event["method"]!.string!, body: event["params"]!)

        let key = response.success ? "success" : "error"
        reply[key] = response.body

        remote.send(message: .init(reply))
      } else {
        // no reply context
      }
    default:
      fatalError("wrong type!")
    }
  }
}
