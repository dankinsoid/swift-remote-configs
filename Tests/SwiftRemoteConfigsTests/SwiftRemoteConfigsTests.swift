@testable import SwiftRemoteConfigs
import XCTest

final class SwiftRemoteConfigsTests: XCTestCase {

    static var allTests = [
        ("testReadDefaultValue", testReadDefaultValue),
        ("testReadValue", testReadValue),
        ("testRewriteValue", testRewriteValue),
        ("testObserve", testObserve),
        ("testDidLoad", testDidLoad),
        ("testLoadIfNeeded", testLoadIfNeeded),
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
    
    func testObserve() {
        // Arrange
        var loaded = false
        RemoteConfigs().observe { _ in
            loaded = true
        }
        
        // Act
        self.handler.values = ["key": "value"]
        
        // Assert
        XCTAssertTrue(loaded)
    }
    
    func testDidLoad() async {
        // Arrange
        let remoteConfigs = RemoteConfigs()
        
        // Act
        let didLoad = remoteConfigs.didLoad
        
        // Assert
        XCTAssertFalse(didLoad)
        
        // Act
        self.handler.values = ["key": "value"]
        await remoteConfigs.loadIfNeeded()
        // Assert
        XCTAssertTrue(remoteConfigs.didLoad)
    }
    
    func testLoadIfNeeded() async {
        // Arrange
        let remoteConfigs = RemoteConfigs()
        
        // Act
        self.handler.values = ["key": "value"]
        let value = await remoteConfigs.loadIfNeeded(\.testKey)
        
        // Assert
        XCTAssertEqual(value, "value")
    }
}

private extension RemoteConfigs.Keys {

    var testKey: Key<String> {
        Key("key", default: "defaultValue")
    }
}
