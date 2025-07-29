import Foundation

@available(*, deprecated, renamed: "NOOPConfigsHandler")
public typealias NOOPRemoteConfigsHandler = NOOPConfigsHandler

public struct NOOPConfigsHandler: ConfigsHandler {

	public static let instance = NOOPConfigsHandler()

	public init() {
    }

    public func value(for key: String) -> String? {
        return nil
    }
	
	public func writeValue(_ value: String?, for key: String) throws {
	}
	
	public func clear() throws {
	}

    public func fetch(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }

    public func listen(_ listener: @escaping () -> Void) -> ConfigsCancellation? {
        return nil
    }
}
