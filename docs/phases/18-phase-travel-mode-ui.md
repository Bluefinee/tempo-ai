# Phase 18: トラベルモードUI設計書

**フェーズ**: 18 / 19  
**Part**: E（トラベルモード）  
**前提フェーズ**: Phase 17（ロケーション管理・履歴）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI設計指針
- **[UI Specification](../ui-spec.md)** - UI設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書
- **[Travel Mode & Condition Spec](../travel-mode-condition-spec.md)** - トラベルモード詳細仕様

### 📱 Swift/iOS専用資料
- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX設計原則
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準

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

1. **ホーム画面のトラベルモード表示**
2. **コンディション画面の環境差分セクション**
3. **環境差分詳細画面**
4. **「適応の目安」セクション**
5. **ホーム画面ヘッダーのトラベルモードインジケーター**

---

## 完了条件

- [ ] トラベルモードON時にホーム画面ヘッダーにインジケーターが表示される
- [ ] コンディション画面に環境差分セクションが追加される
- [ ] 環境差分詳細画面で Home / Current / Previous の比較が表示される
- [ ] 「適応の目安」セクションが表示される（AI生成はPhase 19）
- [ ] トラベルモードOFF時は通常表示のまま

---

## UI変更一覧

### トラベルモードON時の変更

| 画面 | 変更内容 |
|------|---------|
| ホーム画面ヘッダー | トラベルモードインジケーター追加 |
| ホーム画面 | 「適応の目安」セクション追加 |
| コンディション画面 | 環境差分セクション追加（トップ） |
| サーカディアンリズム詳細 | 「今日のリセットポイント」追加（Phase 19） |

---

## ホーム画面ヘッダーの変更

### 通常モード

```
┌─────────────────────────────────────────┐
│ 12月11日（木）                   東京    │
│ まさかずさん、おはようございます          │
└─────────────────────────────────────────┘
```

### トラベルモードON

```
┌─────────────────────────────────────────┐
│ 12月11日（木）            ✈️ ニューヨーク │ ← インジケーター
│ まさかずさん、おはようございます          │
│ 🌐 東京から -14時間                      │ ← 時差表示
└─────────────────────────────────────────┘
```

### 実装

```swift
struct HomeHeaderView: View {
    let date: Date
    let nickname: String
    let greeting: String
    let currentCity: String
    let travelContext: TravelContext?  // トラベルモードON時のみ
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 日付 + 都市
            HStack {
                Text(date.formatted(.dateTime.month().day().weekday()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let context = travelContext {
                    // トラベルモードインジケーター
                    HStack(spacing: 4) {
                        Image(systemName: "airplane")
                            .font(.caption)
                        Text(currentCity)
                            .font(.subheadline)
                    }
                    .foregroundColor(.accentColor)
                } else {
                    Text(currentCity)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // 挨拶
            Text("\(nickname)さん、\(greeting)")
                .font(.title2)
                .fontWeight(.semibold)
            
            // 時差表示（トラベルモードON時のみ）
            if let context = travelContext, let offset = context.timezoneOffset {
                HStack(spacing: 4) {
                    Image(systemName: "globe")
                        .font(.caption)
                    Text("\(context.homeCity)から \(formatTimezoneOffset(offset))")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func formatTimezoneOffset(_ hours: Int) -> String {
        if hours > 0 {
            return "+\(hours)時間"
        } else if hours < 0 {
            return "\(hours)時間"
        } else {
            return "時差なし"
        }
    }
}

struct TravelContext {
    let homeCity: String
    let timezoneOffset: Int?
    let stayDays: Int
}
```

---

## 「適応の目安」セクション

### ホーム画面への追加

トラベルモードON時、アドバイスカードの下に表示:

```
┌─────────────────────────────────────────┐
│ 🔄 適応の目安                            │
│                                         │
│ ニューヨーク滞在 3日目                   │
│                                         │
│ 時差 -14時間の適応には                   │
│ 約7〜10日かかります。                    │
│                                         │
│ ████████░░░░░░░░░░░░  3/10日            │
│                                         │
│ 💡 西向き移動は体内時計を遅らせる        │
│    必要があり、比較的適応しやすいです    │
└─────────────────────────────────────────┘
```

### 実装

```swift
struct AdaptationProgressCard: View {
    let currentCity: String
    let stayDays: Int
    let timezoneOffset: Int
    let adaptationDays: Int  // 適応に必要な目安日数
    let hint: String?        // Phase 19でAI生成、それまでは固定
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("適応の目安")
                    .font(.headline)
            }
            
            // 滞在情報
            Text("\(currentCity)滞在 \(stayDays)日目")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 説明
            Text("時差 \(formatTimezoneOffset(timezoneOffset))の適応には\n約\(adaptationDays)日かかります。")
                .font(.body)
            
            // プログレスバー
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: Double(stayDays), total: Double(adaptationDays))
                    .tint(.accentColor)
                
                Text("\(stayDays)/\(adaptationDays)日")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // ヒント
            if let hint = hint {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.yellow)
                    Text(hint)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func formatTimezoneOffset(_ hours: Int) -> String {
        if hours > 0 {
            return "+\(hours)時間"
        } else {
            return "\(hours)時間"
        }
    }
}
```

