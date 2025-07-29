import Foundation

@available(*, deprecated, renamed: "ConfigsHandler")
public typealias RemoteConfigsHandler = ConfigsHandler

/// An `ConfigsHandler` is an implementation of configs backend.
///
/// This type is an implementation detail and should not normally be used, unless implementing your own configs backend.
/// To use the SwiftRemoteConfigs API, please refer to the documentation of ``Configs``.
public protocol ConfigsHandler: _SwiftConfigsSendableAnalyticsHandler {
    /// Fetches the latest configuration values from the backend
    func fetch(completion: @escaping (Error?) -> Void)
    /// Registers a listener for configuration changes
    func listen(_ listener: @escaping () -> Void) -> ConfigsCancellation?
    /// Retrieves the value for a given key
    func value(for key: String) -> String?
    /// Writes a value for a given key
    func writeValue(_ value: String?, for key: String) throws
    /// Clears all stored configuration values
    func clear() throws
    /// Returns all available configuration keys
    func allKeys() -> Set<String>?
}

public extension ConfigsHandler {
    /// Default implementation returns nil
    func allKeys() -> Set<String>? {
        nil
    }

    /// Default implementation throws Unsupported error
    func writeValue(_: String?, for _: String) throws {
        throw Unsupported()
    }

    /// Default implementation throws Unsupported error
    func clear() throws {
        throw Unsupported()
    }
}

struct Unsupported: Error {}

// MARK: - Sendable support helpers

#if compiler(>=5.6)
    @preconcurrency public protocol _SwiftConfigsSendableAnalyticsHandler: Sendable {}
#else
    public protocol _SwiftConfigsSendableAnalyticsHandler {}
#endif
