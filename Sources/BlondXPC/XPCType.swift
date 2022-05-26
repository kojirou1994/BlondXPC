import XPC
import CUtility

public struct XPCType: RawRepresentable, CustomStringConvertible {

  public init(rawValue: xpc_type_t) {
    self.rawValue = rawValue
  }

  public let rawValue: xpc_type_t

  @available(macOS 10.15, *)
  public var name: StaticCString {
    .init(cString: xpc_type_get_name(rawValue))
  }

  public var description: String {
    if #available(macOS 10.15, *) {
      return name.string
    } else {
      switch rawValue {
      case XPC_TYPE_ACTIVITY: return "activity"
      case XPC_TYPE_ARRAY: return "array"
      case XPC_TYPE_BOOL: return "bool"
      case XPC_TYPE_CONNECTION: return "connection"
      case XPC_TYPE_DATA: return "data"
      case XPC_TYPE_DATE: return "date"
      case XPC_TYPE_DICTIONARY: return "dictionary"
      case XPC_TYPE_DOUBLE: return "double"
      case XPC_TYPE_ENDPOINT: return "endpoint"
      case XPC_TYPE_ERROR: return "error"
      case XPC_TYPE_FD: return "fd"
      case XPC_TYPE_INT64: return "int64"
      case XPC_TYPE_NULL: return "null"
      case XPC_TYPE_SHMEM: return "shmem"
      case XPC_TYPE_STRING: return "string"
      case XPC_TYPE_UINT64: return "uint64"
      case XPC_TYPE_UUID: return "uuid"
      default: return "unknown: " + String(describing: rawValue)
      }
    }
  }
}

extension XPCType: Equatable {}

public extension XPCType {
  @_alwaysEmitIntoClient
  static var activity: Self { .init(rawValue: XPC_TYPE_ACTIVITY) }
  @_alwaysEmitIntoClient
  static var array: Self { .init(rawValue: XPC_TYPE_ARRAY) }
  @_alwaysEmitIntoClient
  static var bool: Self { .init(rawValue: XPC_TYPE_BOOL) }
  @_alwaysEmitIntoClient
  static var connection: Self { .init(rawValue: XPC_TYPE_CONNECTION) }
  @_alwaysEmitIntoClient
  static var data: Self { .init(rawValue: XPC_TYPE_DATA) }
  @_alwaysEmitIntoClient
  static var date: Self { .init(rawValue: XPC_TYPE_DATE) }
  @_alwaysEmitIntoClient
  static var dictionary: Self { .init(rawValue: XPC_TYPE_DICTIONARY) }
  @_alwaysEmitIntoClient
  static var double: Self { .init(rawValue: XPC_TYPE_DOUBLE) }
  @_alwaysEmitIntoClient
  static var endpoint: Self { .init(rawValue: XPC_TYPE_ENDPOINT) }
  @_alwaysEmitIntoClient
  static var error: Self { .init(rawValue: XPC_TYPE_ERROR) }
  @_alwaysEmitIntoClient
  static var fd: Self { .init(rawValue: XPC_TYPE_FD) }
  @_alwaysEmitIntoClient
  static var int64: Self { .init(rawValue: XPC_TYPE_INT64) }
  @_alwaysEmitIntoClient
  static var null: Self { .init(rawValue: XPC_TYPE_NULL) }
  @_alwaysEmitIntoClient
  static var shmem: Self { .init(rawValue: XPC_TYPE_SHMEM) }
  @_alwaysEmitIntoClient
  static var string: Self { .init(rawValue: XPC_TYPE_STRING) }
  @_alwaysEmitIntoClient
  static var uint64: Self { .init(rawValue: XPC_TYPE_UINT64) }
  @_alwaysEmitIntoClient
  static var uuid: Self { .init(rawValue: XPC_TYPE_UUID) }
}