### 適応日数の算出（仮ロジック）

Phase 19でAIが算出するまでの仮実装:

```swift
func estimateAdaptationDays(timezoneOffset: Int) -> Int {
    let absOffset = abs(timezoneOffset)
    
    // 一般的な目安: 1時間の時差につき約1日
    // ただし最低3日、最大14日
    return min(14, max(3, absOffset))
}
```

---

## コンディション画面の変更

### 環境差分セクションの追加

トラベルモードON時、コンディショントップの最上部に表示:

```
┌─────────────────────────────────────────┐
│ コンディション                 📅 今週 ▼│
├─────────────────────────────────────────┤
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🌍 環境の変化                   >   │ │ ← NEW（トップに追加）
│ │                                     │ │
│ │ 東京 → ニューヨーク                 │ │
│ │ 気温 -8°C / 時差 -14h / 湿度 +15%   │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ⏰ サーカディアンリズム         >   │ │
│ │ ...                                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ （以下、通常のセクション）              │
└─────────────────────────────────────────┘
```

### 環境差分セクションカード

```swift
struct EnvironmentDeltaSectionCard: View {
    let delta: EnvironmentDelta
    let homeCity: String
    let currentCity: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: "globe.asia.australia")
                    .foregroundColor(.accentColor)
                Text("環境の変化")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            // 移動経路
            Text("\(homeCity) → \(currentCity)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 主要な差分
            HStack(spacing: 16) {
                DeltaChip(
                    label: "気温",
                    value: formatDelta(delta.tempDiff, suffix: "°C")
                )
                DeltaChip(
                    label: "時差",
                    value: formatDelta(delta.timezoneOffset, suffix: "h")
                )
                DeltaChip(
                    label: "湿度",
                    value: formatDelta(delta.humidityDiff, suffix: "%")
                )
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func formatDelta(_ value: Int, suffix: String) -> String {
        if value > 0 {
            return "+\(value)\(suffix)"
        } else {
            return "\(value)\(suffix)"
        }
    }
}

struct DeltaChip: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
```

---

## 環境差分詳細画面

### 画面構成

```
┌─────────────────────────────────────────┐
│ ← 環境の変化                             │
├─────────────────────────────────────────┤
│                                         │
│ 📍 現在地: ニューヨーク                  │
│ 🏠 拠点: 東京                           │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 気温                                    │
│ ┌─────────────────────────────────────┐ │
│ │ 🏠 東京        12°C                 │ │
│ │ 📍 現在地       4°C                 │ │
│ │ 差分          -8°C                  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 時差                                    │
│ ┌─────────────────────────────────────┐ │
│ │ 🏠 東京       UTC+9                 │ │
│ │ 📍 現在地     UTC-5                 │ │
│ │ 差分         -14時間                │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 湿度                                    │
│ ┌─────────────────────────────────────┐ │
│ │ 🏠 東京        45%                  │ │
│ │ 📍 現在地      60%                  │ │
│ │ 差分         +15%                   │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 気圧                                    │
│ ┌─────────────────────────────────────┐ │
│ │ 🏠 東京       1018hPa               │ │
│ │ 📍 現在地     1012hPa               │ │
│ │ 差分          -6hPa                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 日の出・日没                            │
│ ┌─────────────────────────────────────┐ │
│ │ 🏠 東京       6:45 / 16:30          │ │
│ │ 📍 現在地     7:05 / 16:45          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 直前の滞在地                            │
│ ┌─────────────────────────────────────┐ │
│ │ 📍 ロサンゼルス（5日前まで）        │ │
│ │ 気温 18°C / UTC-8                   │ │
│ └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

### 実装

```swift
struct EnvironmentDeltaDetailView: View {
    let homeEnvironment: EnvironmentData
    let currentEnvironment: EnvironmentData
    let previousLocation: LocationEntry?
    let previousEnvironment: EnvironmentData?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ロケーション情報
                LocationHeader(
                    homeCity: homeEnvironment.city,
                    currentCity: currentEnvironment.city
                )
                
                Divider()
                
                // 気温
                ComparisonCard(
                    title: "気温",
                    homeValue: "\(homeEnvironment.temp)°C",
                    currentValue: "\(currentEnvironment.temp)°C",
                    delta: formatDelta(
                        currentEnvironment.temp - homeEnvironment.temp,
                        suffix: "°C"
                    )
                )
                
