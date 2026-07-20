//
//  RetailSDKModel.swift
//  RetailBrain
//
//  Created by ajith.a.s on 19/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

enum ProductFloor: String, Codable {
    case singleFloor
    case multiFloor
}

struct AppShoppingItem: Codable, Hashable {
    let name: String
    let storeName: String
    let description: String?
}

struct AppProductDetails: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let locationName: String
    let spaceId: String?
    let coordinates: (Double, Double)?
}

struct ProductResponse: Codable {
    let products: [ProductAPIModel]
}

struct ProductAPIModel: Codable {
    let name: String
    let storeName: String
    let description: String?
    let floor: ProductFloor

    func asAppShoppingItem() -> AppShoppingItem {
        AppShoppingItem(name: name, storeName: storeName, description: description)
    }
}

final class ProductDataRepository {
    static let shared = ProductDataRepository()

    private var cachedResponse: ProductResponse?

    private init() {}

    func items(for floor: ProductFloor) -> [AppShoppingItem] {
        guard let response = loadProducts() else { return [] }
        return response.products
            .filter { $0.floor == floor }
            .map { $0.asAppShoppingItem() }
    }

    private func loadProducts() -> ProductResponse? {
        if let cachedResponse {
            return cachedResponse
        }

        let data: Data
        if let url = Bundle.main.url(forResource: "ProductData", withExtension: "json"),
           let bundledData = try? Data(contentsOf: url) {
            data = bundledData
        } else {
            data = Data(Self.mockJSON.utf8)
        }

        do {
            let response = try JSONDecoder().decode(ProductResponse.self, from: data)
            cachedResponse = response
            return response
        } catch {
            print("[ProductDataRepository] JSON decode failed: \(error.localizedDescription)")
            return nil
        }
    }

    private static let mockJSON = """
    {
      "products": [
        {"name":"Washroom","storeName":"Washroom","description":"Restrooms and facilities","floor":"singleFloor"},
        {"name":"Butcher","storeName":"Butcher","description":"Fresh meat and butcher products","floor":"singleFloor"},
        {"name":"Seafood","storeName":"Seafood","description":"Fresh seafood section","floor":"singleFloor"},
        {"name":"Cafe","storeName":"Cafe","description":"Cafe and dining area","floor":"singleFloor"},
        {"name":"Milk","storeName":"Dairy","description":"Fresh milk and dairy products","floor":"singleFloor"},
        {"name":"Cake","storeName":"Bakery","description":"Fresh baked cakes and pastries","floor":"singleFloor"},
        {"name":"Biscuits","storeName":"Bakery","description":"Cookies and biscuits","floor":"singleFloor"},
        {"name":"Popcorn","storeName":"Snacks","description":"Popcorn and snacks","floor":"singleFloor"},
        {"name":"Chips","storeName":"Snacks","description":"Chips and crisps","floor":"singleFloor"},
        {"name":"Tomato Paste","storeName":"Pantry","description":"Tomato paste and sauces","floor":"singleFloor"},
        {"name":"Olive Oil","storeName":"Pantry","description":"Olive oil and cooking oils","floor":"singleFloor"},
        {"name":"Flour","storeName":"Pantry","description":"Flour and baking supplies","floor":"singleFloor"},
        {"name":"Sugar","storeName":"Pantry","description":"Sugar and sweeteners","floor":"singleFloor"},
        {"name":"Jam","storeName":"Pantry","description":"Jams and preserves","floor":"singleFloor"},
        {"name":"Bulgur","storeName":"Pantry","description":"Bulgur and grains","floor":"singleFloor"},
        {"name":"Oatmeal","storeName":"Pantry","description":"Oatmeal and cereals","floor":"singleFloor"},
        {"name":"Bleach","storeName":"Household","description":"Cleaning supplies","floor":"singleFloor"},
        {"name":"Mop","storeName":"Household","description":"Cleaning tools","floor":"singleFloor"},
        {"name":"Lotion","storeName":"Health and Beauty","description":"Lotions and skincare","floor":"singleFloor"},
        {"name":"Parking","storeName":"Parking","description":"Parking area","floor":"singleFloor"},

        {"name":"Apple Store","storeName":"Apple Store","description":"Latest Apple devices and accessories","floor":"multiFloor"},
        {"name":"Nike","storeName":"Nike","description":"Sportswear and footwear","floor":"multiFloor"},
        {"name":"Adidas","storeName":"Adidas","description":"Athletic apparel and shoes","floor":"multiFloor"},
        {"name":"Zara","storeName":"Zara","description":"Fashion clothing","floor":"multiFloor"},
        {"name":"H&M","storeName":"H&M","description":"Casual fashion and accessories","floor":"multiFloor"},
        {"name":"Levis","storeName":"Levis","description":"Denim and casual wear","floor":"multiFloor"},
        {"name":"Puma","storeName":"Puma","description":"Sports apparel and shoes","floor":"multiFloor"},
        {"name":"Sephora","storeName":"Sephora","description":"Beauty and cosmetics","floor":"multiFloor"},
        {"name":"MAC Cosmetics","storeName":"MAC","description":"Professional makeup products","floor":"multiFloor"},
        {"name":"Starbucks","storeName":"Starbucks","description":"Coffee and beverages","floor":"multiFloor"},
        {"name":"McDonalds","storeName":"McDonalds","description":"Fast food restaurant","floor":"multiFloor"},
        {"name":"KFC","storeName":"KFC","description":"Fried chicken restaurant","floor":"multiFloor"},
        {"name":"Subway","storeName":"Subway","description":"Sandwiches and salads","floor":"multiFloor"},
        {"name":"Pizza Hut","storeName":"Pizza Hut","description":"Pizza and pasta","floor":"multiFloor"},
        {"name":"Book Store","storeName":"Book World","description":"Books and stationery","floor":"multiFloor"},
        {"name":"Toys Store","storeName":"Toy Planet","description":"Kids toys and games","floor":"multiFloor"},
        {"name":"Kids Zone","storeName":"Kids Zone","description":"Indoor play area","floor":"multiFloor"},
        {"name":"Cinema","storeName":"Multiplex","description":"Movie theatre","floor":"multiFloor"},
        {"name":"Gaming Zone","storeName":"Game Arena","description":"Arcade and VR games","floor":"multiFloor"},
        {"name":"ATM","storeName":"Bank ATM","description":"Cash withdrawal","floor":"multiFloor"},
        {"name":"Information Desk","storeName":"Information","description":"Customer assistance","floor":"multiFloor"},
        {"name":"Washroom","storeName":"Washroom","description":"Restrooms and facilities","floor":"multiFloor"},
        {"name":"Escalator","storeName":"Escalator","description":"Access to upper floors","floor":"multiFloor"},
        {"name":"Parking","storeName":"Parking","description":"Parking area","floor":"multiFloor"}
      ]
    }
    """
}

struct StoreLocations {
    static func shoppingItems(for mode: MapNavigationMode) -> [AppShoppingItem] {
        let floor: ProductFloor = mode == .singleFloor ? .singleFloor : .multiFloor
        return ProductDataRepository.shared.items(for: floor)
    }
}
