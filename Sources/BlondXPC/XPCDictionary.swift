import XPC

public struct XPCDictionary: RawRepresentable {
  public init(rawValue: xpc_object_t) {
    self.rawValue = rawValue
  }

  public let rawValue: xpc_object_t
}

public extension XPCDictionary {

  @_alwaysEmitIntoClient
  init() {
    rawValue = xpc_dictionary_create(nil, nil, 0)
  }

  @_alwaysEmitIntoClient
  func createReply() -> Self? {
    xpc_dictionary_create_reply(rawValue).map(Self.init)
  }

  @_alwaysEmitIntoClient
  var remoteConnection: XPCConnection? {
    xpc_dictionary_get_remote_connection(rawValue).map(XPCConnection.init)
  }

  @_alwaysEmitIntoClient
  var count: Int {
    xpc_dictionary_get_count(rawValue)
  }

  @_alwaysEmitIntoClient
  subscript(key: UnsafePointer<CChar>) -> XPCObject? {
    get {
      xpc_dictionary_get_value(rawValue, key).map(XPCObject.init)
    }
    nonmutating set {
      precondition(newValue?.rawValue !== rawValue)
      xpc_dictionary_set_value(rawValue, key, newValue?.rawValue)
    }
  }
}

extension XPCDictionary: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, XPCObject)...) {
    self.init()
    elements.forEach { self[$0.0] = $0.1 }
  }
}

public extension XPCDictionary {
  @_alwaysEmitIntoClient
  func toNative() -> [String: Any] {
    var result = [String: Any]()
    xpc_dictionary_apply(rawValue) { key, value in
      result[String(cString: key)] = XPCObject(rawValue: value).native
      return true
    }
    return result
  }
}
