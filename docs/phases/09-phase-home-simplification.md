# Phase 9: ホーム画面シンプル化設計書

**フェーズ**: 9 / 15  
**Part**: C（新仕様への調整）  
**前提フェーズ**: Phase 3（ホーム画面UI - メトリクス・トライ）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[Product Spec v4.2](../product-spec.md)** - プロダクト仕様書（新仕様）
- **[UI Spec v3.2](../ui-spec.md)** - UI設計仕様書（新仕様）
- **[AI Prompt Spec v4.0](../ai-prompts/spec.md)** - AIプロンプト仕様書

### 🔧 iOS専用資料
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準
- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX設計原則

### ✅ 実装完了後の必須作業
実装完了後は必ず以下を実行してください：
```bash
# リント・フォーマット確認
swiftlint
swift-format --lint --recursive ios/

# テスト実行
swift test
```

---

## このフェーズで実現すること

Phase 3で実装した旧仕様のホーム画面を、新仕様に準拠するようシンプル化します。

**削除する要素**:
1. メトリクスカード4つ（回復・睡眠・エネルギー・ストレス）
2. 今週のトライカード
3. 追加アドバイス（昼・夕のフローティング吹き出し）

**残す要素**:
1. ヘッダー（日付、挨拶）
2. 今日のアドバイス（サマリー + 詳細へのタップ）
3. 今日のトライ

---

## 完了条件

- [ ] メトリクスカード4つが削除されている
- [ ] 今週のトライカードと関連ロジックが削除されている
- [ ] 追加アドバイス（フローティング吹き出し）が削除されている
- [ ] ホーム画面が「ヘッダー + アドバイス + トライ」の3要素のみで構成されている
- [ ] 削除した機能のコードが完全に除去されている（View、Model、ViewModel）
- [ ] UI Spec v3.2のホーム画面仕様に一致している

---

## 変更前後の比較

### 旧仕様（Phase 3完了時点）

```
┌─────────────────────────────────┐
│ ヘッダー（日付、挨拶）          │
├─────────────────────────────────┤
│ 今日のアドバイス               │
├─────────────────────────────────┤
│ ┌───────┐ ┌───────┐            │
│ │回復 78│ │睡眠 72│  ← 削除    │
│ └───────┘ └───────┘            │
│ ┌───────┐ ┌───────┐            │
│ │活力 81│ │ストレス│ ← 削除    │
│ └───────┘ └───────┘            │
├─────────────────────────────────┤
│ 今日のトライ                   │
├─────────────────────────────────┤
│ 今週のトライ（月曜のみ）← 削除  │
├─────────────────────────────────┤
│ 💬 フローティング吹き出し ← 削除│
└─────────────────────────────────┘
```

### 新仕様（Phase 9完了後）

```
┌─────────────────────────────────┐
│ ヘッダー（日付、挨拶）          │
├─────────────────────────────────┤
│                                 │
│ 今日のアドバイス               │
│ （サマリー表示）                │
│                                 │
│          [もっと見る]           │
│                                 │
├─────────────────────────────────┤
│                                 │
│ 今日のトライ                   │
│                                 │
└─────────────────────────────────┘
```

---

## 削除対象の詳細

### 1. メトリクスカード削除

**削除対象ファイル/コンポーネント**:

```
ios/TempoAI/Features/Home/Views/
├── MetricsGridView.swift        # 削除
├── MetricCardView.swift         # 削除
└── ...

ios/TempoAI/Features/Home/Models/
├── MetricItem.swift             # 削除
└── ...
```

**削除するUI要素**:
- 4つのメトリクスカード（回復・睡眠・エネルギー・ストレス）
- グリッドレイアウト
- スコア表示とプログレスリング

**注意**: メトリクス関連のロジックはPhase 12のコンディション画面で使用するため、`Shared/Models/`配下のモデルは保持。

### 2. 今週のトライ削除

**削除対象ファイル/コンポーネント**:

