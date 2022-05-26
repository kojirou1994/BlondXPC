import XPC
import CUtility
import Foundation

public struct XPCObject: RawRepresentable {
  public init(rawValue: xpc_object_t) {
    self.rawValue = rawValue
  }

  public let rawValue: xpc_object_t
}

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

  init(_ value: UnsafePointer<CChar>) {
    rawValue = xpc_string_create(value)
  }

  init(format: UnsafePointer<CChar>, _ ap: CVaListPointer) {
    rawValue = xpc_string_create_with_format_and_arguments(format, ap)
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
    guard let ptr = buffer.baseAddress else {
      return 0
    }
    return xpc_data_get_bytes(rawValue, ptr, offset, buffer.count)
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
