//
//  UserDTO.swift
//  UserApp
//
//  Created by Priyanka on 8/11/2026.
//

nonisolated struct UserDTO: Decodable, Sendable {
    struct CompanyDTO: Decodable, Sendable {
        let name: String
    }
    let id: Int
    let name: String
    let email: String
    
    let company: CompanyDTO
}
