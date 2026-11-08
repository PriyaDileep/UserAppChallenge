//
//  User.swift
//  UserApp
//
//  Created by Priyanka on 8/11/2026.
//

nonisolated struct User: Identifiable, Equatable, Sendable {
    let id : Int
   let name: String
    let email: String
    let companyName: String
}

nonisolated extension User {
    init(dto: UserDTO) {
        self.init(id: dto.id, name: dto.name, email: dto.email, companyName: dto.company.name)
    }
}
