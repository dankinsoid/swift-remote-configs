import Foundation

/// The `RemoteConfigsSystem` is a global facility where the default remote configs backend implementation (`RemoteConfigsHandler`) can be
/// configured. `RemoteConfigsSystem` is set up just once in a given program to set up the desired remote configs backend
/// implementation.
public enum RemoteConfigsSystem {

	private static let _handler = HandlerBox { NOOPRemoteConfigsHandler.instance }

	/// `bootstrap` is an one-time configuration function which globally selects the desired remote configs backend
	/// implementation. `bootstrap` can be called at maximum once in any given program, calling it more than once will
	/// lead to undefined behaviour, most likely a crash.
	///
	/// - parameters:
	///     - handler: The desired remote configs backend implementation.
	public static func bootstrap(_ handler: @autoclosure @escaping () -> RemoteConfigsHandler) {
		_handler.replaceHandler(handler, validate: true)
	}

	/// for our testing we want to allow multiple bootstrapping
	static func bootstrapInternal(_ handler: @autoclosure @escaping () -> RemoteConfigsHandler) {
		_handler.replaceHandler(handler, validate: false)
	}

	/// Returns a reference to the configured handler.
	static var handler: RemoteConfigsHandler {
		_handler.underlying()
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
		fileprivate var _underlying: () -> RemoteConfigsHandler
		private var initialized = false

		init(_ underlying: @escaping () -> RemoteConfigsHandler) {
			_underlying = underlying
		}

		func replaceHandler(_ factory: @escaping () -> RemoteConfigsHandler, validate: Bool) {
			withWriterLock {
				precondition(!validate || !self.initialized, "remote configs system can only be initialized once per process.")
				self._underlying = factory
				self.initialized = true
			}
		}

		var underlying: () -> RemoteConfigsHandler {
			lock.withReaderLock {
				self._underlying
			}
		}

		func withWriterLock<T>(_ body: () throws -> T) rethrows -> T {
			try lock.withWriterLock(body)
		}
	}
}

// MARK: - Sendable support helpers

#if compiler(>=5.6)
extension RemoteConfigsSystem: Sendable {}
#endif
