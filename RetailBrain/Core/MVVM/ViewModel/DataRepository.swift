//
//  DataRepository.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 14/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

protocol RetailBrainRepository: AnyObject {
    func fetchStores() async throws -> [StoreData]
}

final class DataRepository: RetailBrainRepository {

    private let apiService: APIService

    init(apiService: APIService = DefaultAPIService()) {
        self.apiService = apiService
    }

    func fetchStores() async throws -> [StoreData] {
        let store = try await apiService.request(APIClient.fetchStores, as: Store.self)
        return store.data ?? []
    }

}
