import XCTest
@testable import OrderedDictionary

final class OrderedDictionaryTests: XCTestCase {

    func testOrderedKeys() {
        let expectation = (1...10_000).map { _ in UUID().uuidString }

        var dict = OrderedDictionary<String, String>()
        expectation.forEach {
            dict[$0] = UUID().uuidString
        }

        XCTAssertEqual(dict.orderedKeys, expectation)
    }

    func testOrderedKeysConcurrent() {
        let expectation = (1...10_000).map { _ in UUID().uuidString }

        var dict = OrderedDictionary<String, String>()
        DispatchQueue.concurrentPerform(iterations: 10_000) { iteration in
            dict["\(iteration)"] = UUID().uuidString
        }

        XCTAssertEqual(dict.orderedKeys, expectation)
    }

    static var allTests = [
        ("testOrderedKeys", testOrderedKeys),
    ]
}
