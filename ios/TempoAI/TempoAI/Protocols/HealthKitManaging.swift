import Foundation

/// HealthKit管理のプロトコル
/// テスト時にモック実装を注入可能にする
@MainActor
protocol HealthKitManaging: ObservableObject {
    /// 現在の認証ステータス
    var authorizationStatus: HealthKitAuthorizationStatus { get }

    /// 権限リクエスト中かどうか
    var isRequestingPermission: Bool { get }

    /// 認証ステータスを確認
    func checkAuthorizationStatus()

    /// HealthKit権限をリクエスト
    func requestAuthorization() async throws

    /// HealthKitデータを取得
    func fetchInitialData() async throws -> HealthData

    // MARK: - Phase 12.5: リズム指標

    /// 日光浴時間を取得
    /// - Parameter date: 取得対象日
    /// - Returns: (total: 合計分, morning: 午前中の分)
    func fetchTimeInDaylight(for date: Date) async throws -> (total: Int, morning: Int)

    /// 手首皮膚温データを取得（Apple Watch Series 8+のみ）
    /// - Returns: 体温位相指標、非対応機種ではnil
    func fetchWristTemperature() async throws -> TemperatureMetric?

    /// 手首皮膚温が利用可能か確認
    func isWristTemperatureAvailable() -> Bool

    /// 全リズム指標を一括取得
    /// - Parameter date: 取得対象日
    /// - Returns: 5指標統合モデル
    func fetchRhythmMetrics(for date: Date) async throws -> RhythmMetrics
}
