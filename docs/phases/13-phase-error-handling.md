# Phase 13: エラーハンドリング設計書

**フェーズ**: 13 / 14  
**Part**: D（仕上げ）  
**前提フェーズ**: Phase 10（UI結合）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI設計指針
- **[UI Specification](../ui-spec.md)** - UI設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書

### 📱 Swift/iOS専用資料
- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX設計原則
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準

### 🔧 Backend専用資料
- **[TypeScript Hono Standards](../../.claude/typescript-hono-standards.md)** - TypeScript + Hono 開発標準

### ✅ 実装完了後の必須作業
実装完了後は必ず以下を実行してください：

**iOS側**:
```bash
# リント・フォーマット確認
swiftlint
swift-format --lint --recursive ios/

# テスト実行
swift test
```

**Backend側**:
```bash
# TypeScript型チェック
npm run typecheck

# リント・フォーマット確認
npm run lint

# テスト実行
npm test
```

---

## このフェーズで実現すること

1. **エラー画面UI**の実装
2. **都市手動選択ダイアログ**の実装
3. **エラー状態の伝播**と適切な表示

---

## 完了条件

- [ ] オフライン時に適切なエラー画面が表示される
- [ ] HealthKitデータ不足時に説明メッセージが表示される
- [ ] 位置情報取得失敗時に都市手動選択ダイアログが表示される
- [ ] Claude APIエラー時にフォールバック表示される
- [ ] エラーからの復帰（再試行）が機能する

---

## エラー種別と対応

| エラー種別 | 原因 | ユーザーへの表示 | 対応アクション |
|-----------|------|-----------------|---------------|
| オフライン | ネットワーク接続なし | 「接続を確認してください」 | キャッシュ表示 + 再試行ボタン |
| HealthKitデータ不足 | 必須データがない | 「データが不足しています」 | 一般的アドバイス表示 |
| HealthKit権限なし | 権限が拒否された | 「設定から許可してください」 | 設定アプリへ誘導 |
| 位置情報エラー | 取得失敗 or 権限なし | 「位置情報を設定してください」 | 都市手動選択 |
| APIエラー | サーバーエラー | 「一時的なエラー」 | フォールバック + 再試行 |
| JSONパースエラー | 不正なレスポンス | 「一時的なエラー」 | フォールバック |

---

## エラー型定義

```swift
enum TempoError: Error {
    // ネットワーク
    case offline
    case networkError(underlying: Error)
    case timeout
    
    // HealthKit
    case healthKitNotAuthorized
    case healthKitDataInsufficient(missing: [HealthDataType])
    case healthKitUnavailable
    
    // 位置情報
    case locationNotAuthorized
    case locationUnavailable
    case locationTimeout
    
    // API
    case apiError(statusCode: Int, message: String?)
    case parseError(underlying: Error)
    case rateLimited
    
    // キャッシュ
    case cacheNotFound
    
    var isRecoverable: Bool {
        switch self {
        case .offline, .networkError, .timeout, .apiError, .rateLimited:
            return true
        case .healthKitNotAuthorized, .locationNotAuthorized:
            return false // 設定変更が必要
        default:
            return false
        }
    }
    
    var userMessage: String {
        switch self {
        case .offline:
            return "インターネットに接続されていません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .timeout:
            return "接続がタイムアウトしました"
        case .healthKitNotAuthorized:
            return "ヘルスケアデータへのアクセスが許可されていません"
        case .healthKitDataInsufficient:
            return "ヘルスケアデータが不足しています"
        case .healthKitUnavailable:
            return "ヘルスケアを利用できません"
        case .locationNotAuthorized:
            return "位置情報へのアクセスが許可されていません"
        case .locationUnavailable, .locationTimeout:
            return "位置情報を取得できませんでした"
        case .apiError:
            return "サーバーとの通信に失敗しました"
        case .parseError:
            return "データの処理に失敗しました"
        case .rateLimited:
            return "しばらく時間をおいてお試しください"
        case .cacheNotFound:
            return "データが見つかりません"
        }
    }
}
```

---

## エラー画面UI

### 基本構造

```
┌─────────────────────────────────────┐
│                                     │
│           [エラーアイコン]           │
│                                     │
│         エラーメッセージ            │
│                                     │
│         詳細説明（任意）            │
│                                     │
│         [プライマリアクション]       │
│         [セカンダリアクション]       │
│                                     │
└─────────────────────────────────────┘
```

