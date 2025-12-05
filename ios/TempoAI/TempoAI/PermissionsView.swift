import CoreLocation
import SwiftUI

// MARK: - Permissions View
struct PermissionsView: View {
    let healthKitManager: HealthKitManager
    let locationManager: LocationManager
    let onDismiss: () -> Void

    @State private var showErrorAlert: Bool = false
    @State private var alertMessage: String = ""

    private var isLocationAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse
            || locationManager.authorizationStatus == .authorizedAlways
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Permissions Required")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(spacing: 16) {
                    PermissionRow(
                        icon: "heart.fill",
                        title: "HealthKit",
                        description: "Access your health data for personalized advice",
                        status: healthKitManager.isAuthorized ? "Authorized" : "Not Authorized",
                        color: healthKitManager.isAuthorized ? .green : .red
                    )

                    PermissionRow(
                        icon: "location.fill",
                        title: "Location",
                        description: "Get weather information for your area",
                        status: isLocationAuthorized ? "Authorized" : "Not Authorized",
                        color: isLocationAuthorized ? .green : .red
                    )
                }

                if !healthKitManager.isAuthorized {
                    Button("Enable HealthKit") {
                        Task {
                            do {
                                try await healthKitManager.requestAuthorization()
                            } catch {
                                await MainActor.run {
                                    alertMessage = "HealthKit authorization failed: \(error.localizedDescription)"
                                    showErrorAlert = true
                                }
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                if !isLocationAuthorized {
                    Button("Enable Location") {
                        locationManager.requestLocation()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            })
            .onChange(of: locationManager.errorMessage) { newValue in
                if let error = newValue {
                    alertMessage = error
                    showErrorAlert = true
                }
            }
            .alert("Permission Error", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
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
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}
