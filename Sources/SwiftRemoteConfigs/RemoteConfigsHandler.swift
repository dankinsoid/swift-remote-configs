import Foundation

/// An `RemoteConfigsHandler` is an implementation of a remote configs backend.
///
/// This type is an implementation detail and should not normally be used, unless implementing your own remote configs backend.
/// To use the SwiftRemoteConfigs API, please refer to the documentation of ``RemoteConfigs``.
///
public protocol RemoteConfigsHandler: _SwiftRemoteConfigsSendableAnalyticsHandler {

    func fetch(completion: @escaping (Error?) -> Void)
    func listen(_ listener: @escaping () -> Void) -> RemoteConfigsCancellation?
    func value(for key: String) -> String?
}

// MARK: - Sendable support helpers

#if compiler(>=5.6)
@preconcurrency public protocol _SwiftRemoteConfigsSendableAnalyticsHandler: Sendable {}
#else
public protocol _SwiftRemoteConfigsSendableAnalyticsHandler {}
#endif
