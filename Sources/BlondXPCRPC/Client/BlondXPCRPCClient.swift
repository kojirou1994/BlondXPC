import BlondXPC
import BlondXPCEncoder
import Foundation

public final class BlondXPCRPCClient {
  public init(connection: XPCConnection) {
    self.connection = connection
  }

  public let connection: XPCConnection
  private var currentID: UInt64 = 0
  private let idLock = NSLock()
  let encoder: BlondXPCEncoder = .init()
  let decoder: BlondXPCDecoder = .init()

  @available(macOS 10.15, *)
  public func result<T, R, E>(method: String, _ body: T) async throws -> Result<R, E> where T: Encodable, R: Decodable, E: Decodable, E: Error {
    let req = XPCDictionary()
    req["method"] = XPCObject.string(method)
    idLock.lock()
    req["id"] = XPCObject(currentID)
    currentID += 1
    idLock.unlock()

    req["params"] = try encoder.encode(body)

    let reply = connection.waitReply(message: XPCObject(req)).dictionary!

    if let success = reply["success"] {
      return .success(try decoder.decode(success))
    } else if let error = reply["error"] {
      return .failure(try decoder.decode(error))
    } else {
      fatalError()
    }
  }

  @available(macOS 10.15, *)
  public func result<T: BlondXPCRPCRequest>(request: T) async throws -> Result<T.Success, T.Error> {
    try await result(method: request.method, request.body)
  }
}
