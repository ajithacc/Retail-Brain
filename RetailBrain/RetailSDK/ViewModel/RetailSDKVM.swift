//
//  RetailSDKVM.swift
//  RetailBrain
//
//  Created by ajith.a.s on 19/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Combine
import Foundation
import RetailBrainSDK

enum NavigationState {
    case home
    case map
}

final class RetailSDKViewModel: ObservableObject {

    // MARK: - Published UI State

    @Published var navigationState: NavigationState = .home
    @Published var showPermissionPopup = false
    @Published var showPermissionDeniedAlert = false
    @Published var isRequestingPermissions = false
    @Published var deniedPermissionMessage = ""
    @Published var showPermissionRevokedAlert = false
    @Published var revokedPermissionType = ""
    @Published var isPermissionRevokedOnMap = false
    @Published var selectedMode: MapNavigationMode = .singleFloor
    @Published var selectedProductDetails: AppProductDetails?
    @Published var vusionStatusText: String = "Not initialized"
    @Published var vusionAisle: String = "-"
    @Published var vusionModule: String = "-"
    @Published var vusionRSSI: String = "-"
    @Published var vusionDeviceId: String = "-"

    // MARK: - App-Specific UI State
    /// Map page UI state (search, floating menu, NFC overlay, shopping list)
    @Published var appSearchText: String = ""
    @Published var appShowListSheet: Bool = false
    @Published var appFloatingMenuExpanded: Bool = false
    @Published var appShowNFCOverlay: Bool = false

    // MARK: - Dependencies

    let sdkManager: RetailBrainManager

    // MARK: - Internal State

    private var activeMapConfiguration: MapConfiguration?

    // MARK: - Initialization

    init(sdkManager: RetailBrainManager = RetailBrainManager()) {
        self.sdkManager = sdkManager
        self.sdkManager.delegate = self
    }

    // MARK: - Flow Entry (Home -> SDK)

    /// Step 1: Entry point from Home screen.
    /// Loads app data, configures SDK, and decides permission flow.
    func startShopping() {
        guard prepareBackendDrivenData() else {
            deniedPermissionMessage = "Unable to load map and product data."
            showPermissionDeniedAlert = true
            return
        }

        guard initializeSDK() else {
            return
        }

        showPermissionDeniedAlert = false
        showPermissionPopup = false
        handlePermissionStateForStartShopping()
    }

