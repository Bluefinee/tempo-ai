//
//  EnvironmentConfiguration.swift
//  TempoAI
//
//  Created for standard iOS environment configuration
//

import Foundation

/// Standard iOS environment configuration following 2025 best practices
enum Environment: String, CaseIterable {
    case development = "DEVELOPMENT"
    case staging = "STAGING"
    case production = "PRODUCTION"

    /// Current environment determined at compile time
    static var current: Environment {
        #if DEVELOPMENT
            return .development
        #elseif STAGING
            return .staging
        #elseif PRODUCTION
            return .production
        #else
            return .development  // Default fallback
        #endif
    }

    /// Environment display name
    var displayName: String {
        switch self {
        case .development: return "Development"
        case .staging: return "Staging"
        case .production: return "Production"
        }
    }
}

/// Universal network configuration for all environments
struct EnvironmentConfiguration {
    let baseURL: String
    let port: Int
    let scheme: String
    let timeout: TimeInterval
    let enableLogging: Bool
    let allowsInsecureHTTP: Bool

    /// Current environment configuration
    static var current: EnvironmentConfiguration {
        switch Environment.current {
        case .development:
            return EnvironmentConfiguration(
                baseURL: "127.0.0.1",
                port: 8787,
                scheme: "http",
                timeout: 30.0,
                enableLogging: true,
                allowsInsecureHTTP: true
            )
        case .staging:
            return EnvironmentConfiguration(
                baseURL: "staging.tempo-ai.com",
                port: 443,
                scheme: "https",
                timeout: 20.0,
                enableLogging: true,
                allowsInsecureHTTP: false
            )
        case .production:
            return EnvironmentConfiguration(
                baseURL: "api.tempo-ai.com",
                port: 443,
                scheme: "https",
                timeout: 15.0,
                enableLogging: false,
                allowsInsecureHTTP: false
            )
        }
    }

    /// Computed full base URL with scheme and port
    var fullBaseURL: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = baseURL

        // Only add port if it's not the default for the scheme
        if (scheme == "http" && port != 80) || (scheme == "https" && port != 443) {
            components.port = port
        }

        return components.url
    }

    /// Build URL for specific endpoint
    func buildURL(for endpoint: String) -> URL? {
        guard let baseURL = fullBaseURL else { return nil }
        return baseURL.appendingPathComponent(endpoint)
    }
}

/// Device type detection for universal configuration
enum DeviceType {
    case simulator
    case device

    static var current: DeviceType {
        #if targetEnvironment(simulator)
            return .simulator
        #else
            return .device
        #endif
    }
}

/// Network reachability status
enum NetworkReachability {
    case unknown
    case notReachable
    case reachableViaWiFi
    case reachableViaCellular
}
