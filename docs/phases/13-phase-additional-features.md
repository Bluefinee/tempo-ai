# Phase 13: 追加機能結合設計書

**フェーズ**: 13 / 15  
**Part**: C（結合・調整）  
**前提フェーズ**: Phase 11（UI結合）、Phase 12（キャッシュ・状態管理）

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

1. **追加アドバイス**の生成・表示（昼・夕）
2. **今日のトライ履歴管理**（重複防止）
3. **今週のトライ**（月曜判定）

---

## 完了条件

- [ ] 13時以降にアプリを開くと追加アドバイス（昼）が表示される
- [ ] 18時以降にアプリを開くと追加アドバイス（夕）が表示される
- [ ] 追加アドバイスは該当時間帯で1回のみ表示される
- [ ] 今日のトライが過去2週間と重複しない
- [ ] 月曜日に今週のトライが新規生成される
- [ ] 火〜日曜は今週のトライがコンパクト表示される

---

## 追加アドバイス機能

### 表示タイミング

| 時間帯 | 表示条件 |
|--------|---------|
| 昼 | 13:00〜17:59にアプリ起動、かつ当日未表示 |
| 夕 | 18:00〜翌5:59にアプリ起動、かつ当日未表示 |

### 表示判定ロジック

```swift
func shouldShowAdditionalAdvice(for timeSlot: TimeSlot, on date: Date) -> Bool {
    // 朝は追加アドバイスなし
    guard timeSlot != .morning else { return false }
    
    // 既に表示済みかチェック
    let key = additionalAdviceShownKey(for: date, timeSlot: timeSlot)
    return !userDefaults.bool(forKey: key)
}

func markAdditionalAdviceShown(for timeSlot: TimeSlot, on date: Date) {
    let key = additionalAdviceShownKey(for: date, timeSlot: timeSlot)
    userDefaults.set(true, forKey: key)
}

private func additionalAdviceShownKey(for date: Date, timeSlot: TimeSlot) -> String {
    "additional_shown_\(timeSlot.rawValue)_\(dateFormatter.string(from: date))"
}
```

### 生成フロー

```
アプリ起動（13:00以降）
    │
    ↓
TimeSlot.current() → afternoon or evening
    │
    ↓
shouldShowAdditionalAdvice() 判定
    │
    ├─ false → 表示しない
    │
    └─ true
         │
         ↓
    キャッシュ確認
         │
         ├─ キャッシュあり → キャッシュから表示
         │
         └─ キャッシュなし
              │
              ↓
         APIClient.generateAdditionalAdvice()
              │
              ↓
         キャッシュ保存
              │
              ↓
         フローティング吹き出し表示
              │
              ↓
         markAdditionalAdviceShown()
```

### API呼び出し

```swift
func generateAdditionalAdvice(
    userProfile: UserProfile,
    healthData: HealthData,
    timeSlot: TimeSlot,
    mainAdvice: DailyAdvice
) async throws -> AdditionalAdvice {
    let request = AdditionalAdviceRequest(
        userProfile: userProfile,
        healthData: healthData,
        timeSlot: timeSlot,
        morningAdviceSummary: mainAdvice.condition.summary
    )
    
    return try await apiClient.generateAdditionalAdvice(request: request)
}
```

### UI表示

```swift
struct AdditionalAdvicePopup: View {
    let advice: AdditionalAdvice
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("💬")
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                    }
                }
                
                Text(advice.message)
                    .font(.body)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(radius: 4)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
```

---

## 今日のトライ履歴管理

### 重複防止の仕組み

APIリクエストに過去2週間のトピックを含め、Claude側で重複を避ける。

### リクエストへの含め方

```swift
let context = RequestContext(
    currentTime: Date().iso8601String,
    dayOfWeek: Date().dayOfWeekString,
    isMonday: Date().isMonday,
    recentDailyTries: cacheManager.getRecentDailyTries(days: 14),
    lastWeeklyTry: cacheManager.getLastWeeklyTry()
)
```

### トピック抽出と保存

アドバイス受信後、トピックを履歴に保存:

```swift
func onAdviceReceived(_ advice: DailyAdvice) {
    // 今日のトライのトピックを保存
    let topic = advice.dailyTry.title
    cacheManager.saveDailyTry(topic, for: Date())
    
    // 今週のトライ（月曜のみ）
    if let weeklyTry = advice.weeklyTry {
        cacheManager.saveWeeklyTry(weeklyTry.title, for: Date())
    }
}
```

### 履歴データ構造

```swift
struct TryHistory: Codable {
    var dailyTries: [TryEntry]
    var weeklyTries: [WeeklyTryEntry]
    
    struct TryEntry: Codable {
        let topic: String
        let date: Date
    }
    
    struct WeeklyTryEntry: Codable {
        let topic: String
        let weekStart: Date // その週の月曜日
    }
}
```

---

## 今週のトライ

### 月曜判定

```swift
extension Date {
    var isMonday: Bool {
        Calendar.current.component(.weekday, from: self) == 2
    }
    
    var weekStart: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
}
```

### 表示ロジック

