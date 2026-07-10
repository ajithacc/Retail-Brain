//
//  PermissionManaging.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 08/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

protocol PermissionService: AnyObject {
    /// `true` when both Location and Bluetooth permissions are granted.
    var areAllPermissionsGranted: Bool { get }
    /// `true` when Location permission is granted.
    var isLocationPermissionGranted: Bool { get }
    /// `true` when Bluetooth permission is granted.
    var isBluetoothPermissionGranted: Bool { get }
    /// `true` when Location permission was denied or restricted (cannot be re-prompted).
    var isLocationPermissionDenied: Bool { get }
    /// `true` when Bluetooth permission was denied or restricted (cannot be re-prompted).
    var isBluetoothPermissionDenied: Bool { get }
    /// Refreshes the cached Location and Bluetooth authorization statuses.
    func updatePermissionStatuses()
    /// Requests Location and Bluetooth permissions.
    func requestAllPermissions(completion: @escaping (_ locationGranted: Bool, _ bluetoothGranted: Bool) -> Void)
}
