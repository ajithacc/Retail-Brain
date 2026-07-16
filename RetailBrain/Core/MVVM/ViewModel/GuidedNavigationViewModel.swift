//
//  GuidedNavigationViewModel.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 15/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation
import Combine
import RetailBrainSDK

final class GuidedNavigationViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var showListSheet: Bool = false
    @Published var floatingMenuExpanded: Bool = false
    @Published var showNFCOverlay: Bool = false

    init() {
        initializeSDK()
    }

    func initializeSDK() {
        RetailBrainManager.shared.delegate = self
        let configuration = RetailBrainConfig(
            apiKey: "5eab30aa91b055001a68e996",
            apiSecret: "RJyRXKcryCMy4erZqqCbuB1NbR66QTGNXVE0x3Pg6oCIlUR1",
            mapId: "mappedin-demo-mall"
        )
        RetailBrainManager.shared.initialize(config: configuration)
    }

}

// MARK: RETAIL BRAIN SDK DELEGATES
extension GuidedNavigationViewModel: RetailBrainSDKDelegate {

    func sdkDidInitialize() {
        print("App Callback: SDK initialized")
    }

    func sdkDidFailToInitialize(error: Error) {
        print("App Callback: SDK initialization failed - \(error.localizedDescription)")
    }

    func mapDidLoad() {
        print("App Callback: Map loaded")
    }

    func mapDidFailToLoad(error: Error) {
        print("App Callback: Map failed to load - \(error.localizedDescription)")
    }

    func addProductToMap() {
        print("App Callback: Product list added/updated")
    }

    func didSelectItem(_ item: StoreItem) {
        print("App Callback: Selected item - \(item.name) at \(item.locationName)")
    }

    func didDeselectItem(_ item: StoreItem) {
        print("App Callback: Deselected item - \(item.name) at \(item.locationName)")
    }

    func routeCalculationStarted() {
        print("App Callback: Route calculation started")
    }

    func didTapProductPointer(_ product: StoreDetails) {
        print("App Callback: Tapped product pointer - \(product.name) at \(product.locationName)")
    }

}
