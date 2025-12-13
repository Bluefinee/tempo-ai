import Foundation

/// キャッシュ管理のプロトコル
/// テスト時にモック実装を注入可能にする
@MainActor
protocol CacheManaging: AnyObject {
    // MARK: - User Profile

    /// ユーザープロフィールを保存
    func saveUserProfile(_ profile: UserProfile) throws

    /// ユーザープロフィールを読み込み
    func loadUserProfile() throws -> UserProfile?

    /// ユーザープロフィールを削除
    func deleteUserProfile()

    // MARK: - Onboarding

    /// オンボーディング完了フラグを保存
    func saveOnboardingCompleted(_ completed: Bool)

    /// オンボーディング完了状態を読み込み
    func isOnboardingCompleted() -> Bool

    /// オンボーディング状態をリセット
    func resetOnboardingState()

    // MARK: - Advice Cache

    /// アドバイスを保存
    func saveAdvice<T: Codable>(_ advice: T, for date: Date) throws

    /// アドバイスを読み込み
    func loadAdvice<T: Codable>(for date: Date, type: T.Type) throws -> T?

    /// アドバイスがキャッシュされているかチェック
    func isAdviceCached(for date: Date) -> Bool
}
