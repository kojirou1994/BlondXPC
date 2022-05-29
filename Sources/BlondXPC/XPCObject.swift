import XPC
import CUtility
import Foundation
import System

public struct XPCObject: RawRepresentable {
  public init(rawValue: xpc_object_t) {
    self.rawValue = rawValue
  }

  public let rawValue: xpc_object_t
}
/*

 pure stack value use init
 heap values use static func

 */
// MARK: Create
public extension XPCObject {

  @_alwaysEmitIntoClient
  init(_ value: Bool) {
    rawValue = xpc_bool_create(value)
  }

  @_alwaysEmitIntoClient
  init(_ value: Int64) {
    rawValue = xpc_int64_create(value)
  }

  @_alwaysEmitIntoClient
  init(_ value: UInt64) {
    rawValue = xpc_uint64_create(value)
  }

  @_alwaysEmitIntoClient
  init(_ value: Double) {
    rawValue = xpc_double_create(value)
  }

  @_alwaysEmitIntoClient
  init(_ value: UUID) {
    rawValue = withUnsafeBytes(of: value.uuid) { buffer in
      xpc_uuid_create(buffer.baseAddress!)
    }
  }

  @_alwaysEmitIntoClient
  init(_ value: CFUUID) {
    self.init(CFUUIDGetUUIDBytes(value))
  }

  @_alwaysEmitIntoClient
  init(_ value: CFUUIDBytes) {
    rawValue = withUnsafeBytes(of: value) { buffer in
      xpc_uuid_create(buffer.baseAddress!)
    }
  }

  @_alwaysEmitIntoClient
  init(_ value: XPCArray) {
    rawValue = value.rawValue
  }

  @_alwaysEmitIntoClient
  init(_ value: XPCDictionary) {
    rawValue = value.rawValue
  }

  @_alwaysEmitIntoClient
  static func string(_ value: UnsafePointer<CChar>) -> Self {
    .init(rawValue: xpc_string_create(value))
  }

  @_alwaysEmitIntoClient
  static func string(format: UnsafePointer<CChar>, _ ap: CVaListPointer) -> Self {
    .init(rawValue: xpc_string_create_with_format_and_arguments(format, ap))
  }

  @_alwaysEmitIntoClient
  init(_ value: __DispatchData) {
    rawValue = xpc_data_create_with_dispatch_data(value)
  }

  @_alwaysEmitIntoClient
  static var null: Self { .init(rawValue: xpc_null_create()) }

  @_alwaysEmitIntoClient
  static var `true`: Self { .init(rawValue: XPC_BOOL_TRUE) }

  @_alwaysEmitIntoClient
  static var `false`: Self { .init(rawValue: XPC_BOOL_FALSE) }

  @_alwaysEmitIntoClient
  static var errorConnectionInterrupted: Self { .init(rawValue: XPC_ERROR_CONNECTION_INTERRUPTED) }

  @_alwaysEmitIntoClient
  static var errorConnectionInvalid: Self { .init(rawValue: XPC_ERROR_CONNECTION_INVALID) }

  @_alwaysEmitIntoClient
  static var errorTerminationImminent: Self { .init(rawValue: XPC_ERROR_TERMINATION_IMMINENT) }

  @_alwaysEmitIntoClient
  static func data<T: ContiguousBytes>(bytesCopiedFrom bytes: T) -> Self {
    bytes.withUnsafeBytes { buffer in
      Self(rawValue: xpc_data_create(buffer.baseAddress, buffer.count))
    }
  }

  @_alwaysEmitIntoClient
  static func duplicatedFD(_ fd: Int32) -> Self? {
    xpc_fd_create(fd).map(Self.init)
  }

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  @_alwaysEmitIntoClient
  static func duplicatedFD(_ fd: FileDescriptor) -> Self? {
    .duplicatedFD(fd.rawValue)
  }

  @_alwaysEmitIntoClient
  static func date(interval: Int64? = nil) -> Self {
    if let interval = interval {
      return .init(rawValue: xpc_date_create(interval))
    } else {
      return .init(rawValue: xpc_date_create_from_current())
    }
  }
}

// MARK: Get
public extension XPCObject {
  // MARK: Unsafe Get

  @_alwaysEmitIntoClient
  var unsafeBool: Bool {
    xpc_bool_get_value(rawValue)
  }

  @_alwaysEmitIntoClient
  var unsafeDouble: Double {
    xpc_double_get_value(rawValue)
  }

  @_alwaysEmitIntoClient
  var unsafeInt64: Int64 {
    xpc_int64_get_value(rawValue)
  }

  @_alwaysEmitIntoClient
  var unsafeUInt64: UInt64 {
    xpc_uint64_get_value(rawValue)
  }

  @_alwaysEmitIntoClient
  var unsafeDataPointer: UnsafeRawPointer? {
    xpc_data_get_bytes_ptr(rawValue)
  }

  @_alwaysEmitIntoClient
  var dataLength: Int {
    xpc_data_get_length(rawValue)
  }

