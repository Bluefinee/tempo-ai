# Phase 14: UI結合・キャッシュ設計書

**フェーズ**: 14 / 15  
**Part**: E（結合）  
**前提フェーズ**: Phase 1〜13（全て完了）

---

## ⚠️ 実装前必読ドキュメント

### 📋 必須参考資料
- **[Product Spec v4.2](../product-spec.md)** - プロダクト仕様書
- **[Technical Spec v2.0](../technical-spec.md)** - 技術仕様書

### ✅ 実装完了後の必須作業
**iOS側**: `swiftlint && swift test`  
**Backend側**: `npm run typecheck && npm run lint && npm test`

---

## このフェーズで実現すること

1. **Mock削除**: 全画面のMockデータを実APIレスポンスに置き換え
2. **CacheManager実装**: 同日キャッシュ（24時間）
3. **オフライン対応**: ネットワークエラー時のフォールバック
4. **レイアウト調整**: 実データでの文長変動への対応

---

## 完了条件

- [ ] 全画面が実APIデータで動作する
- [ ] 同日2回目の起動でキャッシュが使われる
- [ ] オフライン時に前日のアドバイスが表示される
- [ ] condition_insightがコンディション画面に表示される
- [ ] 過去2週間のトライ履歴がキャッシュされる
- [ ] Mockデータが完全に削除されている

---

## 1. APIClient実装

```swift
// Services/APIClient.swift
final class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://tempo-ai.YOUR_SUBDOMAIN.workers.dev"
    
    func fetchDailyAdvice(request: AdviceRequest) async throws -> AdviceResponse {
        let url = URL(string: "\(baseURL)/api/advice")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("tempo-ai-mobile-app-key-v1", forHTTPHeaderField: "X-API-Key")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(AdviceResponse.self, from: data)
    }
    
    func fetchEnvironmentData(lat: Double, lon: Double) async throws -> EnvironmentResponse {
        var components = URLComponents(string: "\(baseURL)/api/environment")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon))
        ]
        
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.setValue("tempo-ai-mobile-app-key-v1", forHTTPHeaderField: "X-API-Key")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(EnvironmentResponse.self, from: data)
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "サーバーからの応答が不正です"
        case .serverError(let code): return "サーバーエラー（\(code)）"
        case .networkError: return "ネットワーク接続を確認してください"
        }
    }
}
```

---

## 2. CacheManager実装

```swift
// Services/CacheManager.swift
final class CacheManager {
    static let shared = CacheManager()
    private let defaults = UserDefaults.standard
    
    // アドバイスキャッシュ
    func saveAdvice(_ advice: DailyAdvice, for date: Date) {
        let key = "advice:\(dateString(date))"
        if let data = try? JSONEncoder().encode(advice) {
            defaults.set(data, forKey: key)
        }
    }
    
    func loadAdvice(for date: Date) -> DailyAdvice? {
        let key = "advice:\(dateString(date))"
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(DailyAdvice.self, from: data)
    }
    
    func hasValidAdvice(for date: Date) -> Bool {
        loadAdvice(for: date) != nil
    }
    
    // 環境データキャッシュ（1時間有効）
    func saveEnvironmentData(_ data: EnvironmentResponse) {
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: "environmentData")
            defaults.set(Date(), forKey: "environmentData:timestamp")
        }
    }
    
    func loadEnvironmentData() -> EnvironmentResponse? {
        guard let data = defaults.data(forKey: "environmentData"),
              let timestamp = defaults.object(forKey: "environmentData:timestamp") as? Date,
              Date().timeIntervalSince(timestamp) < 3600 else { return nil }
        return try? JSONDecoder().decode(EnvironmentResponse.self, from: data)
    }
    
    // トライ履歴（14日間）
    func saveDailyTry(_ title: String, date: Date) {
        var tries = loadRecentDailyTries()
        let dateStr = dateString(date, format: "MM/dd")
        tries.removeAll { $0.date == dateStr }
        tries.append(RecentTry(date: dateStr, title: title))
        
        // 14日以上前を削除
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        tries = tries.filter { parseDate($0.date) ?? Date() >= twoWeeksAgo }
        
        if let data = try? JSONEncoder().encode(tries) {
            defaults.set(data, forKey: "dailyTries")
        }
    }
    
    func loadRecentDailyTries() -> [RecentTry] {
        guard let data = defaults.data(forKey: "dailyTries") else { return [] }
        return (try? JSONDecoder().decode([RecentTry].self, from: data)) ?? []
    }
    
    // ユーザープロフィール
    func saveUserProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: "userProfile")
        }
    }
    
    func loadUserProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: "userProfile") else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    // ヘルパー
    private func dateString(_ date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    private func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.date(from: string)
    }
}
```

