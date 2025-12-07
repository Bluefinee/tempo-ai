import Foundation

// MARK: - HealthKit Error Types

enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationFailed(details: String)
    case partialAuthorization(granted: [String], denied: [String])
    case dataUnavailable(dataType: String)
    case queryFailed(dataType: String, error: String)
    case insufficientData(missing: [String], recommendations: [String])

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationFailed(let details):
            return "HealthKit authorization failed: \(details)"
        case .partialAuthorization(let granted, let denied):
            let grantedList = granted.joined(separator: ", ")
            let deniedList = denied.joined(separator: ", ")
            return "Partial HealthKit access - Granted: \(grantedList), Denied: \(deniedList)"
        case .dataUnavailable(let dataType):
            return "Health data unavailable for type: \(dataType)"
        case .queryFailed(let dataType, let error):
            return "HealthKit query failed for \(dataType): \(error)"
        case .insufficientData(let missing, _):
            let missingList = missing.joined(separator: ", ")
            return "Insufficient health data for analysis. Missing: \(missingList)"
        }
    }

    var failureReason: String? {
        switch self {
        case .notAvailable:
            return "This device does not support HealthKit or health data access"
        case .authorizationFailed:
            return "User has not granted permission to access health data"
        case .partialAuthorization:
            return "Some health data types are not accessible"
        case .dataUnavailable:
            return "The requested health data is not available or accessible"
        case .queryFailed:
            return "Failed to retrieve health data from HealthKit"
        case .insufficientData:
            return "Not enough health data available for meaningful analysis"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not supported on this device. Please use a compatible iOS device with health data."
        case .authorizationFailed, .partialAuthorization:
            return "Please enable HealthKit permissions in Settings > Privacy & Security > Health > Tempo AI"
        case .dataUnavailable, .queryFailed:
            return "Ensure health data is available and try again. You may need to use the Health app first."
        case .insufficientData(_, let recommendations):
            return recommendations.first
                ?? "Enable more health data permissions or ensure your devices are collecting data regularly."
        }
    }
}
