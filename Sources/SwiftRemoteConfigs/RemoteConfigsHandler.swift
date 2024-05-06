import Foundation

/// An `RemoteConfigsHandler` is an implementation of a remote configs backend.
///
/// This type is an implementation detail and should not normally be used, unless implementing your own remote configs backend.
/// To use the SwiftRemoteConfigs API, please refer to the documentation of ``RemoteConfigs``.
///
public protocol RemoteConfigsHandler: _SwiftRemoteConfigsSendableAnalyticsHandler {

    var didLoad: Bool { get }
    func load(observe: @escaping () -> Void) -> () -> Void
    func value(for key: String) -> CustomStringConvertible?
}

// MARK: - Sendable support helpers

#if compiler(>=5.6)
@preconcurrency public protocol _SwiftRemoteConfigsSendableAnalyticsHandler: Sendable {}
#else
public protocol _SwiftRemoteConfigsSendableAnalyticsHandler {}
#endif
