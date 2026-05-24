import Foundation

enum LoadingState<Value>: Equatable where Value: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(NetworkError)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var value: Value? {
        if case let .loaded(value) = self { return value }
        return nil
    }

    var error: NetworkError? {
        if case let .failed(error) = self { return error }
        return nil
    }
}

@MainActor
protocol LoadableViewModel: AnyObject {
    associatedtype Value: Equatable

    var loadState: LoadingState<Value> { get set }
}

extension LoadableViewModel {
    func performLoad(_ operation: () async throws -> Value) async {
        loadState = .loading

        do {
            let value = try await operation()
            loadState = .loaded(value)
        } catch {
            loadState = .failed(NetworkError.map(error))
        }
    }

    func resetLoadState() {
        loadState = .idle
    }
}
