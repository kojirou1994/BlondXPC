import BlondXPC

public protocol XPCConnectionEventDelegate {
  func handle(event: XPCObject)
}

public extension XPCConnection {
  @_alwaysEmitIntoClient
  func set(delegate: XPCConnectionEventDelegate) {
    set(eventHandler: delegate.handle(event:))
  }
}

public struct XPCConnectionEventHandlerExample: XPCConnectionEventDelegate {
  public init() {}
  public func handle(event: XPCObject) {
    switch event.type {
    case .error:
      if event == .errorConnectionInvalid {

      } else if event == .errorTerminationImminent {

      }
    case .dictionary:
      print("received event:")
      print(event)
      let event = event.unsafeDictionary
      let remote = event.remoteConnection!

      if let reply = event.createReply() {
        reply["reply"] = "Hi from XPC!"
        remote.send(message: .init(reply))
      } else {
        // no reply context
      }
    default:
      fatalError("wrong type!")
    }
  }
}
