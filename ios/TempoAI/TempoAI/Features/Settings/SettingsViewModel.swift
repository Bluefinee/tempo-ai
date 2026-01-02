//
//  SettingsViewModel.swift
//  TempoAI
//
//  Settings screen state management
//

import Combine
import Foundation

// MARK: - SettingsViewModel

/// Settings画面の状態管理
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Published Properties (Editable)

    @Published var nickname: String = ""
    @Published var weight: Double = 0
    @Published var height: Double = 0
    @Published var chronotype: Chronotype = .intermediate
    @Published var targetBedtime: Date = Date()

    // MARK: - Published Properties (Read-only)

    @Published private(set) var age: Int = 0
    @Published private(set) var gender: Gender = .preferNotToSay
    @Published private(set) var occupation: Occupation?
    @Published private(set) var exerciseFrequency: ExerciseFrequency?
    @Published private(set) var alcoholFrequency: AlcoholFrequency?

    // MARK: - Published Properties (Status)

    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var error: SettingsError?
    @Published var showSaveSuccess: Bool = false

    // MARK: - Dependencies

    private let localStorage: LocalStorageProtocol
    private var originalProfile: UserProfile?

    // MARK: - Computed Properties

    /// アプリバージョン
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// ビルド番号
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// バージョン表示文字列
    var versionDisplayString: String {
        "Version \(appVersion) (\(buildNumber))"
    }

    /// 性別の表示文字列
    var genderDisplayString: String {
        gender.rawValue
    }

    /// 変更があるかどうか
    var hasChanges: Bool {
        guard let original = originalProfile else { return false }
        return nickname != original.nickname ||
            weight != original.weight ||
            height != original.height ||
            chronotype != original.chronotype ||
            !Calendar.current.isDate(targetBedtime, equalTo: original.targetBedtime, toGranularity: .minute)
    }

    // MARK: - Initialization

    init(localStorage: LocalStorageProtocol = LocalStorage()) {
        self.localStorage = localStorage
    }

    // MARK: - Public Methods

    /// プロフィールを読み込む
    func loadProfile() {
        isLoading = true
        defer { isLoading = false }

        guard let profile: UserProfile = localStorage.load(forKey: StorageKeys.userProfile) else {
            error = .loadFailed
            return
        }

        originalProfile = profile
        populateFields(from: profile)
    }

    /// プロフィールを保存する
    func saveProfile() async {
        guard hasChanges else { return }
        guard let original = originalProfile else {
            error = .saveFailed
            return
        }

        isSaving = true
        defer { isSaving = false }

        // 新しいUserProfileを作成（letプロパティのため）
        let updatedProfile = UserProfile(
            nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines),
            age: original.age,
            gender: original.gender,
            weight: weight,
            height: height,
            occupation: original.occupation,
            chronotype: chronotype,
            exerciseFrequency: original.exerciseFrequency,
            alcoholFrequency: original.alcoholFrequency,
            targetBedtime: targetBedtime
        )

        localStorage.save(updatedProfile, forKey: StorageKeys.userProfile)
        originalProfile = updatedProfile
        showSaveSuccess = true

        // 成功メッセージを3秒後に非表示
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        showSaveSuccess = false
    }

    /// 変更を元に戻す
    func resetToOriginal() {
        guard let profile = originalProfile else { return }
        populateFields(from: profile)
    }

    // MARK: - Private Methods

    private func populateFields(from profile: UserProfile) {
        nickname = profile.nickname
        age = profile.age
        gender = profile.gender
        weight = profile.weight
        height = profile.height
        occupation = profile.occupation
        chronotype = profile.chronotype
        exerciseFrequency = profile.exerciseFrequency
        alcoholFrequency = profile.alcoholFrequency
        targetBedtime = profile.targetBedtime
    }
}

// MARK: - SettingsError

enum SettingsError: LocalizedError, Identifiable {
    case loadFailed
    case saveFailed
    case invalidData

    var id: String { localizedDescription }

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "プロフィールの読み込みに失敗しました"
        case .saveFailed:
            return "プロフィールの保存に失敗しました"
        case .invalidData:
            return "入力データが不正です"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .loadFailed:
            return "アプリを再起動してください"
        case .saveFailed:
            return "時間をおいて再試行してください"
        case .invalidData:
            return "入力内容を確認してください"
        }
    }
}
