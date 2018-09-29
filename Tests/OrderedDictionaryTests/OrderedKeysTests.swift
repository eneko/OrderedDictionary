import XCTest
import OrderedDictionary

final class OrderedKeysTests: XCTestCase {

    let sourceData = (1...1_000).map { _ in (key: UUID().uuidString, value: UUID().uuidString) }

    func testOrderedKeys() {
        measure {
            var dict = OrderedDictionary<String, String>()
            sourceData.forEach {
                dict[$0.key] = $0.value
            }

            XCTAssertEqual(dict.orderedKeys, sourceData.map { $0.key })
            sourceData.forEach {
                XCTAssertEqual(dict[$0.key], $0.value)
            }
        }
    }

    func testOrderedKeysConcurrent() {
        measure {
            var dict = OrderedDictionary<String, String>()
            DispatchQueue.concurrentPerform(iterations: sourceData.count) { iteration in
                let key = sourceData[iteration].key
                dict[key] = sourceData[iteration].value
            }

            XCTAssertEqual(dict.orderedKeys.count, sourceData.count)

            DispatchQueue.concurrentPerform(iterations: sourceData.count) { iteration in
                let pair = sourceData[iteration]
                XCTAssertEqual(dict[pair.key], pair.value)
            }
        }
    }

    func testOrderedKeysAsync() {
        measure {
            var dict = OrderedDictionary<String, String>()

            let group = DispatchGroup()
            sourceData.forEach { pair in
                group.enter()
                DispatchQueue.global().async {
                    dict[pair.key] = pair.value
                    group.leave()
                }
            }
            group.wait()

            XCTAssertEqual(dict.orderedKeys.count, sourceData.count)

            sourceData.forEach { pair in
                group.enter()
                DispatchQueue.global().async {
                    XCTAssertEqual(dict[pair.key], pair.value)
                    group.leave()
                }
                group.wait()
            }
        }
    }

    func testOrderedKeysSetTwice() {
        measure {
            var dict = OrderedDictionary<String, String>()
            sourceData.forEach {
                dict[$0.key] = $0.value
                dict[$0.key] = "foo"
            }

            XCTAssertEqual(dict.orderedKeys, sourceData.map { $0.key })
            sourceData.forEach {
                XCTAssertEqual(dict[$0.key], "foo")
            }
        }
    }

    func testOrderedKeysSetAndClear() {
        measure {
            var dict = OrderedDictionary<String, String>()
            sourceData.forEach {
                dict[$0.key] = $0.value
                dict[$0.key] = nil
            }

            XCTAssertEqual(dict.orderedKeys.count, 0)
            sourceData.forEach {
                XCTAssertNil(dict[$0.key])
            }
        }
    }

    func testOrderedKeysSetThenClear() {
        measure {
            var dict = OrderedDictionary<String, String>()
            sourceData.forEach {
                dict[$0.key] = $0.value
            }
            sourceData.forEach {
                dict[$0.key] = nil
            }

            XCTAssertEqual(dict.orderedKeys.count, 0)
            sourceData.forEach {
                XCTAssertNil(dict[$0.key])
            }
        }
    }

    static var allTests = [
        ("testOrderedKeys", testOrderedKeys),
        ("testOrderedKeysConcurrent", testOrderedKeysConcurrent),
        ("testOrderedKeysAsync", testOrderedKeysAsync),
        ("testOrderedKeysSetTwice", testOrderedKeysSetTwice),
        ("testOrderedKeysSetAndClear", testOrderedKeysSetAndClear),
        ("testOrderedKeysSetThenClear", testOrderedKeysSetThenClear)
    ]
}
