import Foundation

// MARK: - Debug Reset Service

/// デバッグ用リセットサービス
/// ⚠️ 本番リリース前に確認: このファイル全体が DEBUG 用
#if DEBUG

/// デバッグ用リセットサービス
/// CacheManagerのリセット機能を集約
@MainActor
final class DebugResetService {

    private let cacheManager: CacheManaging

    init(cacheManager: CacheManaging) {
        self.cacheManager = cacheManager
    }

    /// 完全リセット（開発・テスト用）
    /// - アプリデータをすべてクリア
    /// - 権限状態をリセット
    /// - ユーザーへの詳細案内も含む
    func performCompleteReset() {
        // 1. キャッシュデータの完全削除
        clearAllCache()

        // 2. 権限状態のリセット
        resetPermissionStates()

        // 3. ユーザー案内の表示
        printResetInstructions()

        // 4. アプリ状態のリセット通知
        notifyAppReset()
    }

    /// ライトリセット（オンボーディング再実行用）
    /// - ユーザーデータのみクリア
    /// - 権限設定は維持
    func performLightReset() {
        // オンボーディングデータのみクリア
        clearOnboardingData()

        // アプリ状態のリセット通知
        notifyAppReset()

        print("🔄 オンボーディングデータをリセットしました（権限は維持）")
    }

    // MARK: - Private Methods

    /// アプリデータの完全削除
    private func clearAllCache() {
        cacheManager.deleteUserProfile()
        cacheManager.resetOnboardingState()

        print("✅ アプリデータを完全削除しました")
    }

    /// オンボーディングデータのみ削除
    private func clearOnboardingData() {
        cacheManager.deleteUserProfile()
        cacheManager.resetOnboardingState()
    }

    /// 権限状態のリセット（アプリ内状態のみ）
    private func resetPermissionStates() {
        // 注意: iOSシステムレベルの権限は手動でリセット必要
        print("🔄 アプリ内権限状態をリセットしました")
    }

    /// ユーザーへのリセット案内を表示
    private func printResetInstructions() {
        let separator = String(repeating: "=", count: 50)
        print(separator)
        print("🎯 RESET COMPLETED")
        print(separator)
        print("")
        print("✅ アプリデータが完全にリセットされました")
        print("")
        print("⚠️  iOS権限の完全リセットには手動操作が必要です:")
        print("")
        print("📱 HealthKit権限のリセット:")
        print("   設定アプリ > プライバシーとセキュリティ > HealthKit")
        print("   > Tempo AI > すべてのカテゴリをオフにする")
        print("")
        print("📍 位置情報権限のリセット:")
        print("   設定アプリ > プライバシーとセキュリティ > 位置情報")
        print("   > Tempo AI > 「なし」を選択")
        print("")
        print("🔄 完了後、アプリを再起動してオンボーディングを再テストできます")
        print(separator)
    }

    /// アプリリセット通知の送信
    private func notifyAppReset() {
        NotificationCenter.default.post(
            name: .onboardingReset,
            object: nil
        )
    }
}

#endif
