import Foundation

/// The `RemoteConfigsSystem` is a global facility where the default remote configs backend implementation (`RemoteConfigsHandler`) can be
/// configured. `RemoteConfigsSystem` is set up just once in a given program to set up the desired remote configs backend
/// implementation.
public enum RemoteConfigsSystem {

	private static let _handler = HandlerBox(NOOPRemoteConfigsHandler.instance)

	/// `bootstrap` is an one-time configuration function which globally selects the desired remote configs backend
	/// implementation. `bootstrap` can be called at maximum once in any given program, calling it more than once will
	/// lead to undefined behaviour, most likely a crash.
	///
	/// - parameters:
	///     - handler: The desired remote configs backend implementation.
	public static func bootstrap(_ handler: RemoteConfigsHandler) {
		_handler.replaceHandler(handler, validate: true)
	}

	/// for our testing we want to allow multiple bootstrapping
	static func bootstrapInternal(_ handler: RemoteConfigsHandler) {
		_handler.replaceHandler(handler, validate: false)
	}

	/// Returns a reference to the configured handler.
	static var handler: Handler {
		_handler.underlying
	}

	/// Acquire a writer lock for the duration of the given block.
	///
	/// - Parameter body: The block to execute while holding the lock.
	/// - Returns: The value returned by the block.
	public static func withWriterLock<T>(_ body: () throws -> T) rethrows -> T {
		try _handler.withWriterLock(body)
	}

	private final class HandlerBox {

		private let lock = ReadWriteLock()
		fileprivate var handler: Handler
		private var initialized = false

		init(_ underlying: RemoteConfigsHandler) {
            handler = Handler(underlying)
		}

		func replaceHandler(_ factory: RemoteConfigsHandler, validate: Bool) {
			withWriterLock {
				precondition(!validate || !self.initialized, "remote configs system can only be initialized once per process.")
				self.handler = Handler(factory)
				self.initialized = true
			}
		}

		var underlying: Handler {
			lock.withReaderLock {
                handler
			}
		}

		func withWriterLock<T>(_ body: () throws -> T) rethrows -> T {
			try lock.withWriterLock(body)
		}
	}

    final class Handler {
        var didFetch: Bool {
            lock.withReaderLock {
                _didFetch
            }
        }
        private let lock = ReadWriteLock()
        private var _didFetch = false
        private let handler: RemoteConfigsHandler
        private var observers: [UUID: () -> Void] = [:]
        private var didStartListen = false
        private var didStartFetch = false
        private var cancellation: RemoteConfigsCancellation?

        init(_ handler: RemoteConfigsHandler) {
            self.handler = handler
        }

        func fetch(completion: @escaping (Error?) -> Void) {
            handler.fetch { error in
                self.lock.withWriterLock {
                    if error == nil {
                        self._didFetch = true
                        self.observers.values.forEach { $0() }
                    }
                }
                completion(error)
            }
            lock.withWriterLock {
                didStartFetch = true
            }
        }

        func value(for key: String) -> CustomStringConvertible? {
            handler.value(for: key)
        }

        func listen(_ observer: @escaping () -> Void) -> RemoteConfigsCancellation {
            let didFetch = self.didFetch
            if !didFetch, !lock.withReaderLock({ didStartFetch }) {
                fetch { _ in }
            }
            defer {
                if didFetch {
                    observer()
                }
            }
            let id = UUID()
            lock.withWriterLockVoid {
                observers[id] = observer
                if !didStartListen {
                    didStartListen = true
                    cancellation = handler.listen { [weak self] in
                        self?.lock.withReaderLockVoid {
                            self?.observers.values.forEach { $0() }
                        }
                    }
                }
            }
            return RemoteConfigsCancellation { self.cancel(id: id) }
        }

        private func cancel(id: UUID) {
            lock.withWriterLockVoid {
                observers.removeValue(forKey: id)
                if observers.isEmpty {
                    cancellation?.cancel()
                    cancellation = nil
                    didStartListen = false
                }
            }
        }
    }
}

// MARK: - Sendable support helpers

#if compiler(>=5.6)
extension RemoteConfigsSystem: Sendable {}
#endif
