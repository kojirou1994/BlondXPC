import BlondXPC
import Foundation

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
      let eventDictionary = event.unsafeDictionary
      let remote = eventDictionary.remoteConnection!

      if let replyDictionary = eventDictionary.createReply() {
        if let xpcrpc = eventDictionary["xpcrpc"]?.string {
          replyDictionary["id"] = eventDictionary["id"]
          NSLog("XPCRPC get request, version: \(xpcrpc), id: \(eventDictionary["id"]!.unsafeUInt64)")

          let response = handle(method: eventDictionary["method"]!.string!, body: eventDictionary["params"]!)

          let key = response.success ? "success" : "error"
          replyDictionary[key] = response.body

          remote.send(message: .init(replyDictionary))
        } else {
          // not xpcrpc request
          NSLog("It's not xpcrpc request!")
          assertionFailure("Use \(String(describing: BlondXPCRPCClient.self)) to send request!")
          remote.cancel()
        }
      } else {
        // no reply context
      }
    default:
      assertionFailure("wrong type!")
      return
    }
  }
}