### 実装

```swift
struct ErrorView: View {
    let error: TempoError
    let onRetry: (() -> Void)?
    let onSecondaryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            // アイコン
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            // メッセージ
            Text(error.userMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // 詳細説明
            if let detail = detailMessage {
                Text(detail)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // アクションボタン
            VStack(spacing: 12) {
                if let onRetry = onRetry, error.isRecoverable {
                    Button("再試行") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if let onSecondary = onSecondaryAction {
                    Button(secondaryActionTitle) {
                        onSecondary()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(32)
    }
    
    private var iconName: String {
        switch error {
        case .offline, .networkError, .timeout:
            return "wifi.slash"
        case .healthKitNotAuthorized, .healthKitDataInsufficient, .healthKitUnavailable:
            return "heart.slash"
        case .locationNotAuthorized, .locationUnavailable, .locationTimeout:
            return "location.slash"
        default:
            return "exclamationmark.triangle"
        }
    }
}
```

---

## オフライン時の処理

### フロー

```
API呼び出し失敗（オフライン）
    │
    ↓
キャッシュ確認
    │
    ├─ 今日のキャッシュあり → キャッシュ表示
    │
    ├─ 前日のキャッシュあり → 前日表示 + バナー
    │
    └─ キャッシュなし → エラー画面
```

### バナー表示

前日のキャッシュを表示する場合:

```swift
struct OfflineBanner: View {
    let onRetry: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
            Text("オフラインです。前回のアドバイスを表示しています")
                .font(.caption)
            Spacer()
            Button("再読み込み", action: onRetry)
                .font(.caption)
        }
        .padding()
        .background(Color.yellow.opacity(0.2))
    }
}
```

---

## HealthKitデータ不足時の処理

### 不足パターンと対応

| 不足データ | 影響 | 対応 |
|-----------|------|------|
| 睡眠データのみ | 睡眠関連アドバイス不可 | 他のデータでアドバイス生成 |
| HRVのみ | 回復・ストレス分析不可 | 心拍数で代替 |
| すべて不足 | パーソナライズ不可 | 一般的アドバイス + 説明 |

### 一般的アドバイスへのフォールバック

```swift
func handleInsufficientHealthData(missing: [HealthDataType]) {
    if missing.count >= 3 {
        // ほぼすべて不足 → 一般的アドバイス
        showGenericAdviceWithExplanation()
    } else {
        // 一部不足 → 利用可能なデータでアドバイス生成
        generateAdviceWithPartialData()
    }
}

func showGenericAdviceWithExplanation() {
    // メッセージカード表示
    let message = """
    ヘルスケアデータが不足しているため、
    パーソナライズされたアドバイスを生成できません。
    
    Apple Watchやヘルスケアアプリで
    データを記録すると、より詳細な
    アドバイスを受けられます。
    """
    
    showInfoCard(message: message)
    showGenericAdvice()
}
```

---

## 位置情報エラー時の処理

### 都市手動選択ダイアログ

```
┌─────────────────────────────────────┐
│                                     │
│     位置情報を設定してください       │
│                                     │
│ お住まいの都市を選択すると、        │
│ 天気情報を取得できます。            │
│                                     │
│ ┌─────────────────────────────┐    │
│ │ 🔍 都市を検索...             │    │
│ └─────────────────────────────┘    │
│                                     │
│ よく選ばれる都市:                   │
│ ┌─────────────────────────────┐    │
│ │ 東京                        │    │
│ │ 大阪                        │    │
│ │ 名古屋                      │    │
│ │ 福岡                        │    │
│ │ 札幌                        │    │
│ └─────────────────────────────┘    │
│                                     │
│ [スキップ]                [決定]   │
│                                     │
└─────────────────────────────────────┘
```

### 実装

