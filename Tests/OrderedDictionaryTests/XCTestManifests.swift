import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(IndexingTests.allTests),
        testCase(OrderedKeysTests.allTests),
    ]
}
#endif
