//
//  PermissionManager.swift
//  RetailBrainApp
//
//  Created by ajith.a.s on 30/06/26.
//  Copyright © 2026 Accenture. All rights reserved.

import CoreLocation
import CoreBluetooth

final class PermissionManager: NSObject, PermissionService {

    private let locationManager: LocationAuthorizing
    private let bluetoothAuthorizationProvider: () -> CBManagerAuthorization
    private let centralManagerFactory: (CBCentralManagerDelegate) -> CBCentralManager?
    private let simulatorEnvironment: Bool

    private(set) var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    private(set) var bluetoothPermissionStatus: CBManagerAuthorization = .notDetermined

    private var locationCompletion: ((Bool) -> Void)?
    private var bluetoothCompletion: ((Bool) -> Void)?
    private var centralManager: CBCentralManager?

    init(
        locationManager: LocationAuthorizing = CLLocationManager(),
        bluetoothAuthorizationProvider: @escaping () -> CBManagerAuthorization = { CBManager.authorization },
        centralManagerFactory: @escaping (CBCentralManagerDelegate) -> CBCentralManager? = { delegate in
            CBCentralManager(delegate: delegate, queue: .main)
        },
        simulatorEnvironment: Bool = PermissionManager.defaultSimulatorEnvironment
    ) {
        self.locationManager = locationManager
        self.bluetoothAuthorizationProvider = bluetoothAuthorizationProvider
        self.centralManagerFactory = centralManagerFactory
        self.simulatorEnvironment = simulatorEnvironment
        super.init()
        self.locationManager.locationDelegate = self
        updatePermissionStatuses()
    }

    func updatePermissionStatuses() {
        locationPermissionStatus = locationManager.currentAuthorizationStatus
        bluetoothPermissionStatus = bluetoothAuthorizationProvider()
    }

    var areAllPermissionsGranted: Bool {
        let locationGranted = locationPermissionStatus == .authorizedAlways || locationPermissionStatus == .authorizedWhenInUse
        let bluetoothGranted = bluetoothPermissionStatus == .allowedAlways
        return locationGranted && bluetoothGranted
    }

    var isLocationPermissionGranted: Bool {
        locationPermissionStatus == .authorizedAlways || locationPermissionStatus == .authorizedWhenInUse
    }

    var isBluetoothPermissionGranted: Bool {
        bluetoothPermissionStatus == .allowedAlways
    }

    var isLocationPermissionDenied: Bool {
        locationPermissionStatus == .denied || locationPermissionStatus == .restricted
    }

    var isBluetoothPermissionDenied: Bool {
        bluetoothPermissionStatus == .denied || bluetoothPermissionStatus == .restricted
    }

    // MARK: Combined Permission Request
    func requestAllPermissions(completion: @escaping (_ locationGranted: Bool, _ bluetoothGranted: Bool) -> Void) {
        requestLocationPermissionOnly { [weak self] locationGranted in
            guard let self else {
                completion(locationGranted, false)
                return
            }
            self.requestBluetoothPermissionOnly { bluetoothGranted in
                completion(locationGranted, bluetoothGranted)
            }
        }
    }

    // MARK: Individual Permission Requests
    func requestLocationPermissionOnly(completion: @escaping (Bool) -> Void) {
        updatePermissionStatuses()
        if isLocationPermissionGranted {
            DispatchQueue.main.async {
                completion(true)
            }
            return
        }
        if locationPermissionStatus == .denied || locationPermissionStatus == .restricted {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        self.locationCompletion = completion
        locationManager.requestWhenInUseAuthorization()
    }

    func requestBluetoothPermissionOnly(completion: @escaping (Bool) -> Void) {
        updatePermissionStatuses()
        if isBluetoothPermissionGranted {
            DispatchQueue.main.async {
                completion(true)
            }
            return
        }
        if bluetoothPermissionStatus == .denied || bluetoothPermissionStatus == .restricted {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        if isSimulator() {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        self.bluetoothCompletion = completion
        centralManager = centralManagerFactory(self)
    }

    private func isSimulator() -> Bool {
        simulatorEnvironment
    }

    static var defaultSimulatorEnvironment: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

}

// MARK: CLLocationManagerDelegate
extension PermissionManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleLocationAuthorizationChange()
    }

    /// Testable core of the location authorization change handling.
    func handleLocationAuthorizationChange() {
        updatePermissionStatuses()
        guard locationPermissionStatus != .notDetermined else { return }
        if let completion = locationCompletion {
            locationCompletion = nil
            completion(isLocationPermissionGranted)
        }
    }

}

// MARK: CBCentralManagerDelegate
extension PermissionManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        handleBluetoothStateUpdate(isBluetoothUnavailable: central.state == .unsupported)
    }

    func handleBluetoothStateUpdate(isBluetoothUnavailable: Bool) {
        updatePermissionStatuses()
        let authorizationDetermined = bluetoothPermissionStatus != .notDetermined
        guard authorizationDetermined || isBluetoothUnavailable else { return }
        if let completion = bluetoothCompletion {
            bluetoothCompletion = nil
            centralManager = nil
            completion(isBluetoothPermissionGranted)
        }
    }

}

// Abstraction over `CLLocationManager` so the permission logic can be unit tested.
protocol LocationAuthorizing: AnyObject {
    var locationDelegate: CLLocationManagerDelegate? { get set }
    var currentAuthorizationStatus: CLAuthorizationStatus { get }
    func requestWhenInUseAuthorization()
}

extension CLLocationManager: LocationAuthorizing {
    var locationDelegate: CLLocationManagerDelegate? {
        get { delegate }
        set { delegate = newValue }
    }

    var currentAuthorizationStatus: CLAuthorizationStatus {
        authorizationStatus
    }
}
