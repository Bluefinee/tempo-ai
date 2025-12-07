import Combine
import CoreLocation
import Foundation
import HealthKit
import SwiftUI

/// Unified permission management system for HealthKit and Location services.
///
/// Provides centralized permission handling with proper error management, status tracking,
/// and notification broadcasting. Integrates with existing HealthKitManager and LocationManager
/// while providing a unified interface for onboarding and app-wide permission management.
@MainActor
final class PermissionManager: NSObject, ObservableObject {

    // MARK: - Singleton

    static let shared = PermissionManager()

    // MARK: - Published Properties

    @Published var healthKitPermissionStatus: PermissionStatus = .notDetermined
    @Published var locationPermissionStatus: PermissionStatus = .notDetermined

    // MARK: - Private Properties

    private let healthStore: HKHealthStore = HKHealthStore()
    private let locationManager: CLLocationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<PermissionStatus, Never>?

    // MARK: - HealthKit Types

    private let healthKitTypesToRead: Set<HKObjectType> = {
        var types: Set<HKObjectType> = []

        // Quantity types
        if let heartRateVariability = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(heartRateVariability)
        }
        if let restingHeartRate = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(restingHeartRate)
        }
        if let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }
        if let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergy)
        }

        // Category types
        if let sleepAnalysis = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepAnalysis)
        }

        return types
    }()

    // MARK: - Initialization

    override init() {
        super.init()
        setupLocationManager()
        updatePermissionStatuses()
    }

    // MARK: - Public Methods

    /// Request HealthKit permissions for all required health data types
    /// - Returns: Permission status after request completion
    func requestHealthKitPermission() async -> PermissionStatus {
        print("🏥 PermissionManager: Requesting HealthKit permissions...")

        #if os(iOS)
            guard HKHealthStore.isHealthDataAvailable() else {
                print("❌ HealthKit not available on this iOS device")
                await updateHealthKitStatus(.denied)
                return .denied
            }
        #else
            print("⚠️ Running on macOS - simulating HealthKit permission request for development")
        #endif

        do {
            try await healthStore.requestAuthorization(toShare: [], read: healthKitTypesToRead)
            let status = determineHealthKitStatus()
            await updateHealthKitStatus(status)
            print("✅ HealthKit permission request completed with status: \(status)")
            return status
        } catch {
            print("❌ HealthKit permission request failed: \(error.localizedDescription)")
            await updateHealthKitStatus(.denied)
            return .denied
        }
    }

    /// Request location permissions for weather data
    /// - Returns: Permission status after request completion
    func requestLocationPermission() async -> PermissionStatus {
        print("📍 PermissionManager: Requesting location permissions...")

        let currentStatus: CLAuthorizationStatus = locationManager.authorizationStatus
        print("📍 Current location authorization status: \(currentStatus)")

        // If already authorized, return immediately
        #if os(iOS)
            if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
                let status: PermissionStatus = PermissionStatus.from(clStatus: currentStatus)
                print("📍 Location already authorized on iOS: \(status)")
                await updateLocationStatus(status)
                return status
            }
        #elseif os(macOS)
            if currentStatus == .authorizedAlways {
                let status: PermissionStatus = PermissionStatus.from(clStatus: currentStatus)
                print("📍 Location already authorized on macOS: \(status)")
                await updateLocationStatus(status)
                return status
            }
            print("📍 Requesting location permission on macOS (may show system dialog)")
        #endif

        // Request permission and wait for response
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            DispatchQueue.main.async {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    /// Check current permission statuses without requesting
    func checkCurrentPermissionStatuses() {
        updatePermissionStatuses()
        print(
            "📊 Permission status check - HealthKit: \(healthKitPermissionStatus), Location: \(locationPermissionStatus)"
        )
    }

    /// Whether both critical permissions are granted
    var allCriticalPermissionsGranted: Bool {
        healthKitPermissionStatus == .granted && locationPermissionStatus == .granted
    }

    /// Whether at least one permission is granted
    var anyPermissionGranted: Bool {
        healthKitPermissionStatus == .granted || locationPermissionStatus == .granted
    }

    // MARK: - Private Methods

    private func setupLocationManager() {
        locationManager.delegate = self
    }

    private func updatePermissionStatuses() {
        // Update HealthKit status
        let healthStatus = determineHealthKitStatus()
        if healthKitPermissionStatus != healthStatus {
            healthKitPermissionStatus = healthStatus
            NotificationCenter.default.post(name: .healthKitPermissionChanged, object: nil)
        }

        // Update Location status
        let locationStatus = PermissionStatus.from(clStatus: locationManager.authorizationStatus)
        if locationPermissionStatus != locationStatus {
            locationPermissionStatus = locationStatus
            NotificationCenter.default.post(name: .locationPermissionChanged, object: nil)
        }
    }

    private func determineHealthKitStatus() -> PermissionStatus {
        #if os(iOS)
            guard HKHealthStore.isHealthDataAvailable() else {
                return .denied
            }
        #else
            // On macOS, simulate permission checking for development
            print("🏥 Simulating HealthKit status check on macOS")
        #endif

        // Check authorization status for each required type
        var allAuthorized = true
        var anyDenied = false

        for type in healthKitTypesToRead {
            let status = healthStore.authorizationStatus(for: type)
            switch status {
            case .notDetermined:
                allAuthorized = false
            case .sharingDenied:
                anyDenied = true
                allAuthorized = false
            case .sharingAuthorized:
                continue
            @unknown default:
                allAuthorized = false
            }
        }

        if allAuthorized {
            return .granted
        } else if anyDenied {
            return .denied
        } else {
            return .notDetermined
        }
    }

    private func updateHealthKitStatus(_ status: PermissionStatus) async {
        healthKitPermissionStatus = status
        NotificationCenter.default.post(name: .healthKitPermissionChanged, object: nil)
    }

    private func updateLocationStatus(_ status: PermissionStatus) async {
        locationPermissionStatus = status
        NotificationCenter.default.post(name: .locationPermissionChanged, object: nil)
    }
}

