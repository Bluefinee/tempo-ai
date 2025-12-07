import CoreLocation
import SwiftUI

// MARK: - Permissions View
struct PermissionsView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared
    let locationManager: LocationManager
    let onDismiss: () -> Void

    @State private var showErrorAlert: Bool = false
    @State private var alertMessage: String = ""

    private var isLocationAuthorized: Bool {
        #if os(iOS)
            return locationManager.authorizationStatus == .authorizedWhenInUse
                || locationManager.authorizationStatus == .authorizedAlways
        #else
            return locationManager.authorizationStatus == .authorizedAlways
        #endif
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Permissions Required")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityIdentifier(UIIdentifiers.PermissionsView.headerTitle)

                VStack(spacing: 16) {
                    PermissionRow(
                        icon: "heart.fill",
                        title: "HealthKit",
                        description: "Access your health data for personalized advice",
                        status: healthKitManager.authorizationStatus.rawValue.capitalized,
                        color: healthKitManager.authorizationStatus == .granted ? .green : .orange
                    )
                    .accessibilityIdentifier(UIIdentifiers.PermissionsView.healthKitRow)

                    PermissionRow(
                        icon: "location.fill",
                        title: "Location",
                        description: "Get weather information for your area",
                        status: isLocationAuthorized ? "Authorized" : "Not Authorized",
                        color: isLocationAuthorized ? .green : .red
                    )
                    .accessibilityIdentifier(UIIdentifiers.PermissionsView.locationRow)
                }
                .accessibilityIdentifier(UIIdentifiers.PermissionsView.permissionsList)

                if healthKitManager.authorizationStatus != .granted {
                    Button("Enable HealthKit") {
                        Task {
                            let success = await healthKitManager.requestAuthorization()
                            if !success {
                                await MainActor.run {
                                    alertMessage = "HealthKit permission request failed. Please check your settings."
                                    showErrorAlert = true
                                }
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier(UIIdentifiers.PermissionsView.healthKitButton)
                }

                if !isLocationAuthorized {
                    Button("Enable Location") {
                        locationManager.requestLocation()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier(UIIdentifiers.PermissionsView.locationButton)
                }

                // Loading indicator when requesting permissions
                if healthKitManager.isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())

                        Text("Requesting HealthKit permission...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
                }

                Spacer()
            }
            .accessibilityIdentifier(UIIdentifiers.PermissionsView.mainView)
            .padding()
            .navigationTitle("Settings")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        onDismiss()
                    }
                    .accessibilityIdentifier(UIIdentifiers.PermissionsView.dismissButton)
                }
            })
            .onChange(of: locationManager.errorMessage) { newValue in
                if let error = newValue {
                    alertMessage = error
                    showErrorAlert = true
                }
            }
            .alert("Permission Error", isPresented: $showErrorAlert) {
                Button("OK") {
                    // Alert OK button accessibility handled by system
                }
                .accessibilityIdentifier(UIIdentifiers.Common.alertOKButton)
            } message: {
                Text(alertMessage)
                    .accessibilityIdentifier(UIIdentifiers.Common.alertMessage)
            }
        }
    }
}

// MARK: - Permission Row
struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let status: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            // Icon doesn't need individual identifier - it's part of the row

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(status)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
                .accessibilityIdentifier(UIIdentifiers.PermissionsView.permissionStatus(for: title))
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}
