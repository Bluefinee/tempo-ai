import Foundation

// MARK: - LocalStorageProtocol

/// ローカルストレージのプロトコル
/// テスト時にモックに差し替え可能
protocol LocalStorageProtocol: Sendable {
    /// 値を保存
    func save<T: Codable>(_ value: T, forKey key: String)

    /// 値を読み込み
    func load<T: Codable>(forKey key: String) -> T?

    /// 値を削除
    func remove(forKey key: String)

    /// キーが存在するか確認
    func exists(forKey key: String) -> Bool
}
