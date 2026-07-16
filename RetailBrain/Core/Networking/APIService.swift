//
//  APIService.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 14/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

protocol APIService {
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
    func request(_ endpoint: Endpoint) async throws
}

extension APIService {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try await request(endpoint, as: T.self)
    }
}

nonisolated final class DefaultAPIService: APIService {

    private let client: HTTPClient
    private let decoder: JSONDecoder
    private let acceptableStatusCodes: Range<Int> = 200..<300

    init(client: HTTPClient = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.client = client
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        let data = try await performRequest(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(underlying: error.localizedDescription)
        }
    }

    func request(_ endpoint: Endpoint) async throws {
        _ = try await performRequest(endpoint)
    }

    private func performRequest(_ endpoint: Endpoint) async throws -> Data {
        let request = try await endpoint.makeURLRequest()
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await client.data(for: request)
        } catch {
            throw APIError.requestFailed(underlying: error.localizedDescription)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
            throw APIError.unacceptableStatusCode(httpResponse.statusCode, data: data)
        }
        return data
    }
}
