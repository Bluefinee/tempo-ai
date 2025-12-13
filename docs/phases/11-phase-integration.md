# Phase 11: UI結合・調整設計書

**フェーズ**: 11 / 15
**Part**: C（結合・調整）
**前提フェーズ**: Phase 1〜6（iOS UI）、Phase 7〜10（Backend）

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

1. **Mockデータの削除**と実APIへの切り替え
2. **実APIレスポンス**とUIの接続
3. **レイアウト調整**（文長変動への対応）
4. **データバインディング**の確認

---

## 完了条件

- [ ] 全画面でMockデータが削除されている
- [ ] ホーム画面が実APIからのアドバイスを表示している
- [ ] アドバイスの文長が変動しても崩れない
- [ ] action_suggestionsの数が変動しても正しく表示される
- [ ] HealthKitデータがAPIリクエストに含まれている
- [ ] 位置情報がAPIリクエストに含まれている

---

## 結合対象一覧

| 画面/コンポーネント | データソース | 結合内容 |
|-------------------|-------------|---------|
| ホーム画面ヘッダー | UserDefaults | ニックネーム |
| アドバイスサマリー | API | condition.summary |
| メトリクスカード | HealthKit | 各指標のスコア |
| 今日のトライ | API | daily_try |
| 今週のトライ | API | weekly_try |
| アドバイス詳細 | API | condition.detail, action_suggestions |
| メトリクス詳細 | HealthKit | 詳細データ |
| 設定画面 | UserDefaults | プロフィール情報 |

---

## Mockデータ削除

### 削除対象ファイル

- `MockData.swift`（または同等のMock定義）
- `MockAdvice.swift`
- `MockMetrics.swift`

### 削除手順

1. Mockを参照している箇所を特定
2. 実データ取得ロジックに置き換え
3. Mockファイルを削除
4. ビルド確認

---

## API接続

### データフロー

```
アプリ起動
    │
    ↓
HomeView表示
    │
    ├─ CacheManager.loadAdvice(for: today)
    │      │
    │      ├─ キャッシュあり → アドバイス表示
    │      │
    │      └─ キャッシュなし
    │              │
    │              ↓
    │         HealthKitManager.fetchTodayHealthData()
    │              │
    │              ↓
    │         LocationManager.requestCurrentLocation()
    │              │
    │              ↓
    │         APIClient.generateAdvice(request)
    │              │
    │              ↓
    │         CacheManager.saveAdvice()
    │              │
    │              ↓
    │         アドバイス表示
    │
    └─ HealthKitManager.fetchMetrics() → メトリクス表示
```

### APIリクエスト組み立て

```swift
func buildAdviceRequest() async throws -> AdviceRequest {
    let profile = cacheManager.loadUserProfile()
    let healthData = try await healthKitManager.fetchTodayHealthData()
    let location = try await locationManager.getCurrentLocation()
    
    return AdviceRequest(
        userProfile: profile.toAPIModel(),
        healthData: healthData.toAPIModel(),
        location: LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            city: location.cityName
        ),
        context: RequestContext(
            currentTime: Date().iso8601String,
            dayOfWeek: Date().dayOfWeekString,
            isMonday: Date().isMonday,
            recentDailyTries: cacheManager.getRecentDailyTries(days: 14),
            lastWeeklyTry: cacheManager.getLastWeeklyTry()
        )
    )
}
```

---

## レイアウト調整

### 調整が必要な箇所

1. **condition.summary**
   - 3〜5文で変動
   - カード高さを可変に
   - テキスト折り返し対応

2. **condition.detail**
   - 5〜8文で変動
   - スクロール対応済みだが確認

3. **action_suggestions**
   - 3〜5個で変動
   - 動的リスト表示
   - アイコンマッピング確認

4. **daily_try.detail / weekly_try.detail**
   - 長文になる場合あり
   - 改行（\n）の処理確認

### 調整方針

- **固定高さは避ける**: コンテンツに応じて伸縮
- **最小高さは設定可**: 見た目の安定性のため
- **最大行数は設定しない**: 全文表示を優先
- **テキスト切り詰め（...）は使わない**: 詳細画面で全文表示

