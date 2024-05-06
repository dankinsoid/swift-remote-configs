@testable import SwiftRemoteConfigs
import XCTest

final class SwiftRemoteConfigsTests: XCTestCase {

    static var allTests = [
        ("testReadDefaultValue", testReadDefaultValue),
        ("testReadValue", testReadValue),
        ("testRewriteValue", testRewriteValue),
        ("testListen", testListen),
        ("testDidFetch", testDidFetch),
        ("testFetchIfNeeded", testFetchIfNeeded),
    ]

	var handler = MockRemoteConfigsHandler()

	override func setUp() {
		super.setUp()
        RemoteConfigsSystem.bootstrapInternal(self.handler)
	}

	func testReadDefaultValue() {
		// Act
        let value = RemoteConfigs().testKey

		// Assert
        XCTAssertEqual(value, RemoteConfigs.Keys().testKey.defaultValue())
	}

    func testReadValue() {
        // Arrange
        self.handler.set("value", for: \.testKey)

        // Act
        let value = RemoteConfigs().testKey

        // Assert
        XCTAssertEqual(value, "value")
    }

    func testRewriteValue() {
        // Act
        let value = RemoteConfigs().with(\.testKey, "value").testKey
        
        // Assert
        XCTAssertEqual(value, "value")
    }
    
    func testListen() {
        // Arrange
        var fetched = false
        RemoteConfigs().listen { _ in
            fetched = true
        }
        
        // Act
        self.handler.values = ["key": "value"]
        
        // Assert
        XCTAssertTrue(fetched)
    }
    
    func testDidFetch() async throws {
        // Arrange
        let remoteConfigs = RemoteConfigs()
        
        // Act
        let didFetch = remoteConfigs.didFetch
        
        // Assert
        XCTAssertFalse(didFetch)
        
        // Act
        self.handler.values = ["key": "value"]
        try await remoteConfigs.fetchIfNeeded()
        // Assert
        XCTAssertTrue(remoteConfigs.didFetch)
    }
    
    func testFetchIfNeeded() async throws {
        // Arrange
        let remoteConfigs = RemoteConfigs()
        
        // Act
        self.handler.values = ["key": "value"]
        let value = try await remoteConfigs.fetchIfNeeded(\.testKey)
        
        // Assert
        XCTAssertEqual(value, "value")
    }
}

private extension RemoteConfigs.Keys {

    var testKey: Key<String> {
        Key("key", default: "defaultValue")
    }
}