```
ios/TempoAI/Features/Home/Views/
├── WeeklyTryCardView.swift      # 削除
└── ...

ios/TempoAI/Features/Home/ViewModels/
└── HomeViewModel.swift          # 月曜判定ロジック削除

ios/TempoAI/Features/Detail/Views/
├── WeeklyTryDetailView.swift    # 削除（Phase 4で実装）
└── ...
```

**削除するロジック**:
- 月曜日判定（`isMonday`）
- 今週のトライ表示/非表示切り替え
- `WeeklyTry`モデルの参照

### 3. 追加アドバイス削除

**削除対象ファイル/コンポーネント**:

```
ios/TempoAI/Features/Home/Views/
├── AdditionalAdviceBubbleView.swift  # 削除
└── ...

ios/TempoAI/Features/Home/ViewModels/
└── HomeViewModel.swift               # 時間帯判定ロジック削除
```

**削除するロジック**:
- 時間帯判定（13時以降、18時以降）
- フローティング吹き出しの表示/非表示
- `AdditionalAdvice`モデルの参照

---

## 実装手順

### Step 1: Viewファイルの削除

```bash
# 削除対象ファイル一覧
rm ios/TempoAI/Features/Home/Views/MetricsGridView.swift
rm ios/TempoAI/Features/Home/Views/MetricCardView.swift
rm ios/TempoAI/Features/Home/Views/WeeklyTryCardView.swift
rm ios/TempoAI/Features/Home/Views/AdditionalAdviceBubbleView.swift
rm ios/TempoAI/Features/Detail/Views/WeeklyTryDetailView.swift
```

### Step 2: Modelファイルの整理

```bash
# ホーム専用モデルの削除
rm ios/TempoAI/Features/Home/Models/MetricItem.swift

# 注意: 以下は残す（コンディション画面で使用）
# - Shared/Models/HealthMetrics.swift
# - Shared/Models/DailyAdvice.swift
```

### Step 3: HomeViewの修正

**修正前**:
```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeaderView(...)
                AdviceSummaryCard(...)
                MetricsGridView(...)       // 削除
                DailyTryCard(...)
                if viewModel.isMonday {    // 削除
                    WeeklyTryCard(...)     // 削除
                }                          // 削除
            }
        }
        .overlay(alignment: .bottom) {     // 削除
            if viewModel.showAdditionalAdvice {  // 削除
                AdditionalAdviceBubbleView(...)  // 削除
            }                                     // 削除
        }                                         // 削除
    }
}
```

**修正後**:
```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                HeaderView(
                    date: viewModel.currentDate,
                    greeting: viewModel.greeting
                )
                
                // 今日のアドバイス
                AdviceSummaryCard(
                    advice: viewModel.dailyAdvice,
                    onTap: { viewModel.showAdviceDetail = true }
                )
                
                // 今日のトライ
                DailyTryCard(
                    dailyTry: viewModel.dailyTry,
                    onTap: { viewModel.showTryDetail = true }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(Color.backgroundPrimary)
        .sheet(isPresented: $viewModel.showAdviceDetail) {
            AdviceDetailView(advice: viewModel.dailyAdvice)
        }
        .sheet(isPresented: $viewModel.showTryDetail) {
            DailyTryDetailView(dailyTry: viewModel.dailyTry)
        }
    }
}
```

### Step 4: HomeViewModelの修正

**削除するプロパティ/メソッド**:
```swift
// 削除対象
@Published var isMonday: Bool = false
@Published var showAdditionalAdvice: Bool = false
@Published var additionalAdvice: AdditionalAdvice?
@Published var weeklyTry: WeeklyTry?

func checkIfMonday() { ... }           // 削除
func checkTimeForAdditionalAdvice() { ... }  // 削除
func fetchAdditionalAdvice() async { ... }   // 削除
```

