import Foundation
import Dispatch

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

    var store: [Key: Value] = [:]
    var indices: [Key: Int] = [:]
    var nextIndex = 0

    /// Initialize an empty ordered dictionary.
    public init() {}

    /// Determine if the dictionary contains any elements
    /// - complexity: O(1)
    public var isEmpty: Bool {
        return store.isEmpty
    }

    /// Determine the number of elements contained by the dictionary
    /// - complexity: O(1)
    public var count: Int {
        return store.count
    }

    /// Get or set a value using subscripting.
    ///
    ///     var dict = OrderedDictionary<String, String>()
    ///     dict["key"] = "value" // set
    ///     dict["key"]           // get
    ///     dict["key"] = nil     // remove
    ///
    /// - Parameter key: key to retrieve the value.
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

    /// Retrieve a value from the dictionary under the given key.
    ///
    /// - Parameter key: Key to be used to retrieve the value.
    /// - Returns: Value if the dictionary contained that key.
    func getValue(forKey key: Key) -> Value? {
        var value: Value?
        queue.sync {
            value = store[key]
        }
        return value
    }

    /// Store a value in the dictionary under the given key.
    ///
    /// - Parameters:
    ///   - value: Value to be stored.
    ///   - key: Key to be used to retrieve the value.
    /// - Complexity: O(n)
    mutating func set(value: Value, forKey key: Key) {
        queue.sync {
            if let _ = indices[key] {
                // Already in dictionary, keep current index
            } else {
                indices[key] = nextIndex
                nextIndex += 1
            }
            store[key] = value
        }
    }

    /// Remove an element stored in the dictionary under the given key.
    ///
    /// - Parameter key: Key where the element is stored under.
    mutating func remove(key: Key) {
        queue.sync {
            indices[key] = nil
            store[key] = nil
            reindex()
        }
    }

    private mutating func reindex() {
        guard nextIndex - count > reindexThreshold else {
            return
        }

        for (offset, index) in orderedIndices.enumerated() {
            indices[index.key] = offset
        }
        nextIndex = count
    }

    private let reindexThreshold = 1024 * 1024
}

extension OrderedDictionary {

    private var orderedIndices: [(key: Key, value: Int)] {
        return indices.sorted(by: { $0.value < $1.value })
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

    /// Collection of key/value pairs sorted by insertion order.
    public var orderedKeyValuePairs: [(key: Key, value: Value)] {
        var result: [(key: Key, value: Value)] = []
        queue.sync {
            result = orderedIndices.compactMap { (key, _) in
                let value = store[key]
                return value.flatMap { (key: key, value: $0) }
            }
        }
        return result
    }

}