  @_alwaysEmitIntoClient
  var unsafeDataBufferPointer: UnsafeRawBufferPointer {
    .init(start: unsafeDataPointer, count: dataLength)
  }

  @_alwaysEmitIntoClient
  var unsafeStringPointer: UnsafePointer<CChar>? {
    xpc_string_get_string_ptr(rawValue)
  }

  @_alwaysEmitIntoClient
  var stringLength: Int {
    xpc_string_get_length(rawValue)
  }

  @_alwaysEmitIntoClient
  var unsafeDate: Int64 {
    xpc_date_get_value(rawValue)
  }

  /// don't free result
  @_alwaysEmitIntoClient
  var unsafeUUID: UnsafePointer<UInt8>? {
    xpc_uuid_get_bytes(rawValue)
  }

  // MARK: Safe Get

  @_alwaysEmitIntoClient
  var bool: Bool? {
    guard type == .bool else {
      return nil
    }
    return unsafeBool
  }

  @_alwaysEmitIntoClient
  var double: Double? {
    guard type == .double else {
      return nil
    }
    return unsafeDouble
  }

  @_alwaysEmitIntoClient
  var int64: Int64? {
    guard type == .int64 else {
      return nil
    }
    return unsafeInt64
  }

  @_alwaysEmitIntoClient
  var uint64: UInt64? {
    guard type == .uint64 else {
      return nil
    }
    return unsafeUInt64
  }

  @_alwaysEmitIntoClient
  func copyDataBytes(into buffer: UnsafeMutableRawBufferPointer,
                     offset: Int) -> Int {
    guard let baseAddress = buffer.baseAddress else {
      return 0
    }
    return xpc_data_get_bytes(rawValue, baseAddress, offset, buffer.count)
  }

  @_alwaysEmitIntoClient
  var string: String? {
    guard type == .string else {
      return nil
    }
    return String(decoding: UnsafeRawBufferPointer(start: unsafeStringPointer, count: stringLength), as: UTF8.self)
  }

  @_alwaysEmitIntoClient
  var duplicateFD: Int32? {
    let fd = xpc_fd_dup(rawValue)
    return fd == -1 ? nil : fd
  }

  @_alwaysEmitIntoClient
  var date: Int64? {
    guard type == .date else {
      return nil
    }
    return unsafeDate
  }

  @_alwaysEmitIntoClient
  var uuidReference: NSUUID? {
    guard type == .uuid else {
      return nil
    }
    return NSUUID(uuidBytes: unsafeUUID)
  }

  @_alwaysEmitIntoClient
  var uuid: UUID? {
    guard type == .uuid, let bytes = unsafeUUID else {
      return nil
    }
    return UUID(uuid: (
      bytes[0], bytes[1], bytes[2], bytes[3],
      bytes[4], bytes[5], bytes[6], bytes[7],
      bytes[8], bytes[9], bytes[10], bytes[11],
      bytes[12], bytes[13], bytes[14], bytes[15]
    ))
  }

  @_alwaysEmitIntoClient
  var array: XPCArray? {
    guard type == .array else {
      return nil
    }
    return .init(rawValue: rawValue)
  }

  @_alwaysEmitIntoClient
  var dictionary: XPCDictionary? {
    guard type == .dictionary else {
      return nil
    }
    return .init(rawValue: rawValue)
  }

  @_alwaysEmitIntoClient
  var native: Any? {
    switch type {
    case .array: return array!.map(\.native)
    case .bool: return unsafeBool
    case .date: return unsafeDate
    case .dictionary: return dictionary!.toNative()
    case .double: return unsafeDouble
    case .int64: return unsafeInt64
    case .null: return NSNull()
    case .string: return string!
    case .uint64: return unsafeUInt64
    case .uuid: return uuid!
    default: return nil
    }
  }

}

// MARK: Copy
public extension XPCObject {

  @_alwaysEmitIntoClient
  func copy() -> Self? {
    xpc_copy(rawValue).map(Self.init)
  }

  @_alwaysEmitIntoClient
  func copyDescription() -> LazyCopiedCString {
    .init(cString: xpc_copy_description(rawValue), freeWhenDone: true)
  }
}

extension XPCObject: CustomStringConvertible {
  public var description: String {
    copyDescription().string
  }
}

extension XPCObject: Equatable, Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(xpc_hash(rawValue))
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    xpc_equal(lhs.rawValue, rhs.rawValue)
  }
}

public extension XPCObject {
  @_alwaysEmitIntoClient
  var type: XPCType {
    .init(rawValue: xpc_get_type(rawValue))
  }
}

extension XPCObject: ExpressibleByBooleanLiteral, ExpressibleByFloatLiteral,
                     ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {
  public init(booleanLiteral value: Bool) {
    self.init(value)
  }

  public init(floatLiteral value: Double) {
    self.init(value)
  }

  public init(integerLiteral value: Int64) {
    self.init(value)
  }

  public init(stringLiteral value: String) {
    self = .string(value)
  }
}
