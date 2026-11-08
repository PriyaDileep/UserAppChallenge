//
//  UserRepository.swift
//  UserApp
//
//  Created by Priyanka on 8/11/2026.
//

nonisolated protocol UsersRepository: Sendable {
    func fetchUsers() async throws -> [User]
}

nonisolated struct DefaultUserRepository: UsersRepository {
    private let client: any HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    func fetchUsers() async throws -> [User] {
        let user: [UserDTO] = try await client.get(.users)
        return user.map(User.init(dto:))
    }
       
}
