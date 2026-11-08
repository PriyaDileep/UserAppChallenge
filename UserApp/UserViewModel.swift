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

    private let usersService: any UsersServiceProtocol

    init(usersService: any UsersServiceProtocol = UsersAPIClient()) {
        self.usersService = usersService
    }

    func load() async {
        state = .loading

        do {
            let users = try await usersService.fetchUsers()
            state = .loaded(users)
        } catch {
            state = .failed(error)
        }
    }
}