// MARK: - CLLocationManagerDelegate

extension PermissionManager: @preconcurrency CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authStatus: CLAuthorizationStatus = manager.authorizationStatus

        Task { @MainActor in
            let status: PermissionStatus = PermissionStatus.from(clStatus: authStatus)
            await updateLocationStatus(status)

            // Complete any pending permission request
            if let continuation = locationContinuation {
                locationContinuation = nil
                continuation.resume(returning: status)
            }
        }

        print("📍 Location authorization changed to: \(authStatus.rawValue)")
    }
}

// MARK: - Permission Status Enum

/// Represents the status of a permission request
enum PermissionStatus: String, CaseIterable {
    case notDetermined = "not_determined"
    case granted = "granted"
    case denied = "denied"
    case restricted = "restricted"

    /// User-friendly display text
    var displayText: String {
        switch self {
        case .notDetermined:
            return "Not Requested"
        case .granted:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        }
    }

    /// Associated color for UI display
    var color: Color {
        switch self {
        case .granted:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        }
    }

    /// Associated SF Symbol icon
    var icon: String {
        switch self {
        case .granted:
            return "checkmark.circle.fill"
        case .denied, .restricted:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        }
    }

    /// Convert from Core Location authorization status
    static func from(clStatus: CLAuthorizationStatus) -> PermissionStatus {
        switch clStatus {
        case .notDetermined:
            return .notDetermined
        #if os(iOS)
            case .authorizedWhenInUse, .authorizedAlways:
                return .granted
        #elseif os(macOS)
            case .authorizedAlways:
                return .granted
        #endif
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
    }
}

// MARK: - Permission Error Types

enum PermissionError: LocalizedError {
    case healthKitNotAvailable
    case permissionDenied(String)
    case locationServicesDisabled
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .healthKitNotAvailable:
            return "HealthKit is not available on this device"
        case .permissionDenied(let permission):
            return "\(permission) permission was denied"
        case .locationServicesDisabled:
            return "Location services are disabled"
        case .unknown(let error):
            return "Unknown permission error: \(error.localizedDescription)"
        }
    }
}
