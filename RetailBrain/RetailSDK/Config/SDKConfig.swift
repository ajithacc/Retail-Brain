//
//  SDKConfig.swift
//  RetailBrain
//
//  Created by ajith.a.s on 19/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

enum MapNavigationMode: String, CaseIterable, Codable {
    case singleFloor
    case multiFloor

    var title: String {
        switch self {
        case .singleFloor:
            return "Single Floor"
        case .multiFloor:
            return "Multi Floor"
        }
    }

    var isMultiFloorEnabled: Bool {
        self == .multiFloor
    }
}

struct MapConfigurationResponse: Codable {
    let configurations: [MapConfiguration]
}

struct MapConfiguration: Codable {
    let mode: MapNavigationMode
    let venueId: String
    let mapId: String
    let defaultFloor: String
    let buildingId: String
    let storeId: String
    let apiKey: String
    let apiSecret: String
    let isMultiFloor: Bool
}

final class MapConfigurationRepository {
    static let shared = MapConfigurationRepository()

    private var cachedResponse: MapConfigurationResponse?

    private init() {}

    func configuration(for mode: MapNavigationMode) -> MapConfiguration? {
        guard let response = loadConfigurationResponse() else { return nil }
        return response.configurations.first { $0.mode == mode }
    }

    private func loadConfigurationResponse() -> MapConfigurationResponse? {
        if let cachedResponse {
            return cachedResponse
        }

        let data: Data
        if let url = Bundle.main.url(forResource: "mapConfig", withExtension: "json"),
           let bundledData = try? Data(contentsOf: url) {
            data = bundledData
        } else {
            data = Data(Self.fallbackJSON.utf8)
        }

        do {
            let decoded = try JSONDecoder().decode(MapConfigurationResponse.self, from: data)
            cachedResponse = decoded
            return decoded
        } catch {
            print("[MapConfigurationRepository] JSON decode failed: \(error.localizedDescription)")
            return nil
        }
    }

    private static let fallbackJSON = """
    {
      "configurations": [
        {
          "mode": "singleFloor",
          "venueId": "venue-single-001",
          "mapId": "6679882a8298d5000b85ee89",
          "defaultFloor": "L1",
          "buildingId": "building-01",
          "storeId": "store-single-001",
          "apiKey": "mik_yeBk0Vf0nNJtpesfu560e07e5",
          "apiSecret": "mis_2g9ST8ZcSFb5R9fPnsvYhrX3RyRwPtDGbMGweCYKEq385431022",
          "isMultiFloor": false
        },
        {
          "mode": "multiFloor",
          "venueId": "venue-multi-001",
          "mapId": "mappedin-demo-mall",
          "defaultFloor": "M1",
          "buildingId": "building-02",
          "storeId": "store-multi-001",
          "apiKey": "5eab30aa91b055001a68e996",
          "apiSecret": "RJyRXKcryCMy4erZqqCbuB1NbR66QTGNXVE0x3Pg6oCIlUR1",
          "isMultiFloor": true
        }
      ]
    }
    """
}
