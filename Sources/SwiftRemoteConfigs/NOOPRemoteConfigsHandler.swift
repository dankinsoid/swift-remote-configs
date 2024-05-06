import Foundation

public struct NOOPRemoteConfigsHandler: RemoteConfigsHandler {

    public var didLoad: Bool { true }
	public static let instance = NOOPRemoteConfigsHandler()

	public init() {
    }

    public func value(for key: String) -> CustomStringConvertible? {
        return nil
    }

    public func load(observe: @escaping () -> Void) -> () -> Void {
        observe()
        return {}
    }
}
