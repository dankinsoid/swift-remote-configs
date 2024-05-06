import Foundation

/// Mock RemoteConfigsHandler for testing
public final class MockRemoteConfigsHandler: RemoteConfigsHandler {

    public var didLoad: Bool {
        lock.withReaderLock { _didLoad }
    }
    public var values: [String: CustomStringConvertible] {
        get {
            lock.withReaderLock { _values }
        }
        set {
            lock.withWriterLockVoid {
                _didLoad = true
                _values = newValue
                observers.values.forEach { $0() }
            }
        }
    }
    private var _values: [String: CustomStringConvertible]
    private var _didLoad: Bool
    private var observers: [UUID: () -> Void] = [:]
    private let lock = ReadWriteLock()

    public init(_ values: [String: CustomStringConvertible] = [:]) {
        _values = values
        _didLoad = !values.isEmpty
    }

    public func value(for key: String) -> CustomStringConvertible? {
        values[key]
    }

    public func set<Value>(_ value: Value, for keyPath: KeyPath<RemoteConfigs.Keys, RemoteConfigs.Keys.Key<Value>>) where Value: CustomStringConvertible {
        values[RemoteConfigs.Keys()[keyPath: keyPath].name] = value
    }

    public func load(observe: @escaping () -> Void) -> () -> Void {
        let id = UUID()
        lock.withWriterLockVoid {
            observers[id] = observe
        }
        if didLoad {
            observe()
        }
        return { [weak self] in
            self?.lock.withWriterLockVoid {
                self?.observers.removeValue(forKey: id)
            }
        }
    }
}
