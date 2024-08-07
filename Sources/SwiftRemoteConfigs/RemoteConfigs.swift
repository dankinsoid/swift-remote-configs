import Foundation

/// A structure for handling remote configs and reading them from a remote configs provider.
@dynamicMemberLookup
public struct RemoteConfigs {

	/// The remote configs handler responsible for querying and storing values.
    let handler: RemoteConfigsSystem.Handler
    private var values: [String: Any] = [:]

	/// Initializes the `RemoteConfigs` instance with the default remote configs handler.
	public init() {
        self.handler = RemoteConfigsSystem.handler
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

    public var didFetch: Bool { handler.didFetch }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func fetch() async throws {
        let loader = Loader()
        let lock = ReadWriteLock()
        _ = try await withCheckedThrowingContinuation { continuation in
            lock.withWriterLock {
                loader.completion = continuation.resume(returning:)
            }
            handler.fetch { [weak loader] error in
                lock.withWriterLock {
                    if let error = error {
                        loader?.complete(.failure(error))
                    } else {
                        loader?.complete(.success(()))
                    }
                }
            }
        }
    }

    public func listen(_ listener: @escaping (RemoteConfigs) -> Void) -> RemoteConfigsCancellation {
        handler.listen {
            listener(self)
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
    func fetchIfNeeded() async throws {
        guard !didFetch else { return }
        try await fetch()
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func fetchIfNeeded<T>(_ keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<T>>) async throws -> T {
        try await fetchIfNeeded()
        return self[dynamicMember: keyPath]
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func fetch<T>(_ keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<T>>) async throws -> T {
        try await fetch()
        return self[dynamicMember: keyPath]
    }

    @discardableResult
    func listen<T>(_ keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<T>>, _ observer: @escaping (T) -> Void) -> RemoteConfigsCancellation {
        listen {
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

public extension RemoteConfigs.Keys.Key where Value: Decodable {
    
    /// Returns the key instance.
    ///
    /// - Parameters:
    ///   - key: The key string.
    ///   - default: The default value to use if the key is not found.
    ///   - decoder: The JSON decoder to use for decoding the value.
    @_disfavoredOverload
    init(
        _ key: String,
        default defaultValue: Value,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.init(
            key,
            decode: { $0.data(using: .utf8).flatMap { try? decoder.decode(Value.self, from: $0) } },
            default: defaultValue
        )
    }
}

private final class Loader {

    private var didCancelled = false
    private var didComplete = false
    var cancellation: () -> Void = {}
    var completion: (Result<Void, Error>) -> Void = { _ in }

    func complete(_ result: Result<Void, Error>) {
        guard !didComplete else { return }
        didComplete = true
        completion(result)
        completion = { _ in }
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
