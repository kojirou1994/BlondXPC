import XPC
import Dispatch

public struct XPCConnection: RawRepresentable {
  public init(rawValue: xpc_connection_t) {
    self.rawValue = rawValue
  }

  public let rawValue: xpc_connection_t
}

// MARK: Create
public extension XPCConnection {

  @_alwaysEmitIntoClient
  init(name: UnsafePointer<CChar>?, targetQueue: DispatchQueue? = nil) {
    rawValue = xpc_connection_create(name, targetQueue)
  }

  @_alwaysEmitIntoClient
  init(endpoint: XPCObject) {
    rawValue = xpc_connection_create_from_endpoint(endpoint.rawValue)
  }

  @_alwaysEmitIntoClient
  init(machServiceName: UnsafePointer<CChar>,
       targetQueue: DispatchQueue? = nil,
       flags: Flags)  {
    rawValue = xpc_connection_create_mach_service(machServiceName, targetQueue, flags.rawValue)
  }
}

// MARK: API
public extension XPCConnection {

  @_alwaysEmitIntoClient
  func set(targetQueue: DispatchQueue?) {
    xpc_connection_set_target_queue(rawValue, targetQueue)
  }

  @_alwaysEmitIntoClient
  func set(eventHandler: @escaping (XPCObject) -> Void) {
    xpc_connection_set_event_handler(rawValue) { obj in
      eventHandler(.init(rawValue: obj))
    }
  }

  @available(macOS 12.0, *)
  @_alwaysEmitIntoClient
  func set(peerCodeSigningRequirement requirement: UnsafePointer<CChar>) -> Int32 {
    xpc_connection_set_peer_code_signing_requirement(rawValue, requirement)
  }

  @available(macOS 10.12, *)
  @_alwaysEmitIntoClient
  func activate() {
    xpc_connection_activate(rawValue)
  }

  @_alwaysEmitIntoClient
  func suspend() {
    xpc_connection_suspend(rawValue)
  }

  @_alwaysEmitIntoClient
  func resume() {
    xpc_connection_resume(rawValue)
  }

  @_alwaysEmitIntoClient
  func cancel() {
    xpc_connection_cancel(rawValue)
  }

  @_alwaysEmitIntoClient
  func send(message: XPCObject) {
    assert(message.type == .dictionary)
    xpc_connection_send_message(rawValue, message.rawValue)
  }

  @_alwaysEmitIntoClient
  func send(barrier: @escaping () -> Void) {
    xpc_connection_send_barrier(rawValue, barrier)
  }

  @_alwaysEmitIntoClient
  func send(message: XPCObject, replyQueue: DispatchQueue? = nil,
            handler: @escaping (xpc_object_t) -> Void) {
    assert(message.type == .dictionary)
    xpc_connection_send_message_with_reply(rawValue, message.rawValue, replyQueue, handler)
  }

  @_alwaysEmitIntoClient
  func waitReply(fromMessage message: XPCObject) -> XPCObject {
    assert(message.type == .dictionary)
    return .init(rawValue: xpc_connection_send_message_with_reply_sync(rawValue, message.rawValue))
  }

  @_alwaysEmitIntoClient
  @available(macOS 10.15, *)
  func reply(fromMessage message: XPCObject) async -> XPCObject {
    assert(message.type == .dictionary)
    return await withUnsafeContinuation { continuation in
      send(message: message) { rawValue in
        continuation.resume(returning: .init(rawValue: rawValue))
      }
    }
  }

  @_alwaysEmitIntoClient
  var endpoint: XPCObject {
    .init(rawValue: xpc_endpoint_create(rawValue))
  }
}

extension XPCConnection {
  public struct Flags: OptionSet {
    public init(rawValue: UInt64) {
      self.rawValue = rawValue
    }

    public var rawValue: UInt64

    @_alwaysEmitIntoClient
    public static var machServiceListener: Self { .init(rawValue: UInt64(XPC_CONNECTION_MACH_SERVICE_LISTENER)) }

    @_alwaysEmitIntoClient
    public static var machServicePrivileged: Self { .init(rawValue: UInt64(XPC_CONNECTION_MACH_SERVICE_PRIVILEGED)) }
  }
}
