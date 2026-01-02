import Foundation

// MARK: - LocalStorageProtocol

/// ローカルストレージのプロトコル
/// テスト時にモックに差し替え可能
protocol LocalStorageProtocol: Sendable {
    /// 値を保存
    /// - Throws: LocalStorageError.encodingFailed エンコードに失敗した場合
    func save<T: Codable>(_ value: T, forKey key: String) throws

    /// 値を読み込み
    func load<T: Codable>(forKey key: String) -> T?

    /// 値を削除
    func remove(forKey key: String)

    /// キーが存在するか確認
    func exists(forKey key: String) -> Bool
}

// MARK: - LocalStorageError

/// ローカルストレージのエラー
enum LocalStorageError: LocalizedError {
    case encodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let key):
            return "Failed to encode data for key: \(key)"
        }
    }
}