    /// Step 2: User accepts the permission popup.
    func acceptPermissions() {
        isRequestingPermissions = true

        sdkManager.requestRequiredPermissions { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                self.showPermissionPopup = false
                self.isRequestingPermissions = false

                if granted {
                    self.navigateToMapAndStartNavigation()
                }
            }
        }
    }

    /// Step 2b: User dismisses permission popup.
    func declinePermissions() {
        showPermissionPopup = false
        isRequestingPermissions = false
    }

    /// Dismisses denied-permission alert.
    func dismissPermissionDeniedAlert() {
        showPermissionDeniedAlert = false
    }

    // MARK: - Map Screen Actions

    /// Provides SDK map view configured from active app configuration.
    func makeMapView() -> RetailMapView {
        sdkManager.getMapView(
            mapId: activeMapConfiguration?.mapId,
            isMultiFloorMode: activeMapConfiguration?.isMultiFloor ?? selectedMode.isMultiFloorEnabled
        )
    }

    /// Clears current route/navigation overlays.
    func clearNavigation() {
        sdkManager.clearNavigation()
    }

    /// Opens app settings for permission recovery.
    func openSettings() {
        sdkManager.openAppSettings()
    }

    /// Re-syncs map interaction state when app returns from background/settings.
    func refreshPermissionStateAfterForeground() {
        switch sdkManager.currentPermissionState() {
        case .allGranted:
            isPermissionRevokedOnMap = false
            showPermissionRevokedAlert = false
            showPermissionDeniedAlert = false
            sdkManager.syncPermissionMonitoringWithCurrentState()

        case .needsRequest:
            isPermissionRevokedOnMap = false
            showPermissionRevokedAlert = false

        case .deniedPermanently(let deniedTypes):
            applyRevokedPermissionState(deniedTypes)

        @unknown default:
            break
        }
    }

    // MARK: - Private Flow Helpers

    /// Loads backend-like map/product data and maps app models to SDK models.
    private func prepareBackendDrivenData() -> Bool {
        guard let mapConfiguration = MapConfigurationRepository.shared.configuration(for: selectedMode) else {
            return false
        }

        activeMapConfiguration = mapConfiguration

        let floor: ProductFloor = mapConfiguration.isMultiFloor ? .multiFloor : .singleFloor
        let appProducts = ProductDataRepository.shared.items(for: floor)
        guard !appProducts.isEmpty else {
            return false
        }

        let sdkProducts = appProducts.map {
            ShoppingItem(name: $0.name, storeName: $0.storeName, description: $0.description)
        }

        // SDK auto-routes first 5 products when startNavigation() is called.
        sdkManager.setProducts(sdkProducts)
        return true
    }

    /// Creates SDK config from app config and initializes manager.
    @discardableResult
    private func initializeSDK() -> Bool {
        guard let activeMapConfiguration else {
            deniedPermissionMessage = "Map configuration is unavailable."
            showPermissionDeniedAlert = true
            return false
        }

        let sdkConfig = RetailBrainConfig(
            apiKey: activeMapConfiguration.apiKey,
            apiSecret: activeMapConfiguration.apiSecret,
            mapId: activeMapConfiguration.mapId
        )

        sdkManager.configureMap(sdkConfig)
        sdkManager.initializeSDK()
        return true
    }

    /// Decides the next UI action based on current permission state.
    private func handlePermissionStateForStartShopping() {
        switch sdkManager.currentPermissionState() {
        case .allGranted:
            navigateToMapAndStartNavigation()

        case .needsRequest:
            showPermissionPopup = true

        case .deniedPermanently(let deniedTypes):
            setDeniedPermissionMessage(for: deniedTypes)
            showPermissionDeniedAlert = true

        @unknown default:
            showPermissionPopup = true
        }
    }

    /// Common success path after permissions are available.
    private func navigateToMapAndStartNavigation() {
        isPermissionRevokedOnMap = false
        sdkManager.startNavigation()
        navigationState = .map
    }

    /// Sets user-facing denied-permission message and type label.
    private func setDeniedPermissionMessage(for deniedTypes: [RetailBrainPermissionType]) {
        let locationDenied = deniedTypes.contains(.location)
        let bluetoothDenied = deniedTypes.contains(.bluetooth)

        if locationDenied && bluetoothDenied {
            deniedPermissionMessage = "Location and Bluetooth permissions are required to continue. Please enable both permissions in Settings."
            revokedPermissionType = "Location & Bluetooth"
        } else if locationDenied {
            deniedPermissionMessage = "Location permission is required to continue. Please enable it in Settings."
            revokedPermissionType = "Location"
        } else {
            deniedPermissionMessage = "Bluetooth permission is required to continue. Please enable it in Settings."
            revokedPermissionType = "Bluetooth"
        }
    }

    /// Applies revoked-permission state for map screen overlay/alerts.
    private func applyRevokedPermissionState(_ deniedTypes: [RetailBrainPermissionType]) {
        isPermissionRevokedOnMap = true

        if deniedTypes.contains(.location) && deniedTypes.contains(.bluetooth) {
            revokedPermissionType = "Location & Bluetooth"
        } else if deniedTypes.contains(.location) {
            revokedPermissionType = "Location"
        } else {
            revokedPermissionType = "Bluetooth"
        }

        showPermissionRevokedAlert = true
    }

    /// Converts SDK marker payload into app-owned details model for the UI.
    private func mapToAppProductDetails(_ product: StoreDetails) -> AppProductDetails {
        AppProductDetails(
            name: product.name,
            imageName: product.imageName,
            locationName: product.locationName,
            spaceId: product.spaceId,
            coordinates: product.coordinates
        )
    }

}

// MARK: - RetailBrainManagerDelegate

extension RetailSDKViewModel: RetailBrainManagerDelegate {

    /// Receives all SDK events through unified manager delegate.
    func retailBrainManager(_ manager: RetailBrainManager, didReceive event: RetailBrainEvent) {
        switch event {
        case .sdkInitialized:
            print("App Event: SDK initialized")

        case .sdkInitializationFailed(let error):
            deniedPermissionMessage = error.localizedDescription
            showPermissionDeniedAlert = true

        case .mapLoaded:
            print("App Event: Map loaded")

        case .mapLoadFailed(let error):
            deniedPermissionMessage = error.localizedDescription
            showPermissionDeniedAlert = true

        case .didTapProductPointer(let product):
            selectedProductDetails = mapToAppProductDetails(product)

        case .vusionInitialized:
            vusionStatusText = "Initialized"

        case .vusionInitializationFailed(let error):
            vusionStatusText = "Failed: \(error.localizedDescription)"

        case .vusionStatusUpdated(let status):
            switch status.status {
            case .initializing:
                vusionStatusText = "Initializing"
            case .initialized:
                vusionStatusText = "Initialized"
            case .trackingLocationUpdates:
                vusionStatusText = "Beaconing started"
            case .error(let message):
                vusionStatusText = "Failed: \(message)"
            @unknown default:
                vusionStatusText = "Updating"
            }

        case .indoorLocationUpdated(let update):
            vusionAisle = update.aisleName
            vusionModule = update.modularName
            vusionRSSI = "\(update.rssi)"
            vusionDeviceId = update.deviceId

        case .permissionGranted:
            break

        case .permissionDenied(let type, _):
            isPermissionRevokedOnMap = true
            revokedPermissionType = type == .location ? "Location" : "Bluetooth"
            deniedPermissionMessage = "\(revokedPermissionType) permission is required to continue."
            showPermissionDeniedAlert = true
            showPermissionRevokedAlert = true
            clearNavigation()

        case .openSettingsRequired(let type):
            revokedPermissionType = type == .location ? "Location" : "Bluetooth"

        case .generalError(let error):
            deniedPermissionMessage = error.localizedDescription
            showPermissionDeniedAlert = true

        default:
            break
        }
    }
}

// Keep existing app references unchanged.
typealias MapViewModel = RetailSDKViewModel
