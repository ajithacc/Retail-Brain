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
    @Published var showSettingsAlert: Bool = false
    @Published var settingsAlertMessage: String = ""
    @Published var navigateToGuidedNavView: Bool = false

    private let permissionManager: PermissionService

    init(permissionManager: PermissionService = PermissionManager()) {
        self.permissionManager = permissionManager
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
        } else if permissionManager.isLocationPermissionDenied || permissionManager.isBluetoothPermissionDenied {
            // A required permission was permanently denied, navigate user to phone settings
            presentSettingsAlert(
                locationGranted: permissionManager.isLocationPermissionGranted,
                bluetoothGranted: permissionManager.isBluetoothPermissionGranted
            )
        } else {
            showPermissionAlert = true
        }
    }

    func dismissPermissionAlert() {
        showPermissionAlert = false
    }

    func acceptPermission() {
        permissionManager.requestAllPermissions { [weak self] locationGranted, bluetoothGranted in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showPermissionAlert = false
                if locationGranted && bluetoothGranted {
                    self.allPermissionsApproved()
                } else {
                    self.presentSettingsAlert(
                        locationGranted: locationGranted,
                        bluetoothGranted: bluetoothGranted
                    )
                }
            }
        }
    }

    func allPermissionsApproved() {
        print("All permissions approved, navigating to Guided Navigation View")
        navigateToGuidedNavView = true
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    private func presentSettingsAlert(locationGranted: Bool, bluetoothGranted: Bool) {
        showPermissionAlert = false
        settingsAlertMessage = settingsMessage(locationGranted: locationGranted, bluetoothGranted: bluetoothGranted)
        showSettingsAlert = true
    }

    private func settingsMessage(locationGranted: Bool, bluetoothGranted: Bool) -> String {
        var missing: [String] = []
        if !locationGranted { missing.append("Localisation") }
        if !bluetoothGranted { missing.append("Bluetooth") }
        let permissions = missing.joined(separator: " et ")
        return "Vous avez refusé l’accès à \(permissions). Veuillez l’autoriser dans les Réglages pour utiliser l’itinéraire guidé."
    }

}
