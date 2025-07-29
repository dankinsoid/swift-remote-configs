import Foundation

@available(*, deprecated, renamed: "ConfigsHandler")
public typealias RemoteConfigsHandler = ConfigsHandler

/// An `ConfigsHandler` is an implementation of configs backend.
///
/// This type is an implementation detail and should not normally be used, unless implementing your own configs backend.
/// To use the SwiftRemoteConfigs API, please refer to the documentation of ``Configs``.
public protocol ConfigsHandler: _SwiftConfigsSendableAnalyticsHandler {

    func fetch(completion: @escaping (Error?) -> Void)
    func listen(_ listener: @escaping () -> Void) -> ConfigsCancellation?
    func value(for key: String) -> String?
	func writeValue(_ value: String?, for key: String) throws
	func clear() throws
	func allKeys() -> Set<String>?
}

extension ConfigsHandler {

	public func allKeys() -> Set<String>? {
		nil
	}

	public func writeValue(_ value: String?, for key: String) throws {
		throw Unsupported()
	}

	public func clear() throws {
		throw Unsupported()
	}
}

struct Unsupported: Error {
}

// MARK: - Sendable support helpers

#if compiler(>=5.6)
@preconcurrency public protocol _SwiftConfigsSendableAnalyticsHandler: Sendable {}
#else
public protocol _SwiftConfigsSendableAnalyticsHandler {}
#endif
