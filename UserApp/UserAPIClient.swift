// UsersAPIClient.swift

import Foundation

nonisolated protocol UsersServiceProtocol {
    func fetchUsers() async throws -> [User]
}

nonisolated struct UsersAPIClient: UsersServiceProtocol {
    func fetchUsers() async throws -> [User] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([User].self, from: data)
    }
}
