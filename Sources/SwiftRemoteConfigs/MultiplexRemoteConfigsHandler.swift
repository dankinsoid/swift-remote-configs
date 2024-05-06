import Foundation

/// A pseudo-remote configs handler that can be used to send messages to multiple other remote configs handlers.
public struct MultiplexRemoteConfigsHandler: RemoteConfigsHandler {

    public var didLoad: Bool { handlers.allSatisfy(\.didLoad) }
	private var handlers: [MultiplexRemoteConfigsHandler]

	public init(handlers: [MultiplexRemoteConfigsHandler]) {
		self.handlers = handlers
	}

    public func value(for key: String) -> CustomStringConvertible? {
        for handler in handlers {
            if let value = handler.value(for: key) {
                return value
            }
        }
        return nil
    }

    public func load(observe: @escaping () -> Void) -> () -> Void {
        let cancellables = handlers.map { $0.load(observe: observe) }
        return {
            cancellables.forEach { $0() }
        }
    }
}
