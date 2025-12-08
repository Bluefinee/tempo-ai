import CoreLocation
import Foundation

class LocationPermissionDelegate: NSObject, CLLocationManagerDelegate {
    private let completion: (Bool) -> Void

    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        super.init()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission granted")
            completion(true)
        case .denied, .restricted:
            print("❌ Location permission denied")
            completion(false)
        case .notDetermined:
            // Wait for user decision
            break
        @unknown default:
            completion(false)
        }
    }
}
