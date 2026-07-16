//
//  APIClient.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 14/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

enum APIClient: Endpoint {
    case fetchStores

    var baseURL: String {
        "https://api.retailbrain.service.com"
    }

    var path: String {
        switch self {
        case .fetchStores:
            return "/api/v1/stores"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchStores:
            return .get
        }
    }

    var headers: [String: String] {
        ["Accept": "application/json"]
    }
}
