import XPC

public enum XPCLifeCycle {}

public extension XPCLifeCycle {

  static var connectionHandler: ((XPCConnection) -> Void)?

  @_alwaysEmitIntoClient
  static func main() {
    xpc_main { rawValue in
      let connection = XPCConnection(rawValue: rawValue)
      if let handler = Self.connectionHandler {
        handler(connection)
      } else {
        connection.cancel()
      }
    }
  }

  @_alwaysEmitIntoClient
  static func begin() {
    xpc_transaction_begin()
  }

  @_alwaysEmitIntoClient
  static func end() {
    xpc_transaction_end()
  }
}
