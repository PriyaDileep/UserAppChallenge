// UsersAPIClient.swift

import Foundation

struct UsersAPIClient {
    func fetchUsers() async throws -> [User] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode([User].self, from: data)
        return response
    }
}
