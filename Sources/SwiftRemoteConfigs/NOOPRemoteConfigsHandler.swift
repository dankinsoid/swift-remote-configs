import Foundation

public struct NOOPRemoteConfigsHandler: RemoteConfigsHandler {

	public static let instance = NOOPRemoteConfigsHandler()

	public init() {
    }

    public func value(for key: String) -> String? {
        return nil
    }

    public func fetch(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }

    public func listen(_ listener: @escaping () -> Void) -> RemoteConfigsCancellation? {
        return nil
    }
}
