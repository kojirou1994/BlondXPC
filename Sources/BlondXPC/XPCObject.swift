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
  init(_ value: Bool) {
    rawValue = xpc_bool_create(value)
  }

  init(_ value: Int64) {
    rawValue = xpc_int64_create(value)
  }

  init(_ value: UInt64) {
    rawValue = xpc_uint64_create(value)
  }

  init(_ value: Double) {
    rawValue = xpc_double_create(value)
  }

  init(_ value: UUID) {
    rawValue = withUnsafeBytes(of: value.uuid) { buffer in
      xpc_uuid_create(buffer.baseAddress!)
    }
  }

  init(_ value: CFUUID) {
    self.init(CFUUIDGetUUIDBytes(value))
  }

  init(_ value: CFUUIDBytes) {
    rawValue = withUnsafeBytes(of: value) { buffer in
      xpc_uuid_create(buffer.baseAddress!)
    }
  }

  init(_ value: XPCArray) {
    rawValue = value.rawValue
  }

  init(_ value: XPCDictionary) {
    rawValue = value.rawValue
  }

  static func string(_ value: UnsafePointer<CChar>) -> Self {
    .init(rawValue: xpc_string_create(value))
  }

  static func string(format: UnsafePointer<CChar>, _ ap: CVaListPointer) -> Self {
    .init(rawValue: xpc_string_create_with_format_and_arguments(format, ap))
  }

  init(_ value: __DispatchData) {
    rawValue = xpc_data_create_with_dispatch_data(value)
  }

  static var null: Self { .init(rawValue: xpc_null_create()) }
  static var `true`: Self { .init(rawValue: XPC_BOOL_TRUE) }
  static var `false`: Self { .init(rawValue: XPC_BOOL_FALSE) }

  static func data<T: ContiguousBytes>(bytesCopiedFrom bytes: T) -> Self {
    bytes.withUnsafeBytes { buffer in
      Self(rawValue: xpc_data_create(buffer.baseAddress, buffer.count))
    }
  }

  static func duplicatedFD(_ fd: Int32) -> Self? {
    xpc_fd_create(fd).map(Self.init)
  }

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  static func duplicatedFD(_ fd: FileDescriptor) -> Self? {
    .duplicatedFD(fd.rawValue)
  }

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
  var unsafeBool: Bool {
    xpc_bool_get_value(rawValue)
  }

  var unsafeDouble: Double {
    xpc_double_get_value(rawValue)
  }

  var unsafeInt64: Int64 {
    xpc_int64_get_value(rawValue)
  }

  var unsafeUInt64: UInt64 {
    xpc_uint64_get_value(rawValue)
  }

  var unsafeDataPointer: UnsafeRawPointer? {
    xpc_data_get_bytes_ptr(rawValue)
  }

  var dataLength: Int {
    xpc_data_get_length(rawValue)
  }

  var unsafeDataBufferPointer: UnsafeRawBufferPointer {
    .init(start: unsafeDataPointer, count: dataLength)
  }

  var unsafeStringPointer: UnsafePointer<CChar>? {
    xpc_string_get_string_ptr(rawValue)
  }

  var stringLength: Int {
    xpc_string_get_length(rawValue)
  }

  var unsafeDate: Int64 {
    xpc_date_get_value(rawValue)
  }

  /// don't free result
  var unsafeUUID: UnsafePointer<UInt8>? {
    xpc_uuid_get_bytes(rawValue)
  }

  // MARK: Safe Get
  var bool: Bool? {
    guard type == .bool else {
      return nil
    }
    return unsafeBool
  }

  var double: Double? {
    guard type == .double else {
      return nil
    }
    return unsafeDouble
  }

  var int64: Int64? {
    guard type == .int64 else {
      return nil
    }
    return unsafeInt64
  }

  var uint64: UInt64? {
    guard type == .uint64 else {
      return nil
    }
    return unsafeUInt64
  }

  func copyDataBytes(into buffer: UnsafeMutableRawBufferPointer,
                     offset: Int) -> Int {
    guard let baseAddress = buffer.baseAddress else {
      return 0
    }
    return xpc_data_get_bytes(rawValue, baseAddress, offset, buffer.count)
  }

  var string: String? {
    guard type == .string else {
      return nil
    }
    return String(decoding: UnsafeRawBufferPointer(start: unsafeStringPointer, count: stringLength), as: UTF8.self)
  }

  var duplicateFD: Int32? {
    let fd = xpc_fd_dup(rawValue)
    return fd == -1 ? nil : fd
  }

  var date: Int64? {
    guard type == .date else {
      return nil
    }
    return unsafeDate
  }

  var uuidReference: NSUUID? {
    guard type == .uuid else {
      return nil
    }
    return NSUUID(uuidBytes: unsafeUUID)
  }

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

  var array: XPCArray? {
    guard type == .array else {
      return nil
    }
    return .init(rawValue: rawValue)
  }

  var dictionary: XPCDictionary? {
    guard type == .dictionary else {
      return nil
    }
    return .init(rawValue: rawValue)
  }

}

// MARK: Copy
public extension XPCObject {
  func copy() -> Self? {
    xpc_copy(rawValue).map(Self.init)
  }

  func copyDescription() -> LazyCopiedCString {
    .init(cString: xpc_copy_description(rawValue), freeWhenDone: true)
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
