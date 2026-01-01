import Foundation

// MARK: - HealthKitRepositoryProtocol

/// HealthKitデータアクセス層のプロトコル
/// テスト時にモックに差し替え可能
protocol HealthKitRepositoryProtocol: Sendable {
    /// HealthKitへの認証を要求
    func requestAuthorization() async throws

    /// 今日のヘルスメトリクスを取得
    func fetchTodayMetrics() async throws -> HealthMetrics

    /// 過去N日間の睡眠履歴を取得
    func fetchSleepHistory(days: Int) async throws -> [SleepMetrics]

    /// 過去N日間のHRVベースラインを計算
    func fetchHRVBaseline(days: Int) async throws -> Double
}
