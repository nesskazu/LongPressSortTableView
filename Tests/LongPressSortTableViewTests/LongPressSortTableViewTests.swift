import XCTest
@testable import LongPressSortTableView

class LongPressSortTableViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(LongPressSortTableView().text, "Hello, World!")
    }


    static var allTests : [(String, (LongPressSortTableViewTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
