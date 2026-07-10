//
//  PermissionManagerTests.swift
//  RetailBrainTests
//
//  Created by muhammed.nadeem.m.a on 08/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import XCTest
import CoreLocation
import CoreBluetooth
@testable import RetailBrain

private final class MockLocationManager: LocationAuthorizing {
    weak var locationDelegate: CLLocationManagerDelegate?
    var currentAuthorizationStatus: CLAuthorizationStatus
    private(set) var requestWhenInUseAuthorizationCallCount = 0

    init(status: CLAuthorizationStatus = .notDetermined) {
        self.currentAuthorizationStatus = status
    }

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCallCount += 1
    }
}

// Mutable holder so the injected bluetooth authorization provider can change over time.
private final class MutableBluetoothAuthorization {
    var status: CBManagerAuthorization

    init(_ status: CBManagerAuthorization = .notDetermined) {
        self.status = status
    }
}

final class PermissionManagerTests: XCTestCase {

    private var locationMock: MockLocationManager!
    private var bluetoothHolder: MutableBluetoothAuthorization!
    private var centralManagerFactoryCallCount = 0

    override func setUp() {
        super.setUp()
        locationMock = MockLocationManager()
        bluetoothHolder = MutableBluetoothAuthorization()
        centralManagerFactoryCallCount = 0
    }

    override func tearDown() {
        locationMock = nil
        bluetoothHolder = nil
        super.tearDown()
    }

    private func makeSUT(
        locationStatus: CLAuthorizationStatus = .notDetermined,
        bluetoothStatus: CBManagerAuthorization = .notDetermined,
        simulatorEnvironment: Bool = false
    ) -> PermissionManager {
        locationMock.currentAuthorizationStatus = locationStatus
        bluetoothHolder.status = bluetoothStatus
        return PermissionManager(
            locationManager: locationMock,
            bluetoothAuthorizationProvider: { [weak self] in self?.bluetoothHolder.status ?? .notDetermined },
            centralManagerFactory: { [weak self] _ in
                self?.centralManagerFactoryCallCount += 1
                return nil
            },
            simulatorEnvironment: simulatorEnvironment
        )
    }

    // MARK: Initialization
    func test_init_setsLocationDelegate() {
        let sut = makeSUT()
        XCTAssertTrue(locationMock.locationDelegate === sut)
    }

    func test_init_updatesPermissionStatusesFromDependencies() {
        let sut = makeSUT(locationStatus: .authorizedWhenInUse, bluetoothStatus: .allowedAlways)
        XCTAssertEqual(sut.locationPermissionStatus, .authorizedWhenInUse)
        XCTAssertEqual(sut.bluetoothPermissionStatus, .allowedAlways)
    }

    // MARK: updatePermissionStatuses
    func test_updatePermissionStatuses_reflectsLatestValues() {
        let sut = makeSUT(locationStatus: .notDetermined, bluetoothStatus: .notDetermined)
        locationMock.currentAuthorizationStatus = .denied
        bluetoothHolder.status = .denied

        sut.updatePermissionStatuses()

        XCTAssertEqual(sut.locationPermissionStatus, .denied)
        XCTAssertEqual(sut.bluetoothPermissionStatus, .denied)
    }

    // MARK: areAllPermissionsGranted
    func test_areAllPermissionsGranted_trueWhenBothGranted_whenInUse() {
        let sut = makeSUT(locationStatus: .authorizedWhenInUse, bluetoothStatus: .allowedAlways)
        XCTAssertTrue(sut.areAllPermissionsGranted)
    }

    func test_areAllPermissionsGranted_trueWhenBothGranted_always() {
        let sut = makeSUT(locationStatus: .authorizedAlways, bluetoothStatus: .allowedAlways)
        XCTAssertTrue(sut.areAllPermissionsGranted)
    }

    func test_areAllPermissionsGranted_falseWhenLocationMissing() {
        let sut = makeSUT(locationStatus: .denied, bluetoothStatus: .allowedAlways)
        XCTAssertFalse(sut.areAllPermissionsGranted)
    }