```swift
struct CitySelectionSheet: View {
    @Binding var isPresented: Bool
    @State private var searchText = ""
    let onCitySelected: (City) -> Void
    let onSkip: () -> Void
    
    private let popularCities: [City] = [
        City(name: "東京", latitude: 35.6895, longitude: 139.6917),
        City(name: "大阪", latitude: 34.6937, longitude: 135.5023),
        City(name: "名古屋", latitude: 35.1815, longitude: 136.9066),
        City(name: "福岡", latitude: 33.5904, longitude: 130.4017),
        City(name: "札幌", latitude: 43.0618, longitude: 141.3545),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // 説明
                Text("お住まいの都市を選択すると、天気情報を取得できます。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                
                // 検索バー
                TextField("都市を検索...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                // 都市リスト
                List {
                    Section("よく選ばれる都市") {
                        ForEach(filteredCities, id: \.name) { city in
                            Button(city.name) {
                                onCitySelected(city)
                                isPresented = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("位置情報を設定")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("スキップ") {
                        onSkip()
                        isPresented = false
                    }
                }
            }
        }
    }
}
```

### スキップ時の動作

位置情報なしでアドバイス生成（天気・大気汚染関連のアドバイスは省略）。

---

## APIエラー時の処理

### 再試行ロジック

```swift
func fetchAdviceWithRetry(maxRetries: Int = 2) async throws -> DailyAdvice {
    var lastError: Error?
    
    for attempt in 0..<maxRetries {
        do {
            return try await apiClient.generateAdvice(request: request)
        } catch {
            lastError = error
            
            // 再試行可能なエラーかチェック
            if let tempoError = error as? TempoError,
               !tempoError.isRecoverable {
                throw error
            }
            
            // 待機（エクスポネンシャルバックオフ）
            let delay = pow(2.0, Double(attempt))
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
    
    throw lastError ?? TempoError.apiError(statusCode: 0, message: "Unknown error")
}
```

### フォールバックアドバイス

APIエラー時に表示する汎用アドバイス:

```swift
static let fallbackAdvice = DailyAdvice(
    greeting: "\(nickname)さん、こんにちは",
    condition: ConditionAdvice(
        summary: "今日も一日、あなたのペースで過ごしていきましょう。",
        detail: "アドバイスの生成に一時的な問題が発生しました。"
    ),
    actionSuggestions: [
        ActionSuggestion(
            icon: .hydration,
            title: "こまめな水分補給を",
            detail: "1日を通して、意識的に水分を補給しましょう。"
        ),
        ActionSuggestion(
            icon: .rest,
            title: "適度な休憩を",
            detail: "1時間に1回は立ち上がって、軽く体を動かしましょう。"
        )
    ],
    closingMessage: "また後でお試しください。",
    dailyTry: TryContent(
        title: "深呼吸を3回",
        summary: "ゆっくりと深呼吸をして、心を落ち着けてみませんか？",
        detail: "..."
    ),
    weeklyTry: nil,
    generatedAt: Date().iso8601String,
    timeSlot: .morning
)
```

---

## エラー状態の伝播

### ViewModelでのエラー管理

```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var advice: DailyAdvice?
    @Published var error: TempoError?
    @Published var isLoading = false
    @Published var showCitySelection = false
    @Published var isShowingCachedAdvice = false
    
    func loadAdvice() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let newAdvice = try await fetchAdviceWithRetry()
            advice = newAdvice
            isShowingCachedAdvice = false
        } catch let tempoError as TempoError {
            handleError(tempoError)
        } catch {
            handleError(TempoError.networkError(underlying: error))
        }
    }
    
    private func handleError(_ error: TempoError) {
        switch error {
        case .offline, .networkError, .timeout:
            // キャッシュフォールバック
            if let cached = cacheManager.loadFallbackAdvice() {
                advice = cached
                isShowingCachedAdvice = true
            } else {
                self.error = error
            }
            
        case .locationNotAuthorized, .locationUnavailable, .locationTimeout:
            // 都市選択ダイアログを表示
            showCitySelection = true
            
        case .healthKitDataInsufficient:
            // 一般的アドバイスで続行
            advice = Self.fallbackAdvice
            
        default:
            self.error = error
        }
    }
}
```

---

## テスト観点

### オフライン

- 機内モードでアプリ起動 → キャッシュ or エラー表示
- 再試行ボタンでリカバリ

### HealthKit

- 権限拒否 → 設定誘導
- データ不足 → 説明メッセージ

### 位置情報

- 権限拒否 → 都市選択ダイアログ
- 都市選択 → 気象データ取得成功

### API

- 500エラー → 再試行 → フォールバック
- タイムアウト → 再試行

---

## 関連ドキュメント

- `ui-spec.md` - セクション9「エラー・空状態」
- `technical-spec.md` - セクション7「エラーハンドリング」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
