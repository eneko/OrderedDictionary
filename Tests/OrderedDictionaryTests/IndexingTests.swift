import XCTest
import OrderedDictionary

class IndexingTests: XCTestCase {

    func testIsEmpty() {
        var dict = OrderedDictionary<String, String>()
        XCTAssertTrue(dict.isEmpty)
        dict["foo"] = "FOO"
        XCTAssertFalse(dict.isEmpty)
        dict["foo"] = nil
        XCTAssertTrue(dict.isEmpty)
    }

    func testCount() {
        var dict = OrderedDictionary<String, String>()
        XCTAssertEqual(dict.count, 0)
        dict["foo"] = "FOO"
        XCTAssertEqual(dict.count, 1)
        dict["foo"] = nil
        XCTAssertEqual(dict.count, 0)
    }

    func testOrderConsistency() {
        var dict = OrderedDictionary<String, String>()
        dict["foo"] = "FOO"
        dict["bar"] = "BAR"
        dict["bar"] = nil
        dict["baz"] = "BAZ"
        XCTAssertEqual(dict.orderedKeys, ["foo", "baz"])
        XCTAssertEqual(dict.orderedValues, ["FOO", "BAZ"])
        dict["foo"] = nil
        dict["foo"] = "FOO"
        XCTAssertEqual(dict.orderedKeys, ["baz", "foo"])
        XCTAssertEqual(dict.orderedValues, ["BAZ", "FOO"])
    }

    static var allTests = [
        ("testCount", testCount),
        ("testIsEmpty", testIsEmpty),
        ("testOrderConsistency", testOrderConsistency),
    ]
}
