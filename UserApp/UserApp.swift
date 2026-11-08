//
//  UserApp.swift
//  UserApp
//

import SwiftUI

@main
struct UserApp: App {
    
    private let userRepository: any UsersRepository = DefaultUserRepository(client: URLSessionHTTPClient(session: .shared))
    
    var body: some Scene {
        WindowGroup {
            UsersListView(viewModel: UsersViewModel(repository: userRepository))
        }
    }
}
