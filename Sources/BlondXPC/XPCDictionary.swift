import XPC

public struct XPCDictionary: RawRepresentable {
  public init(rawValue: xpc_object_t) {
    self.rawValue = rawValue
  }

  public let rawValue: xpc_object_t
}

public extension XPCDictionary {
  init() {
    rawValue = xpc_dictionary_create(nil, nil, 0)
  }

  func createReply() -> Self? {
    xpc_dictionary_create_reply(rawValue).map(Self.init)
  }

  var count: Int {
    xpc_dictionary_get_count(rawValue)
  }

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
  func toNative() -> [String: Any] {
    var result = [String: Any]()
    xpc_dictionary_apply(rawValue) { key, value in
      result[String(cString: key)] = XPCObject(rawValue: value).native
      return true
    }
    return result
  }
}
