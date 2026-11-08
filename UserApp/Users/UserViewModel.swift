// UsersViewModel.swift

import Foundation
import Observation

enum UsersState {
    case idle
    case loading
    case loaded([User])
    case failed(Error)
}

@MainActor
@Observable
final class UsersViewModel {
    private(set) var state: UsersState = .idle

    private let repository: any UsersRepository

    init(repository: any UsersRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            let users = try await repository.fetchUsers()
            state = .loaded(users)
        } catch {
            state = .failed(error)
        }
    }
}
