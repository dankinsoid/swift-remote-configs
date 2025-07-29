import XCTest

#if os(Linux) || os(FreeBSD) || os(Windows) || os(Android)
    @testable import SwiftRemoteConfigsTests

    XCTMain([
        testCase(SwiftRemoteConfigsTests.all),
    ])
#endif
