//
//  EndPoint.swift
//  UserApp
//
//  Created by Priyanka on 8/11/2026.
//
import Foundation

nonisolated struct EndPoint {
    static let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
    
    let path: String
    var url: URL {
        Self.baseURL.appending(path: path)
    }
}

extension EndPoint {
    static let users = EndPoint(path: "users")
}