    func test_areAllPermissionsGranted_falseWhenBluetoothMissing() {
        let sut = makeSUT(locationStatus: .authorizedAlways, bluetoothStatus: .denied)
        XCTAssertFalse(sut.areAllPermissionsGranted)
    }

    // MARK: isLocationPermissionGranted
    func test_isLocationPermissionGranted() {
        XCTAssertTrue(makeSUT(locationStatus: .authorizedAlways).isLocationPermissionGranted)
        XCTAssertTrue(makeSUT(locationStatus: .authorizedWhenInUse).isLocationPermissionGranted)
        XCTAssertFalse(makeSUT(locationStatus: .notDetermined).isLocationPermissionGranted)
        XCTAssertFalse(makeSUT(locationStatus: .denied).isLocationPermissionGranted)
        XCTAssertFalse(makeSUT(locationStatus: .restricted).isLocationPermissionGranted)
    }

    // MARK: isBluetoothPermissionGranted
    func test_isBluetoothPermissionGranted() {
        XCTAssertTrue(makeSUT(bluetoothStatus: .allowedAlways).isBluetoothPermissionGranted)
        XCTAssertFalse(makeSUT(bluetoothStatus: .notDetermined).isBluetoothPermissionGranted)
        XCTAssertFalse(makeSUT(bluetoothStatus: .denied).isBluetoothPermissionGranted)
        XCTAssertFalse(makeSUT(bluetoothStatus: .restricted).isBluetoothPermissionGranted)
    }

    // MARK: isLocationPermissionDenied
    func test_isLocationPermissionDenied() {
        XCTAssertTrue(makeSUT(locationStatus: .denied).isLocationPermissionDenied)
        XCTAssertTrue(makeSUT(locationStatus: .restricted).isLocationPermissionDenied)
        XCTAssertFalse(makeSUT(locationStatus: .notDetermined).isLocationPermissionDenied)
        XCTAssertFalse(makeSUT(locationStatus: .authorizedAlways).isLocationPermissionDenied)
    }

    // MARK: isBluetoothPermissionDenied
    func test_isBluetoothPermissionDenied() {
        XCTAssertTrue(makeSUT(bluetoothStatus: .denied).isBluetoothPermissionDenied)
        XCTAssertTrue(makeSUT(bluetoothStatus: .restricted).isBluetoothPermissionDenied)
        XCTAssertFalse(makeSUT(bluetoothStatus: .notDetermined).isBluetoothPermissionDenied)
        XCTAssertFalse(makeSUT(bluetoothStatus: .allowedAlways).isBluetoothPermissionDenied)
    }

