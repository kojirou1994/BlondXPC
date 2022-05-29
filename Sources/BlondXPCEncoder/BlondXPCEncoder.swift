import BlondXPC
import Foundation

public struct BlondXPCEncoder {
  public init() {}
  private let _encoder = JSONEncoder()
  public func encode<T: Encodable>(_ value: T) throws -> XPCObject {
    .data(bytesCopiedFrom: try _encoder.encode(value))
  }
}

public struct BlondXPCDecoder {
  public init() {}
  private let _decoder = JSONDecoder()
  public func decode<T: Decodable>(_ value: XPCObject) throws -> T {
    try _decoder.decode(T.self, from: Data(bytesNoCopy: .init(mutating: value.unsafeDataPointer!), count: value.dataLength, deallocator: .none))
  }
}
