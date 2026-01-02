//
//  MockLocalStorage.swift
//  TempoAITests
//
//  Shared mock for LocalStorageProtocol
//

import Foundation
@testable import TempoAI

/// テスト用のLocalStorageモック
final class MockLocalStorage: LocalStorageProtocol, @unchecked Sendable {
    private var storage: [String: Data] = [:]
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()

    func save<T: Codable>(_ value: T, forKey key: String) throws {
        let data: Data = try encoder.encode(value)
        storage[key] = data
    }

    func load<T: Codable>(forKey key: String) -> T? {
        guard let data: Data = storage[key] else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func remove(forKey key: String) {
        storage.removeValue(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        storage[key] != nil
    }

    /// テスト用: ストレージをクリア
    func clear() {
        storage.removeAll()
    }

    /// テスト用: 直接データをセット
    func setMockData(_ data: Data, forKey key: String) {
        storage[key] = data
    }
}
