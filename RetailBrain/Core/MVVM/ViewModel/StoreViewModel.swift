//
//  StoreViewModel.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation
import Combine
import UIKit

final class StoreViewModel: ObservableObject {

    @Published var showPermissionAlert: Bool = false
    @Published var navigateToGuidedNavView: Bool = false
    @Published var stores: [StoreData] = []
    @Published var selectedStore: StoreData?

    private var hasFetchedStores = false

    private let permissionManager: PermissionService
    private let dataRepository: RetailBrainRepository

    init(
        permissionManager: PermissionService = PermissionManager(),
        dataRepository: RetailBrainRepository = DataRepository()
    ) {
        self.permissionManager = permissionManager
        self.dataRepository = dataRepository
    }

    func storeSelection() {
        print("TODO: Show available store list.")
    }

}

// MARK: PERMISSION HANDLING
extension StoreViewModel {

    func handleGuidedRouteTap() {
        permissionManager.updatePermissionStatuses()
        if permissionManager.areAllPermissionsGranted {
            allPermissionsApproved()
        } else {
            showPermissionAlert = true
        }
    }

    func dismissPermissionAlert() {
        showPermissionAlert = false
    }

    func acceptPermission() {
        permissionManager.updatePermissionStatuses()
        if permissionManager.isLocationPermissionDenied || permissionManager.isBluetoothPermissionDenied {
            openAppSettings()
            return
        }
        permissionManager.requestAllPermissions { [weak self] locationGranted, bluetoothGranted in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showPermissionAlert = false
                if locationGranted && bluetoothGranted {
                    self.allPermissionsApproved()
                } else {
                    self.openAppSettings()
                }
            }
        }
    }

    func allPermissionsApproved() {
        print("✅ All permissions approved, navigating to Guided Navigation View")
        navigateToGuidedNavView = true
    }

    func openAppSettings() {
        showPermissionAlert = false
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

}

// MARK: API
extension StoreViewModel {

    func fetchStores() async {
        guard !hasFetchedStores else { return }
        CustomLoader.show()
        defer {
            CustomLoader.hide()
        }
        do {
            stores = try await dataRepository.fetchStores()
            self.selectedStore = stores.first
            hasFetchedStores = true
        } catch {
            print("Error fetching stores: \(error)")
        }
    }

}
