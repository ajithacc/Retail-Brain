//
//  Store.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 14/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

struct Store: Codable {
    let data: [StoreData]?
}

struct StoreData: Codable {
    let storeName: String?
    let storeKey: String?
    let storeSecret: String?
    let storeId: String?
    let vusionBaseUrl: String?
    let vusionAPIKey: String?
}
