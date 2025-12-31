# Phase 9: ホーム画面シンプル化

**ステータス**: 🔜 進行中
**作成日**: 2025-12-31
**目的**: ホーム画面を「ヘッダー + アドバイス + 今日のトライ」の3要素のみにシンプル化

---

## 概要

旧仕様（Phase 3）で実装した以下のコンポーネントを削除し、[ui-spec.md](../specs/ui-spec.md) セクション4に準拠した構成にする。

### 新仕様のホーム画面構成

```
┌─────────────────────────────┐
│ ヘッダー（日付、挨拶）       │
├─────────────────────────────┤
│ 今日のアドバイス（サマリー） │
│        [もっと見る]         │
├─────────────────────────────┤
│ 今日のトライ                │
└─────────────────────────────┘
```

---

## 削除対象

### ファイル削除（5個）

| ファイル | パス | 理由 |
|---------|------|------|
| MetricsGridView.swift | Features/Home/Views/ | メトリクスカード削除 |
| MetricCard.swift | Features/Home/Views/ | メトリクスカード削除 |
| WeeklyTryCard.swift | Features/Home/Views/ | 今週のトライ削除 |
| WeeklyTryDetailView.swift | Features/Home/Views/ | 今週のトライ詳細削除 |
| AdditionalAdvicePopup.swift | Features/Home/Views/ | 追加アドバイス削除 |

### 保持対象

| ファイル | 理由 |
|---------|------|
| DailyTryCard.swift | 今日のトライ（新仕様で保持） |
| DailyTryDetailView.swift | 今日のトライ詳細（新仕様で保持） |
| ActionSuggestionCard.swift | AdviceDetailViewで使用 |
| AdviceSummaryCard.swift | アドバイスサマリー（新仕様で保持） |
| HomeHeaderView.swift | ヘッダー（新仕様で保持） |

---

## 実装ステップ

### Stage 1: テストファイルの修正

**対象**: `ios/TempoAI/TempoAITests/HomeComponentsTests.swift`

削除箇所（Line 165-187）:
- `// MARK: - Phase 3 Component Tests` セクション全体
- `metricCardCreation()` テスト
- `metricsGridViewCreation()` テスト
- `metricsGridViewWithFourMetrics()` テスト

**確認**: テストがコンパイルできること

---

### Stage 2: Viewファイルの削除

以下5ファイルを削除:
1. `MetricsGridView.swift`
2. `MetricCard.swift`
3. `WeeklyTryCard.swift`
4. `WeeklyTryDetailView.swift`
5. `AdditionalAdvicePopup.swift`

**注意**: この時点でビルドエラーが発生（HomeViewが参照）→ Stage 3で解消

---

### Stage 3: HomeView.swift の修正

**対象**: `ios/TempoAI/TempoAI/Features/Home/Views/HomeView.swift`

#### 3.1 HomeNavigationDestination enum修正
```swift
// Before
enum HomeNavigationDestination: Hashable {
    case adviceDetail(DailyAdvice)
    case dailyTryDetail(TryContent)
    case weeklyTryDetail(TryContent)  // ← 削除
}

// After
enum HomeNavigationDestination: Hashable {
    case adviceDetail(DailyAdvice)
    case dailyTryDetail(TryContent)
}
```

#### 3.2 不要なプロパティ削除
```swift
// 削除対象
@State private var showAdditionalAdvice: Bool = false

private var isMonday: Bool {
    Calendar.current.component(.weekday, from: Date()) == 2
}
```

#### 3.3 body内修正

- MetricsGridView参照削除
- WeeklyTryCard参照削除
- AdditionalAdvicePopup参照削除
- navigationDestinationからweeklyTryDetailケース削除
- .task修飾子削除

#### 3.4 DailyTryCardを#if DEBUGの外に移動

修正後の構造:
```swift
ScrollView {
    VStack(spacing: 20) {
        AdviceSummaryCard(advice: mockAdvice) { ... }
            .padding(.horizontal, 24)
            .padding(.top, 8)

        DailyTryCard(tryContent: mockAdvice.dailyTry) { ... }
            .padding(.horizontal, 24)

        Spacer()
            .frame(height: 120)
    }
}
```

---

### Stage 4: MockData.swift の修正

**対象**: `ios/TempoAI/TempoAI/Shared/Models/MockData.swift`

#### 削除対象
- `MetricData` 構造体
- `MetricType` enum
- `mockMetrics` プロパティ
- `mockAdditionalAdvice` プロパティ

#### 保持対象
- `getCurrentGreeting()` - HomeHeaderViewで使用
- `mockWeather` - HomeHeaderViewで使用
- `getCurrentDateString()` - HomeHeaderViewで使用
- `WeatherInfo` 構造体

---

### Stage 5: 最終確認

```bash
# ビルド確認
cd ios/TempoAI && xcodebuild -scheme TempoAI -destination 'platform=iOS Simulator,name=iPhone 16' build

# テスト実行
cd ios/TempoAI && xcodebuild -scheme TempoAI -destination 'platform=iOS Simulator,name=iPhone 16' test
```

---

## 完了条件

- [ ] ホーム画面が「ヘッダー + アドバイス + トライ」の3要素のみ
- [ ] 削除した機能のコードが完全に除去
- [ ] [ui-spec.md](../specs/ui-spec.md) セクション4に一致
- [ ] ビルド成功
- [ ] 全テストパス

---

## 注意事項

1. **DailyAdvice.swift内のAdditionalAdvice構造体は削除しない** - APIレスポンスで使用
2. **ActionSuggestionCardは削除しない** - AdviceDetailViewで必須
3. **ファイル削除後はXcodeプロジェクトも確認** - project.pbxproj更新確認

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [product-spec.md](../specs/product-spec.md) | 機能要件 |
| [ui-spec.md](../specs/ui-spec.md) | UI/UX設計（セクション4参照） |
| [phases.md](./phases.md) | 開発フェーズ管理 |