### 確認用テストケース

| ケース | summary | action_suggestions | daily_try |
|--------|---------|-------------------|-----------|
| 最小 | 3文 | 3個 | 短め |
| 標準 | 4文 | 4個 | 標準 |
| 最大 | 5文 | 5個 | 長め |

---

## データバインディング

### SwiftUIでの実装パターン

```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var advice: DailyAdvice?
    @Published var metrics: MetricsData?
    @Published var isLoading: Bool = false
    @Published var error: TempoError?
    
    private let apiClient: APIClient
    private let healthKitManager: HealthKitManager
    private let cacheManager: CacheManager
    
    func loadAdvice() async {
        isLoading = true
        defer { isLoading = false }
        
        // キャッシュ確認
        if let cached = cacheManager.loadAdvice(for: Date()) {
            advice = cached
            return
        }
        
        // API呼び出し
        do {
            let request = try await buildAdviceRequest()
            let response = try await apiClient.generateAdvice(request: request)
            advice = response
            cacheManager.saveAdvice(response, for: Date())
        } catch {
            self.error = TempoError.from(error)
        }
    }
}
```

### View側

```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                LoadingView()
            } else if let advice = viewModel.advice {
                AdviceSummaryCard(advice: advice)
                MetricsGridView(metrics: viewModel.metrics)
                DailyTryCard(tryContent: advice.dailyTry)
                // ...
            } else if let error = viewModel.error {
                ErrorView(error: error)
            }
        }
        .task {
            await viewModel.loadAdvice()
        }
    }
}
```

---

## ニックネームの動的反映

APIレスポンスの `greeting` には `〇〇さん` の形式でニックネームが含まれる。

### 確認ポイント

- API側でニックネームが正しく埋め込まれているか
- 日本語の敬称（さん）が正しく表示されるか
- 長いニックネームでもレイアウトが崩れないか

---

## メトリクスデータの接続

### HealthKit → メトリクスカード

```swift
struct MetricsData {
    let recovery: MetricValue    // HRVベース
    let sleep: MetricValue       // 睡眠データベース
    let energy: MetricValue      // 歩数・運動ベース
    let stress: MetricValue      // HRV・心拍数ベース
}

struct MetricValue {
    let score: Int          // 0-100
    let status: String      // "最高", "良好", etc.
    let rawValue: Double?   // 元の数値（オプション）
}
```

### スコア計算ロジック

各指標のスコア計算はPhase 1で実装済みのHealthKitManagerを使用。
詳細なロジックはPhase 5のメトリクス詳細画面で使用するものと共通。

---

## エラー状態の接続

### エラー種別と表示

| エラー | 表示 |
|--------|------|
| ネットワークエラー | 「接続を確認してください」+ キャッシュ表示 |
| API エラー | 「一時的なエラー」+ フォールバック |
| HealthKit データ不足 | 「データ不足」メッセージ |
| 位置情報エラー | 都市選択ダイアログ（Phase 13で実装） |

このフェーズでは基本的な接続のみ。詳細なエラーハンドリングはPhase 13で実装。

---

## テスト観点

### 正常系

- アプリ起動 → API呼び出し → アドバイス表示
- キャッシュあり → API呼び出しなし → キャッシュ表示
- 各詳細画面への遷移 → 正しいデータ表示

### 異常系

- オフライン → エラー表示 or キャッシュ表示
- API失敗 → フォールバック表示

### レイアウト確認

- 短文アドバイスでの表示
- 長文アドバイスでの表示
- action_suggestions 3個の場合
- action_suggestions 5個の場合

---

## 今後のフェーズとの関係

### Phase 12で追加

- キャッシュ戦略の本格実装
- 時間帯判定

### Phase 13で追加

- 追加アドバイスの表示制御

### Phase 14で追加

- 詳細なエラーハンドリング

---

## 関連ドキュメント

- `technical-spec.md` - セクション2「iOS設計」
- `ui-spec.md` - セクション6「ホーム画面」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
