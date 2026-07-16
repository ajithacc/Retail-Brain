//
//  HTTPMethod.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 14/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol HTTPClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClient {}
