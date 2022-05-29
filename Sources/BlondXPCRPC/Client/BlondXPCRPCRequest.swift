public protocol BlondXPCRPCRequest {
  associatedtype Body: Encodable
  associatedtype Success: Decodable
  associatedtype Error: Decodable & Swift.Error
  var method: String { get }
  var body: Body { get }
}
