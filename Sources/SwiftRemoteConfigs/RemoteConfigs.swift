import Foundation

/// A structure for handling remote configs and reading them from a remote configs provider.
@dynamicMemberLookup
public struct RemoteConfigs {

	/// The remote configs handler responsible for querying and storing values.
	@usableFromInline
	var handler: RemoteConfigsHandler
    private var values: [String: Any] = [:]

	/// Initializes the `RemoteConfigs` instance with the default remote configs handler.
	public init() {
        self.init(handler: RemoteConfigsSystem.handler)
	}

    init(handler: RemoteConfigsHandler) {
        self.handler = handler
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<Value>>) -> Value {
        let key = Keys()[keyPath: keyPath]
        if let overwrittenValue = values[key.name] as? Value {
            return overwrittenValue
        }
        if let value = handler.value(for: key.name) {
            return (value as? Value) ?? key.decode(value.description) ?? key.defaultValue()
        }
        return key.defaultValue()
    }

    public var didLoad: Bool { handler.didLoad }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func load() async {
        let loader = Loader()
        let lock = ReadWriteLock()
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                lock.withWriterLock {
                    loader.completion = continuation.resume
                    loader.cancellation = handler.load { [weak loader] in
                        lock.withWriterLock {
                            loader?.complete()
                            loader?.cancel()
                        }
                    }
                }
            }
        } onCancel: {
            loader.cancel()
        }
    }

    @discardableResult
    public func observe(_ observer: @escaping (RemoteConfigs) -> Void) -> () -> Void {
        if didLoad {
            observer(self)
        }
        return handler.load {
            observer(self)
        }
    }

    public struct Keys {

        public init() {}

        public struct Key<Value> {

            public let name: String
            public let defaultValue: () -> Value
            public let decode: (String) -> Value?

            public init(
                _ key: String,
                decode: @escaping (String) -> Value?,
                default defaultValue: @escaping @autoclosure () -> Value
            ) {
                self.name = key
                self.decode = decode
                self.defaultValue = defaultValue
            }
        }
    }
}

public extension RemoteConfigs {

    /// Overwrites the value of a key.
    /// - Parameters:
    ///   - key: The key to overwrite.
    ///   - value: The value to set.
    func with<Value>(_ key: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<Value>>, _ value: Value?) -> Self {
        var copy = self
        copy.values[Keys()[keyPath: key].name] = value
        return copy
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func loadIfNeeded() async {
        guard !didLoad else { return }
        await load()
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func loadIfNeeded<T>(_ keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<T>>) async -> T {
        await loadIfNeeded()
        return self[dynamicMember: keyPath]
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func load<T>(_ keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<T>>) async -> T {
        await load()
        return self[dynamicMember: keyPath]
    }

    @discardableResult
    func observe<T>(_ keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<T>>, _ observer: @escaping (T) -> Void) -> () -> Void {
        observe {
            observer($0[dynamicMember: keyPath])
        }
    }
}

public extension RemoteConfigs.Keys.Key where Value: LosslessStringConvertible {

    /// Returns the key instance.
    ///
    /// - Parameters:
    ///   - key: The key string.
    ///   - default: The default value to use if the key is not found.
    @_disfavoredOverload
    init(
        _ key: String,
        default defaultValue: Value
    ) {
        self.init(key, decode: Value.init, default: defaultValue)
    }
}

public extension RemoteConfigs.Keys.Key where Value: RawRepresentable, Value.RawValue == String {

    /// Returns the key instance.
    ///
    /// - Parameters:
    ///   - key: The key string.
    ///   - default: The default value to use if the key is not found.
    init(
        _ key: String,
        default defaultValue: Value
    ) {
        self.init(key, decode: Value.init, default: defaultValue)
    }
}

private final class Loader {
    private var didCancelled = false
    private var didComplete = false
    var cancellation: () -> Void = {}
    var completion: () -> Void = {}
    
    func complete() {
        guard !didComplete else { return }
        didComplete = true
        completion()
        completion = {}
    }
    
    func cancel() {
        guard !didCancelled else { return }
        didCancelled = true
        cancellation()
        cancellation = {}
    }
}

#if compiler(>=5.6)
extension RemoteConfigs: @unchecked Sendable {}
extension RemoteConfigs.Keys: Sendable {}
extension RemoteConfigs.Keys.Key: @unchecked Sendable {}
#endif
