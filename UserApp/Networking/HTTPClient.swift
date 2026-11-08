//
//  HTTPClient.swift
//  UserApp
//
//  Created by Priyanka on 8/11/2026.
//

import Foundation

nonisolated protocol HTTPClient {
    func get<T: Decodable & Sendable>(_ endPoint: EndPoint) async throws -> T
}

nonisolated struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get<T: Decodable>(_ endPoint: EndPoint) async throws -> T {
       let (data, response) = try await session.data(from: endPoint.url)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
       
    }
}
