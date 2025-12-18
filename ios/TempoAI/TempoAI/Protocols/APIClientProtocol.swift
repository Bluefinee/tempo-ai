import Foundation

/// Protocol for API client operations
/// Enables dependency injection and testing
@MainActor
protocol APIClientProtocol: AnyObject {
    /// Generates daily advice based on user profile and health data
    /// - Parameter request: The advice request containing user data
    /// - Returns: DailyAdvice response from the backend
    /// - Throws: APIError for various failure conditions
    func generateAdvice(request: AdviceRequest) async throws -> DailyAdvice

    /// Health check to verify backend connectivity
    /// - Returns: True if backend is healthy, false otherwise
    func healthCheck() async -> Bool
}
