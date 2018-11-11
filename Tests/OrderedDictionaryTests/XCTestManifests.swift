import XCTest

extension IndexingTests {
    static let __allTests = [
        ("testCount", testCount),
        ("testGetter", testGetter),
        ("testIsEmpty", testIsEmpty),
        ("testOrderConsistency", testOrderConsistency),
    ]
}

extension OrderedKeysTests {
    static let __allTests = [
        ("testOrderedKeys", testOrderedKeys),
        ("testOrderedKeysAsync", testOrderedKeysAsync),
        ("testOrderedKeysConcurrent", testOrderedKeysConcurrent),
        ("testOrderedKeysSetAndClear", testOrderedKeysSetAndClear),
        ("testOrderedKeysSetThenClear", testOrderedKeysSetThenClear),
        ("testOrderedKeysSetTwice", testOrderedKeysSetTwice),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(IndexingTests.__allTests),
        testCase(OrderedKeysTests.__allTests),
    ]
}
#endif
