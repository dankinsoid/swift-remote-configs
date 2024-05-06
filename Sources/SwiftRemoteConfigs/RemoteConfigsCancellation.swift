import Foundation

public struct RemoteConfigsCancellation {

    private let _cancel: () -> Void

    public init(_ cancel: @escaping () -> Void) {
        _cancel = cancel
    }

    public func cancel() {
        _cancel()
    }
}
