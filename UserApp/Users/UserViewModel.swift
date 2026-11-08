// UsersViewModel.swift

// UsersViewModel.swift

import Foundation
import Observation

enum UsersState: Equatable {
    case idle
    case loading
    case loaded([User])
    case failed(message: String)
}

@MainActor
@Observable
final class UsersViewModel {
    private(set) var state: UsersState = .idle

    private let repository: any UsersRepository

    init(repository: any UsersRepository) {
        self.repository = repository
    }

    var isLoading: Bool {
        state == .loading
    }

    func load() async {
        guard !isLoading else { return }

        let previousState = state
        state = .loading

        do {
            state = .loaded(try await repository.fetchUsers())
        } catch {
            state = Task.isCancelled ? previousState : .failed(message: Self.message(for: error))
        }
    }

    private static func message(for error: any Error) -> String {
        if let urlError = error as? URLError,
           urlError.code == .notConnectedToInternet {
            String(localized: "You appear to be offline. Check your connection and try again.")
        } else {
            String(localized: "We couldn't load users. Please try again.")
        }
    }
}
