import XPC

public struct XPCArray: RawRepresentable {
  public init(rawValue: xpc_object_t) {
    self.rawValue = rawValue
  }

  public let rawValue: xpc_object_t
}

extension XPCArray: MutableCollection, BidirectionalCollection, RandomAccessCollection {

  public func index(after i: Int) -> Int {
    i + 1
  }

  public typealias Element = XPCObject

  public var count: Int {
    xpc_array_get_count(rawValue)
  }

  public var startIndex: Int { 0 }
  public var endIndex: Int { count }

  public subscript(position: Int) -> XPCObject {
    get {
      precondition((startIndex..<endIndex) ~= position)
      return .init(rawValue: xpc_array_get_value(rawValue, position))
    }
    nonmutating set {
      precondition((startIndex..<endIndex) ~= position)
      check(newValue)
      xpc_array_set_value(rawValue, position, newValue.rawValue)
    }
  }
}

public extension XPCArray {

  init() {
    rawValue = xpc_array_create(nil, 0)
  }

  init<T: Sequence>(_ elements: T) where T.Element == XPCObject {
    rawValue = Array(elements).withUnsafeBufferPointer { buffer in
      xpc_array_create(.init(OpaquePointer(buffer.baseAddress)), buffer.count)
    }
  }

  func append(_ newElement: XPCObject) {
    check(newElement)
    xpc_array_append_value(rawValue, newElement.rawValue)
  }

  private func check(_ newElement: XPCObject) {
    precondition(newElement.rawValue !== rawValue, "add array to itself will cause memory leak! use copy.")
  }
}

extension XPCArray: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: XPCObject...) {
    self.init(elements)
  }
}

public extension XPCArray {

  func toNative() -> [Any] {
    compactMap(\.native)
  }

}
