import Foundation

/// A pseudo-remote configs handler that can be used to send messages to multiple other remote configs handlers.
public struct MultiplexRemoteConfigsHandler: RemoteConfigsHandler {

	private let handlers: [MultiplexRemoteConfigsHandler]

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

    public func fetch(completion: @escaping (Error?) -> Void) {
        handlers.forEach { handler in
            handler.fetch { error in
                
            }
        }
    }

    public func listen(_ listener: @escaping () -> Void) -> RemoteConfigsCancellation? {
        let cancellables = handlers.compactMap { $0.listen(listener) }
        return cancellables.isEmpty ? nil : RemoteConfigsCancellation {
            cancellables.forEach { $0.cancel() }
        }
    }
}