    // MARK: requestLocationPermissionOnly
    func test_requestLocationPermissionOnly_alreadyGranted_completesTrueWithoutPrompt() {
        let sut = makeSUT(locationStatus: .authorizedWhenInUse)
        let exp = expectation(description: "completion")

        sut.requestLocationPermissionOnly { granted in
            XCTAssertTrue(granted)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(locationMock.requestWhenInUseAuthorizationCallCount, 0)
    }

    func test_requestLocationPermissionOnly_denied_completesFalseWithoutPrompt() {
        let sut = makeSUT(locationStatus: .denied)
        let exp = expectation(description: "completion")

        sut.requestLocationPermissionOnly { granted in
            XCTAssertFalse(granted)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(locationMock.requestWhenInUseAuthorizationCallCount, 0)
    }

    func test_requestLocationPermissionOnly_restricted_completesFalseWithoutPrompt() {
        let sut = makeSUT(locationStatus: .restricted)
        let exp = expectation(description: "completion")

        sut.requestLocationPermissionOnly { granted in
            XCTAssertFalse(granted)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(locationMock.requestWhenInUseAuthorizationCallCount, 0)
    }

    func test_requestLocationPermissionOnly_notDetermined_promptsAndDefersCompletion() {
        let sut = makeSUT(locationStatus: .notDetermined)
        var completionCalled = false

        sut.requestLocationPermissionOnly { _ in completionCalled = true }

        XCTAssertEqual(locationMock.requestWhenInUseAuthorizationCallCount, 1)
        XCTAssertFalse(completionCalled, "Completion should wait for the delegate callback")

        // Simulate the user granting permission and the system firing the delegate.
        locationMock.currentAuthorizationStatus = .authorizedWhenInUse
        sut.handleLocationAuthorizationChange()

        XCTAssertTrue(completionCalled)
    }

    // MARK: requestBluetoothPermissionOnly
    func test_requestBluetoothPermissionOnly_alreadyGranted_completesTrue() {
        let sut = makeSUT(bluetoothStatus: .allowedAlways)
        let exp = expectation(description: "completion")

        sut.requestBluetoothPermissionOnly { granted in
            XCTAssertTrue(granted)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(centralManagerFactoryCallCount, 0)
    }

    func test_requestBluetoothPermissionOnly_denied_completesFalse() {
        let sut = makeSUT(bluetoothStatus: .denied)
        let exp = expectation(description: "completion")

        sut.requestBluetoothPermissionOnly { granted in
            XCTAssertFalse(granted)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(centralManagerFactoryCallCount, 0)
    }

    func test_requestBluetoothPermissionOnly_restricted_completesFalse() {
        let sut = makeSUT(bluetoothStatus: .restricted)
        let exp = expectation(description: "completion")

        sut.requestBluetoothPermissionOnly { granted in
            XCTAssertFalse(granted)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(centralManagerFactoryCallCount, 0)
    }

    func test_requestBluetoothPermissionOnly_simulator_completesFalseWithoutFactory() {
        let sut = makeSUT(bluetoothStatus: .notDetermined, simulatorEnvironment: true)
        let exp = expectation(description: "completion")

        sut.requestBluetoothPermissionOnly { granted in
            XCTAssertFalse(granted)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(centralManagerFactoryCallCount, 0)
    }

    func test_requestBluetoothPermissionOnly_notDeterminedRealDevice_createsCentralManagerAndDefers() {
        let sut = makeSUT(bluetoothStatus: .notDetermined, simulatorEnvironment: false)
        var completionCalled = false

        sut.requestBluetoothPermissionOnly { _ in completionCalled = true }

        XCTAssertEqual(centralManagerFactoryCallCount, 1)
        XCTAssertFalse(completionCalled, "Completion should wait for the central manager state update")

        // Simulate the user granting permission and the central manager updating state.
        bluetoothHolder.status = .allowedAlways
        sut.handleBluetoothStateUpdate(isBluetoothUnavailable: false)

        XCTAssertTrue(completionCalled)
    }

    // MARK: requestAllPermissions
    func test_requestAllPermissions_bothGranted() {
        let sut = makeSUT(locationStatus: .authorizedWhenInUse, bluetoothStatus: .allowedAlways)
        let exp = expectation(description: "completion")

        sut.requestAllPermissions { location, bluetooth in
            XCTAssertTrue(location)
            XCTAssertTrue(bluetooth)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_requestAllPermissions_locationGrantedBluetoothDenied() {
        let sut = makeSUT(locationStatus: .authorizedAlways, bluetoothStatus: .denied)
        let exp = expectation(description: "completion")

        sut.requestAllPermissions { location, bluetooth in
            XCTAssertTrue(location)
            XCTAssertFalse(bluetooth)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_requestAllPermissions_locationDenied_stillRequestsBluetooth() {
        let sut = makeSUT(locationStatus: .denied, bluetoothStatus: .allowedAlways)
        let exp = expectation(description: "completion")

        sut.requestAllPermissions { location, bluetooth in
            XCTAssertFalse(location)
            XCTAssertTrue(bluetooth)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: handleLocationAuthorizationChange
    func test_handleLocationAuthorizationChange_notDetermined_doesNotCallCompletion() {
        let sut = makeSUT(locationStatus: .notDetermined)
        var completionCalled = false
        sut.requestLocationPermissionOnly { _ in completionCalled = true }

        // Still not determined -> should not invoke completion.
        sut.handleLocationAuthorizationChange()

        XCTAssertFalse(completionCalled)
    }

    func test_handleLocationAuthorizationChange_granted_callsCompletionWithTrue() {
        let sut = makeSUT(locationStatus: .notDetermined)
        var receivedGranted: Bool?
        sut.requestLocationPermissionOnly { receivedGranted = $0 }

        locationMock.currentAuthorizationStatus = .authorizedAlways
        sut.handleLocationAuthorizationChange()

        XCTAssertEqual(receivedGranted, true)
    }

    func test_handleLocationAuthorizationChange_denied_callsCompletionWithFalse() {
        let sut = makeSUT(locationStatus: .notDetermined)
        var receivedGranted: Bool?
        sut.requestLocationPermissionOnly { receivedGranted = $0 }

        locationMock.currentAuthorizationStatus = .denied
        sut.handleLocationAuthorizationChange()

        XCTAssertEqual(receivedGranted, false)
    }

    func test_handleLocationAuthorizationChange_onlyFiresOnce() {
        let sut = makeSUT(locationStatus: .notDetermined)
        var callCount = 0
        sut.requestLocationPermissionOnly { _ in callCount += 1 }

        locationMock.currentAuthorizationStatus = .authorizedAlways
        sut.handleLocationAuthorizationChange()
        sut.handleLocationAuthorizationChange()

        XCTAssertEqual(callCount, 1, "Completion should be cleared after first invocation")
    }

    func test_handleLocationAuthorizationChange_withoutPendingCompletion_doesNotCrash() {
        let sut = makeSUT(locationStatus: .authorizedAlways)
        // No pending completion set.
        sut.handleLocationAuthorizationChange()
        XCTAssertTrue(sut.isLocationPermissionGranted)
    }

    // MARK: handleBluetoothStateUpdate
    func test_handleBluetoothStateUpdate_notDeterminedAndAvailable_doesNotCallCompletion() {
        let sut = makeSUT(bluetoothStatus: .notDetermined, simulatorEnvironment: false)
        var completionCalled = false
        sut.requestBluetoothPermissionOnly { _ in completionCalled = true }

        sut.handleBluetoothStateUpdate(isBluetoothUnavailable: false)

        XCTAssertFalse(completionCalled)
    }

    func test_handleBluetoothStateUpdate_determined_callsCompletion() {
        let sut = makeSUT(bluetoothStatus: .notDetermined, simulatorEnvironment: false)
        var receivedGranted: Bool?
        sut.requestBluetoothPermissionOnly { receivedGranted = $0 }

        bluetoothHolder.status = .allowedAlways
        sut.handleBluetoothStateUpdate(isBluetoothUnavailable: false)

        XCTAssertEqual(receivedGranted, true)
    }

    func test_handleBluetoothStateUpdate_unavailable_callsCompletionWithFalse() {
        let sut = makeSUT(bluetoothStatus: .notDetermined, simulatorEnvironment: false)
        var receivedGranted: Bool?
        sut.requestBluetoothPermissionOnly { receivedGranted = $0 }

        // Still notDetermined but hardware unavailable -> completion fires with current (false) grant.
        sut.handleBluetoothStateUpdate(isBluetoothUnavailable: true)

        XCTAssertEqual(receivedGranted, false)
    }

    func test_handleBluetoothStateUpdate_onlyFiresOnce() {
        let sut = makeSUT(bluetoothStatus: .notDetermined, simulatorEnvironment: false)
        var callCount = 0
        sut.requestBluetoothPermissionOnly { _ in callCount += 1 }

        bluetoothHolder.status = .allowedAlways
        sut.handleBluetoothStateUpdate(isBluetoothUnavailable: false)
        sut.handleBluetoothStateUpdate(isBluetoothUnavailable: false)

        XCTAssertEqual(callCount, 1)
    }

    func test_handleBluetoothStateUpdate_withoutPendingCompletion_doesNotCrash() {
        let sut = makeSUT(bluetoothStatus: .allowedAlways)
        sut.handleBluetoothStateUpdate(isBluetoothUnavailable: false)
        XCTAssertTrue(sut.isBluetoothPermissionGranted)
    }

    // MARK: defaultSimulatorEnvironment
    func test_defaultSimulatorEnvironment_matchesCompileTarget() {
        #if targetEnvironment(simulator)
        XCTAssertTrue(PermissionManager.defaultSimulatorEnvironment)
        #else
        XCTAssertFalse(PermissionManager.defaultSimulatorEnvironment)
        #endif
    }
}
