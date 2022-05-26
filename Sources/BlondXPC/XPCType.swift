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