                // 時差
                ComparisonCard(
                    title: "時差",
                    homeValue: homeEnvironment.timezoneDisplay,
                    currentValue: currentEnvironment.timezoneDisplay,
                    delta: formatTimezoneOffset(
                        calculateTimezoneOffset(
                            from: homeEnvironment.timezone,
                            to: currentEnvironment.timezone
                        )
                    )
                )
                
                // 湿度
                ComparisonCard(
                    title: "湿度",
                    homeValue: "\(homeEnvironment.humidity)%",
                    currentValue: "\(currentEnvironment.humidity)%",
                    delta: formatDelta(
                        currentEnvironment.humidity - homeEnvironment.humidity,
                        suffix: "%"
                    )
                )
                
                // 気圧
                ComparisonCard(
                    title: "気圧",
                    homeValue: "\(homeEnvironment.pressure)hPa",
                    currentValue: "\(currentEnvironment.pressure)hPa",
                    delta: formatDelta(
                        currentEnvironment.pressure - homeEnvironment.pressure,
                        suffix: "hPa"
                    )
                )
                
                // 日の出・日没
                SunTimesCard(
                    homeData: homeEnvironment,
                    currentData: currentEnvironment
                )
                
                // 直前の滞在地（あれば）
                if let previous = previousLocation,
                   let prevEnv = previousEnvironment {
                    Divider()
                    PreviousLocationCard(
                        location: previous,
                        environment: prevEnv
                    )
                }
            }
            .padding()
        }
        .navigationTitle("環境の変化")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ComparisonCard: View {
    let title: String
    let homeValue: String
    let currentValue: String
    let delta: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "house")
                    Text("拠点")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(homeValue)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Image(systemName: "location")
                    Text("現在地")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(currentValue)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("差分")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(delta)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(8)
        }
    }
}
```

---

## ConditionViewの条件分岐

### トラベルモード判定

```swift
struct ConditionView: View {
    @StateObject private var viewModel = ConditionViewModel()
    @EnvironmentObject var travelModeManager: TravelModeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // トラベルモードON時のみ環境差分セクションを表示
                    if travelModeManager.isEnabled,
                       let delta = viewModel.environmentDelta {
                        NavigationLink {
                            EnvironmentDeltaDetailView(
                                homeEnvironment: viewModel.homeEnvironment,
                                currentEnvironment: viewModel.currentEnvironment,
                                previousLocation: viewModel.previousLocation,
                                previousEnvironment: viewModel.previousEnvironment
                            )
                        } label: {
                            EnvironmentDeltaSectionCard(
                                delta: delta,
                                homeCity: viewModel.homeCity,
                                currentCity: viewModel.currentCity
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // 通常のセクション（既存）
                    CircadianRhythmSectionCard(...)
                    HRVSectionCard(...)
                    SleepSectionCard(...)
                    ActivitySectionCard(...)
                    EnvironmentSectionCard(...)
                }
                .padding()
            }
            .navigationTitle("コンディション")
        }
    }
}
```

---

## 実装コンポーネント

### Views

```
Features/
├── Home/
│   └── Views/
│       ├── HomeHeaderView.swift              # 拡張
│       └── AdaptationProgressCard.swift      # NEW
│
└── Condition/
    └── Views/
        ├── ConditionView.swift               # 拡張
        ├── EnvironmentDeltaSectionCard.swift # NEW
        └── Detail/
            └── EnvironmentDeltaDetailView.swift # NEW
```

### ViewModels

```
Features/
└── Condition/
    └── ViewModels/
        └── ConditionViewModel.swift          # 拡張（環境差分取得）
```

---

## データフロー

```
トラベルモードON
    │
    ↓
LocationHistoryManager.locationContext
    │
    ├── home: HomeLocation
    ├── current: LocationEntry
    └── previous: LocationEntry?
    │
    ↓
EnvironmentDeltaService.calculateDelta()
    │
    ↓
EnvironmentDelta
    │
    ├── ConditionView → EnvironmentDeltaSectionCard
    │
    └── HomeView → AdaptationProgressCard
```

---

## テスト観点

### 正常系

- トラベルモードON → 環境差分セクション表示
- トラベルモードOFF → 環境差分セクション非表示
- 環境差分詳細画面で全項目が正しく表示
- Previous ありの場合の表示

### 異常系

- Home未設定時の表示
- 環境データ取得失敗時のフォールバック

### UI確認

- 時差の正負表示（+/-）
- 長い都市名でのレイアウト
- ダークモード対応

---

## 今後のフェーズとの関係

### Phase 19で追加・拡張

- 「適応の目安」のヒントをAI生成に置き換え
- サーカディアンリズム詳細に「今日のリセットポイント」追加
- アドバイス内容のトラベルモード対応

---

## 関連ドキュメント

- `17-phase-location-management.md` - ロケーション管理
- `05-phase-condition-top.md` - コンディショントップ画面
- `travel-mode-condition-spec.md` - トラベルモード詳細仕様

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-11 | 初版作成 |