**修正後のViewModel**:
```swift
@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var dailyAdvice: DailyAdvice?
    @Published var dailyTry: DailyTry?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var showAdviceDetail: Bool = false
    @Published var showTryDetail: Bool = false
    
    // MARK: - Computed Properties
    var currentDate: Date { Date() }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<13:
            return "おはようございます"
        case 13..<18:
            return "こんにちは"
        default:
            return "お疲れさまです"
        }
    }
    
    // MARK: - Methods
    func loadAdvice() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIClient.shared.fetchDailyAdvice()
            dailyAdvice = response.advice
            dailyTry = response.advice.dailyTry
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### Step 5: 不要な型定義の削除

**削除するAPIレスポンス型**:
```swift
// 削除対象（Shared/Models/AdditionalAdvice.swift）
struct AdditionalAdvice: Codable {
    let timeSlot: TimeSlot
    let message: String
}

// 削除対象（Shared/Models/WeeklyTry.swift）
struct WeeklyTry: Codable {
    let title: String
    let summary: String
    let detail: String
    let category: TryCategory
}
```

### Step 6: APIClientの修正

**削除するメソッド**:
```swift
// 削除対象
func fetchAdditionalAdvice(timeSlot: TimeSlot) async throws -> AdditionalAdvice
func fetchWeeklyTry() async throws -> WeeklyTry
```

---

## レイアウト調整

### スペーシング

| 要素間 | 値 |
|--------|-----|
| ヘッダー → アドバイス | 24pt |
| アドバイス → トライ | 24pt |
| 画面端からの余白 | 16pt |
| 上下の余白 | 24pt |

### アドバイスカードの拡張

メトリクスカードが削除されたことで、アドバイスカードにより多くのスペースを割り当てます。

```swift
struct AdviceSummaryCard: View {
    let advice: DailyAdvice?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // コンディションサマリー（3-4文）
                Text(advice?.condition.summary ?? "")
                    .font(.body)
                    .foregroundColor(.textPrimary)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                
                // もっと見るリンク
                HStack {
                    Spacer()
                    Text("もっと見る")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

---

## 削除するテストコード

```bash
# 削除対象テストファイル
rm ios/TempoAITests/Features/Home/MetricsGridViewTests.swift
rm ios/TempoAITests/Features/Home/WeeklyTryCardViewTests.swift
rm ios/TempoAITests/Features/Home/AdditionalAdviceBubbleViewTests.swift
rm ios/TempoAITests/Features/Detail/WeeklyTryDetailViewTests.swift
```

---

## 確認チェックリスト

### UI確認

- [ ] ホーム画面にメトリクスカードが表示されていない
- [ ] ホーム画面に今週のトライが表示されていない
- [ ] フローティング吹き出しが表示されていない
- [ ] ヘッダー → アドバイス → トライの順で表示されている
- [ ] スクロールが正常に動作する
- [ ] 各カードのタップで詳細画面に遷移する

### コード確認

- [ ] 削除対象のファイルがすべて除去されている
- [ ] Xcodeプロジェクトから参照が削除されている
- [ ] コンパイルエラーがない
- [ ] 未使用のimport文がない

### 機能確認

- [ ] アドバイス詳細画面への遷移が動作する
- [ ] トライ詳細画面への遷移が動作する
- [ ] 時間帯による挨拶が正しく表示される

---

## 今後のフェーズとの関係

### Phase 10（Backend調整）

- 追加アドバイス生成ロジックの削除
- 今週のトライ生成ロジックの削除
- `condition_insight`の追加

### Phase 11（タブバー拡張）

- ホーム画面は変更なし
- コンディションタブの追加のみ

### Phase 12（コンディショントップ）

- メトリクス表示はコンディション画面で実装
- ホーム画面との重複を避ける設計

---

## 関連ドキュメント

- `ui-spec.md` - セクション6「ホーム画面」
- `product-spec.md` - セクション2「機能要件」
- `03-phase-home-metrics.md` - Phase 3詳細設計書（旧仕様）

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-19 | 初版作成 |
