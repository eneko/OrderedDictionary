import Foundation

private let queue = DispatchQueue(label: "OrderedDictionarySerialQueue")

/// OrderedDictionary is a thread-safe data structure that preserves
/// key insertion order.
///
/// Similar to Dictionary, values can be set/read/cleared using subscripting.
///
///     var dict = OrderedDictionary<String, String>()
///     dict["key"] = "value" // set
///     dict["key"]           // get
///     dict["key"] = nil     // remove
///
/// Both keys and values can be read in-order of insertion. Conformance to
/// `Sequence` protocol allows for easy iteration over keys and values.
public struct OrderedDictionary<Key: Hashable, Value> {
    private var store: [Key: Value] = [:]
    private var indices: [Key: Int] = [:]

    public init() {

    }

    public subscript(key: Key) -> Value? {
        get {
            return getValue(forKey: key)
        }
        set {
            if let value = newValue {
                set(value: value, forKey: key)
            } else {
                remove(key: key)
            }
        }
    }

    private func getValue(forKey key: Key) -> Value? {
        var value: Value?
        queue.sync {
            value = self.store[key]
        }
        return value
    }

    /// Store a value in the dictionary under the given key.
    ///
    /// - Parameters:
    ///   - value: Value to be stored
    ///   - key: Key to be used to retrieve the value
    /// - Complexity: O(n)
    private mutating func set(value: Value, forKey key: Key) {
        queue.sync {
            if let _ = self.indices[key] {
                // Already in dictionary, keep current index
            } else {
                self.indices[key] = self.indices.keys.count
            }
            store[key] = value
        }
    }

    private mutating func remove(key: Key) {
        queue.sync {
            self.indices[key] = nil
            self.store[key] = nil
            self.reindex()
        }
    }

    private mutating func reindex() {
        queue.sync {
            let sortedIndices = indices.sorted(by: { $0.value < $1.value })
            sortedIndices.enumerated().forEach { (offset, pair) in
                self.indices[pair.key] = offset
            }
        }
    }

}

extension OrderedDictionary {

    /// Collection of key/value pairs sorted by insertion order.
    public var orderedKeyValuePairs: [(key: Key, value: Value)] {
        var result: [(key: Key, value: Value)] = []
        queue.sync {
            let sortedIndices = indices.sorted(by: { $0.value < $1.value })
            result = sortedIndices.compactMap { (key, _) in
                let value = store[key]
                return value.flatMap { (key: key, value: $0) }
            }
//            for index in sortedIndices let value = store[index.value] {
//
//            }
        }
        return result
    }

    /// Collection of keys sorted by insertion order.
    public var orderedKeys: [Key] {
        var keys: [Key] = []
        queue.sync {
            keys = orderedIndices.map { $0.key }
        }
        return keys
    }

    /// Collection of keys sorted by insertion order.
    public var orderedValues: [Value] {
        return orderedKeyValuePairs.map { $0.value }
    }

    private var orderedIndices: [(key: Key, value: Int)] {
        return indices.sorted(by: { $0.value < $1.value })
    }
}
