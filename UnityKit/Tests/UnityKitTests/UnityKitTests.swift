import XCTest
@testable import UnityKit

final class UnityKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UnityKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
