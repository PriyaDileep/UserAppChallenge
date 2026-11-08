//
//  NetworkError.swift
//  UserApp
//
//  Created by Priyanka on 8/11/2026.
//

nonisolated enum NetworkError: Error, Equatable {
    case inavidResponse
    case badStatusCode(Int)
    case decodingFailed
}
