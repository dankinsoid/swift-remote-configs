import Foundation

/// A ConfigsHandler implementation backed by UserDefaults
public final class UserDefaultsConfigsHandler: ConfigsHandler {
    private let userDefaults: UserDefaults
    private let keyPrefix: String
    private var observers: [UUID: () -> Void] = [:]
    private let lock = ReadWriteLock()
    private var notificationObserver: NSObjectProtocol?

    /// Initialize with custom UserDefaults and optional key prefix
    /// - Parameters:
    ///   - userDefaults: The UserDefaults instance to use (defaults to .standard)
    ///   - keyPrefix: Optional prefix for all keys to avoid conflicts
    public init(userDefaults: UserDefaults = .standard, keyPrefix: String = "") {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix

        setupNotificationObserver()
    }

    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupNotificationObserver() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: userDefaults,
            queue: .main
        ) { [weak self] _ in
            self?.notifyObservers()
        }
    }

    private func notifyObservers() {
        let currentObservers = lock.withReaderLock { Array(observers.values) }
        currentObservers.forEach { $0() }
    }

    private func prefixedKey(_ key: String) -> String {
        keyPrefix.isEmpty ? key : "\(keyPrefix)\(key)"
    }

    // MARK: - ConfigsHandler Implementation

    public func fetch(completion: @escaping (Error?) -> Void) {
        // UserDefaults is synchronous and always available
        completion(nil)
    }

    public func listen(_ listener: @escaping () -> Void) -> ConfigsCancellation? {
        let id = UUID()
        lock.withWriterLockVoid {
            observers[id] = listener
        }

        return ConfigsCancellation { [weak self] in
            self?.lock.withWriterLockVoid {
                self?.observers.removeValue(forKey: id)
            }
        }
    }

    public func value(for key: String) -> String? {
        let prefixedKey = prefixedKey(key)
        return userDefaults.string(forKey: prefixedKey)
    }

    public func writeValue(_ value: String?, for key: String) throws {
        let prefixedKey = prefixedKey(key)

        if let value = value {
            userDefaults.set(value, forKey: prefixedKey)
        } else {
            userDefaults.removeObject(forKey: prefixedKey)
        }
    }

    public func clear() throws {
        let keys = allKeys() ?? Set()
        for key in keys {
            let prefixedKey = prefixedKey(key)
            userDefaults.removeObject(forKey: prefixedKey)
        }
    }

    public func allKeys() -> Set<String>? {
        let allUserDefaultsKeys = Set(userDefaults.dictionaryRepresentation().keys)

        if keyPrefix.isEmpty {
            return allUserDefaultsKeys
        } else {
            return Set(allUserDefaultsKeys
                .filter { $0.hasPrefix(keyPrefix) }
                .map { String($0.dropFirst(keyPrefix.count)) })
        }
    }
}
