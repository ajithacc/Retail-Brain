//
//  Endpoint.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 14/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

nonisolated protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
}

extension Endpoint {
    var headers: [String: String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? { nil }

    func makeURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        let basePath = components.path
        let combinedPath = (basePath + path).replacingOccurrences(of: "//", with: "/")
        components.path = combinedPath
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }
}

enum APIError: Error {
    case invalidURL
    case requestFailed(underlying: String)
    case invalidResponse
    case unacceptableStatusCode(Int, data: Data?)
    case decodingFailed(underlying: String)
    case encodingFailed(underlying: String)
}
