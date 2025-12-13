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
}
