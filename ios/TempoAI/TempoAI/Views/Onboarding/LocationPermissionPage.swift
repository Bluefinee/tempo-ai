import SwiftUI
import CoreLocation

struct LocationPermissionPage: View {
    @Binding var isGranted: Bool
    let onNext: () -> Void
    let onBack: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section (Serial Position Effect)
                VStack(spacing: Spacing.lg) {
                    Text("環境データ取得")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(ColorPalette.richBlack)
                        .padding(.top, Spacing.lg)
                    
                    Image(systemName: "location.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(.systemBlue))
                    
                    Text("気象・大気質情報で\nより正確なアドバイス")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(ColorPalette.richBlack)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                
                // Premium environmental showcase
                VStack(spacing: Spacing.md) {
                    DataTypeRow(icon: "thermometer", title: "", color: Color(.systemOrange))
                    DataTypeRow(icon: "cloud.fill", title: "", color: Color(.systemTeal))
                    DataTypeRow(icon: "sun.max.fill", title: "", color: Color(.systemYellow))
                    DataTypeRow(icon: "shield.lefthalf.filled", title: "", color: Color(.systemGreen))
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.xl)
                
                // Bottom action area (Fitts's Law)
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        Button(action: {
                            print("Location permission back button tapped")
                            onBack?()
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                Text("戻る")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(ColorPalette.gray600)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(ColorPalette.gray100)
                            .cornerRadius(CornerRadius.lg)
                        }
                        .contentShape(Rectangle())
                        
                        Button("位置情報を許可") {
                            print("📱 Location permission button tapped")
                            Task {
                                let granted = await requestLocationPermissions()
                                isGranted = granted
                                onNext()
                            }
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(ColorPalette.pureWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemBlue))
                        .cornerRadius(CornerRadius.lg)
                        .contentShape(Rectangle())
                    }
                    
                    Button("後で設定") {
                        print("📱 Skip location permission tapped")
                        onNext()
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(ColorPalette.gray600)
                    .contentShape(Rectangle())
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
                .frame(height: 120) // Fixed height for bottom area
            }
        }
        .background(ColorPalette.pureWhite)
    }
    
    private func requestLocationPermissions() async -> Bool {
        let locationManager = CLLocationManager()
        
        return await withCheckedContinuation { continuation in
            let delegate = LocationPermissionDelegate { granted in
                continuation.resume(returning: granted)
            }
            
            locationManager.delegate = delegate
            
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                print("❌ Location permission denied or restricted")
                continuation.resume(returning: false)
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ Location already authorized")
                continuation.resume(returning: true)
            @unknown default:
                continuation.resume(returning: false)
            }
            
            withExtendedLifetime(delegate) { }
        }
    }
}