---

## 3. ViewModel修正

### HomeViewModel

```swift
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var dailyAdvice: DailyAdvice?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOffline = false
    
    private let api = APIClient.shared
    private let cache = CacheManager.shared
    private let healthKit = HealthKitManager.shared
    private let location = LocationManager.shared
    
    func loadAdvice() async {
        let today = Date()
        
        // キャッシュ確認
        if let cached = cache.loadAdvice(for: today) {
            dailyAdvice = cached
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let profile = cache.loadUserProfile()!
            let healthData = try await healthKit.fetchHealthData()
            let loc = await location.getCurrentLocation()
            let scores = calculateScores(from: healthData)
            let stability = calculateRhythmStability(from: healthData)
            let factors = await calculateFactors(healthData: healthData, location: loc)
            let recentTries = cache.loadRecentDailyTries()
            
            let request = AdviceRequest(
                profile: profile, healthData: healthData, location: loc,
                scores: scores, rhythmStability: stability, factors: factors,
                recentDailyTries: recentTries
            )
            
            let response = try await api.fetchDailyAdvice(request: request)
            cache.saveAdvice(response.advice, for: today)
            cache.saveDailyTry(response.advice.dailyTry.title, date: today)
            dailyAdvice = response.advice
            isOffline = false
            
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        if (error as NSError).domain == NSURLErrorDomain {
            isOffline = true
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            if let cached = cache.loadAdvice(for: yesterday) {
                dailyAdvice = cached
                errorMessage = "オフラインのため、前日のアドバイスを表示しています"
            } else {
                errorMessage = "インターネット接続を確認してください"
            }
        } else {
            errorMessage = (error as? APIError)?.localizedDescription ?? "エラーが発生しました"
        }
    }
}
```

---

## 4. オフライン対応

```swift
struct OfflineBannerView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
            Text(message)
                .font(.subheadline)
            Spacer()
            Button("再試行", action: onRetry)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
        }
        .foregroundColor(.white)
        .padding(12)
        .background(Color.orange)
    }
}

// HomeViewでの使用
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isOffline {
                OfflineBannerView(message: viewModel.errorMessage ?? "オフライン") {
                    Task { await viewModel.loadAdvice() }
                }
            }
            
            ScrollView {
                // コンテンツ
            }
        }
        .task { await viewModel.loadAdvice() }
    }
}
```

---

## 5. Mockデータ削除

```bash
# 削除対象
rm -rf ios/TempoAI/Mocks/

# 参照確認
grep -r "MockData" ios/TempoAI/
grep -r "Mock" ios/TempoAI/Features/
```

---

## 6. テスト観点

### API接続
- [ ] アドバイス生成APIが正常動作
- [ ] 環境データAPIが正常動作
- [ ] エラー時に適切なメッセージ表示

### キャッシュ
- [ ] アドバイスが正しくキャッシュされる
- [ ] 同日2回目でキャッシュ使用
- [ ] 日付変更で新規生成
- [ ] トライ履歴14日間保持

### オフライン
- [ ] オフラインバナー表示
- [ ] 前日キャッシュ表示
- [ ] 再試行動作

---

## 関連ドキュメント

- `technical-spec.md` - セクション2「データフロー」
- `product-spec.md` - セクション7,8

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-19 | 初版作成 |
