import XPC
import CUtility
import Dispatch

public struct XPCConnection: RawRepresentable {
  public init(rawValue: xpc_connection_t) {
    self.rawValue = rawValue
  }

  public let rawValue: xpc_connection_t
}

// MARK: Create
public extension XPCConnection {
  init(name: UnsafePointer<CChar>?, targetQueue: DispatchQueue? = nil) {
    rawValue = xpc_connection_create(name, targetQueue)
  }

  init(endpoint: XPCObject) {
    rawValue = xpc_connection_create_from_endpoint(endpoint.rawValue)
  }

  init(machServiceName: UnsafePointer<CChar>,
       targetQueue: DispatchQueue? = nil,
       flags: Flags)  {
    rawValue = xpc_connection_create_mach_service(machServiceName, targetQueue, flags.rawValue)
  }
}

// MARK: API
public extension XPCConnection {
  func set(targetQueue: DispatchQueue?) {
    xpc_connection_set_target_queue(rawValue, targetQueue)
  }

  func set(eventHandler: @escaping (XPCObject) -> Void) {
    xpc_connection_set_event_handler(rawValue) { obj in
      eventHandler(.init(rawValue: obj))
    }
  }

  @available(macOS 12.0, *)
  func set(peerCodeSigningRequirement requirement: UnsafePointer<CChar>) -> Int32 {
    xpc_connection_set_peer_code_signing_requirement(rawValue, requirement)
  }

  @available(macOS 10.12, *)
  func activate() {
    xpc_connection_activate(rawValue)
  }

  func suspend() {
    xpc_connection_suspend(rawValue)
  }

  func resume() {
    xpc_connection_resume(rawValue)
  }

  func cancel() {
    xpc_connection_cancel(rawValue)
  }

  func send(message: XPCObject) {
    xpc_connection_send_message(rawValue, message.rawValue)
  }

  func send(barrier: @escaping () -> Void) {
    xpc_connection_send_barrier(rawValue, barrier)
  }

  func send(message: XPCObject, replyQueue: DispatchQueue? = nil,
            handler: @escaping (xpc_object_t) -> Void) {
    xpc_connection_send_message_with_reply(rawValue, message.rawValue, replyQueue, handler)
  }

  func waitReply(message: XPCObject) -> XPCObject {
    .init(rawValue: xpc_connection_send_message_with_reply_sync(rawValue, message.rawValue))
  }

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

    public static var machServiceListener: Self { .init(rawValue: UInt64(XPC_CONNECTION_MACH_SERVICE_LISTENER)) }
    public static var machServicePrivileged: Self { .init(rawValue: UInt64(XPC_CONNECTION_MACH_SERVICE_PRIVILEGED)) }
  }
}