```swift
func getWeeklyTryDisplayMode() -> WeeklyTryDisplayMode {
    let today = Date()
    
    if today.isMonday {
        return .prominent // 目立つ表示
    } else {
        return .compact // コンパクト表示
    }
}

enum WeeklyTryDisplayMode {
    case prominent // 月曜日: 大きなカード、"NEW!"バッジ
    case compact   // 火〜日: 1行表示、タップで展開
}
```

### 月曜日の表示

```
┌─────────────────────────────────────┐
│ 📅 今週のトライ               NEW!  │
│                                     │
│ セサミオイルで足裏マッサージ        │
│                                     │
│ アーユルヴェーダの知恵で、          │
│ 深い眠りと自律神経の安定を          │
│                                     │
│                    [詳しく見る →]   │
└─────────────────────────────────────┘
```

### 火〜日曜日の表示

```
┌─────────────────────────────────────┐
│ 📅 今週のトライ: セサミオイルで...  │
└─────────────────────────────────────┘
```

### 実装

```swift
struct WeeklyTryCard: View {
    let tryContent: TryContent
    let displayMode: WeeklyTryDisplayMode
    
    var body: some View {
        switch displayMode {
        case .prominent:
            ProminentWeeklyTryCard(tryContent: tryContent)
        case .compact:
            CompactWeeklyTryCard(tryContent: tryContent)
        }
    }
}

struct ProminentWeeklyTryCard: View {
    let tryContent: TryContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📅 今週のトライ")
                    .font(.headline)
                Spacer()
                Text("NEW!")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
            
            Text(tryContent.title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(tryContent.summary)
                .font(.body)
                .foregroundColor(.secondary)
            
            // 詳しく見るボタン
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct CompactWeeklyTryCard: View {
    let tryContent: TryContent
    
    var body: some View {
        HStack {
            Text("📅 今週のトライ:")
                .font(.subheadline)
            Text(tryContent.title)
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}
```

---

## 週またぎの処理

### 今週のトライがない場合

火曜日以降にアプリを初めて起動した場合、今週のトライがnullで返される可能性がある。

```swift
func handleWeeklyTry(from advice: DailyAdvice) {
    if let weeklyTry = advice.weeklyTry {
        // 今週のトライあり → 表示
        showWeeklyTry(weeklyTry)
    } else if let cachedWeeklyTry = cacheManager.loadWeeklyTry(for: Date().weekStart) {
        // キャッシュから今週のトライを取得
        showWeeklyTry(cachedWeeklyTry)
    } else {
        // 今週のトライなし → 非表示
        hideWeeklyTry()
    }
}
```

---

## 状態管理

### HomeViewModelへの追加

```swift
@MainActor
class HomeViewModel: ObservableObject {
    // 既存
    @Published var advice: DailyAdvice?
    
    // 追加
    @Published var additionalAdvice: AdditionalAdvice?
    @Published var showAdditionalAdvicePopup = false
    @Published var weeklyTryDisplayMode: WeeklyTryDisplayMode = .compact
    
    func checkForAdditionalAdvice() async {
        let timeSlot = TimeSlot.current()
        let today = Date()
        
        guard cacheManager.shouldShowAdditionalAdvice(for: timeSlot, on: today) else {
            return
        }
        
        // キャッシュ確認
        if let cached = cacheManager.loadAdditionalAdvice(for: today, timeSlot: timeSlot) {
            additionalAdvice = cached
            showAdditionalAdvicePopup = true
            return
        }
        
        // API生成
        guard let mainAdvice = advice else { return }
        
        do {
            let additional = try await generateAdditionalAdvice(
                timeSlot: timeSlot,
                mainAdvice: mainAdvice
            )
            cacheManager.saveAdditionalAdvice(additional, for: today, timeSlot: timeSlot)
            additionalAdvice = additional
            showAdditionalAdvicePopup = true
        } catch {
            // 追加アドバイスの失敗はサイレントに
            print("Additional advice generation failed: \(error)")
        }
    }
    
    func dismissAdditionalAdvice() {
        showAdditionalAdvicePopup = false
        cacheManager.markAdditionalAdviceShown(for: TimeSlot.current(), on: Date())
    }
}
```

---

## テスト観点

### 追加アドバイス

- 13:00に起動 → 昼の追加アドバイス表示
- 13:00に再起動 → 表示されない（表示済み）
- 18:00に起動 → 夕の追加アドバイス表示
- 6:00に起動 → 追加アドバイスなし

### 今日のトライ

- 新規トピックが生成される
- 過去2週間のトピックと重複しない

### 今週のトライ

- 月曜日 → prominent表示、"NEW!"バッジ
- 火〜日曜 → compact表示
- 月曜日に新規生成される

---

## 今後のフェーズとの関係

### Phase 13

- 追加アドバイス生成失敗時のエラーハンドリング

### Phase 14

- 追加アドバイスポップアップのアニメーション調整

---

## 関連ドキュメント

- `product-spec.md` - セクション2.2〜2.4「トライ機能」「追加アドバイス」
- `ai-prompt-design.md` - セクション3「追加アドバイスプロンプト」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
