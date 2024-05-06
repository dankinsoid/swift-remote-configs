import Foundation

/// Mock RemoteConfigsHandler for testing
public final class MockRemoteConfigsHandler: RemoteConfigsHandler {

    public var values: [String: CustomStringConvertible] {
        get {
            lock.withReaderLock { _values }
        }
        set {
            lock.withWriterLockVoid {
                _values = newValue
                observers.values.forEach { $0() }
            }
        }
    }
    private var observers: [UUID: () -> Void] = [:]
    private var _values: [String: CustomStringConvertible]
    private let lock = ReadWriteLock()

    public init(_ values: [String: CustomStringConvertible] = [:]) {
        _values = values
    }

    public func value(for key: String) -> CustomStringConvertible? {
        values[key]
    }

    public func set<Value>(_ value: Value, for keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<Value>>) where Value: CustomStringConvertible {
        values[RemoteConfigs.Keys()[keyPath: keyPath].name] = value
    }

    public func fetch(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }

    public func listen(_ observer: @escaping () -> Void) -> RemoteConfigsCancellation? {
        let id = UUID()
        lock.withWriterLockVoid {
            observers[id] = observer
        }
        return RemoteConfigsCancellation { [weak self] in
            self?.lock.withWriterLockVoid {
                self?.observers.removeValue(forKey: id)
            }
        }
    }
}
