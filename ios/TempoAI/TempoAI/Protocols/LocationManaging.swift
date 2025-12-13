import Foundation

/// 位置情報管理のプロトコル
/// テスト時にモック実装を注入可能にする
@MainActor
protocol LocationManaging: ObservableObject {
    /// 現在の認証ステータス
    var authorizationStatus: LocationAuthorizationStatus { get }

    /// 権限リクエスト中かどうか
    var isRequestingPermission: Bool { get }

    /// 位置情報取得中かどうか
    var isRequestingLocation: Bool { get }

    /// 現在の位置情報
    var currentLocation: LocationData? { get }

    /// 認証ステータスを確認
    func checkAuthorizationStatus()

    /// 位置情報権限をリクエスト
    func requestAuthorization()

    /// 現在位置を取得
    func requestCurrentLocation() async throws -> LocationData
}
