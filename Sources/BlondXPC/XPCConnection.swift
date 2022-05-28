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

  init(endpoint: xpc_endpoint_t) {
    rawValue = xpc_connection_create_from_endpoint(endpoint)
  }

  init(machServiceName: UnsafePointer<CChar>,
       targetQueue: DispatchQueue? = nil,
       flags: UInt64)  {
    rawValue = xpc_connection_create_mach_service(machServiceName, targetQueue, flags)
  }
}

// MARK: API
public extension XPCConnection {
  func set(targetQueue: DispatchQueue?) {
    xpc_connection_set_target_queue(rawValue, targetQueue)
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
}
