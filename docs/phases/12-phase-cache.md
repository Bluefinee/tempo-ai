# Phase 12: キャッシュ・状態管理設計書

**フェーズ**: 12 / 15  
**Part**: C（結合・調整）  
**前提フェーズ**: Phase 11（UI結合・調整）

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

1. **CacheManager**の本格実装
2. **時間帯判定ロジック**（朝・昼・夕）
3. **同日キャッシュ**（TTL: 24時間）
4. **オフラインフォールバック**（前日アドバイス表示）

---

## 完了条件

- [ ] 同日2回目以降のアプリ起動でキャッシュが使われる
- [ ] 時間帯に応じた挨拶が表示される
- [ ] オフライン時に前日のアドバイスが表示される
- [ ] キャッシュの有効期限が正しく機能する
- [ ] 日付が変わるとキャッシュが無効化される

---

## キャッシュ戦略

### キャッシュ対象

| データ | キャッシュ先 | TTL | キー |
|--------|-------------|-----|------|
| メインアドバイス | UserDefaults | 24時間 | `advice_{yyyy-MM-dd}` |
| 追加アドバイス（昼） | UserDefaults | 当日中 | `additional_afternoon_{yyyy-MM-dd}` |
| 追加アドバイス（夕） | UserDefaults | 当日中 | `additional_evening_{yyyy-MM-dd}` |
| ユーザープロフィール | UserDefaults | 永続 | `user_profile` |
| 今日のトライ履歴 | UserDefaults | 14日 | `daily_try_history` |
| 今週のトライ | UserDefaults | 7日 | `weekly_try_{yyyy-Www}` |

### キャッシュフロー

```
アプリ起動
    │
    ↓
今日の日付でキャッシュ検索
    │
    ├─ キャッシュあり & 有効期限内
    │      │
    │      ↓
    │   キャッシュから表示
    │
    └─ キャッシュなし or 期限切れ
           │
           ↓
       API呼び出し
           │
           ├─ 成功 → キャッシュ保存 → 表示
           │
           └─ 失敗 → フォールバック
                      │
                      ├─ 前日キャッシュあり → 前日表示
                      │
                      └─ なし → エラー画面
```

---

## CacheManager実装

### インターフェース

```swift
protocol CacheManagerProtocol {
    // アドバイス
    func loadAdvice(for date: Date) -> DailyAdvice?
    func saveAdvice(_ advice: DailyAdvice, for date: Date)
    func loadPreviousDayAdvice() -> DailyAdvice?
    
    // 追加アドバイス
    func loadAdditionalAdvice(for date: Date, timeSlot: TimeSlot) -> AdditionalAdvice?
    func saveAdditionalAdvice(_ advice: AdditionalAdvice, for date: Date, timeSlot: TimeSlot)
    
    // ユーザープロフィール
    func loadUserProfile() -> UserProfile?
    func saveUserProfile(_ profile: UserProfile)
    
    // トライ履歴
    func getRecentDailyTries(days: Int) -> [String]
    func saveDailyTry(_ topic: String, for date: Date)
    func getLastWeeklyTry() -> String?
    func saveWeeklyTry(_ topic: String, for weekOf: Date)
    
    // キャッシュ管理
    func clearExpiredCache()
    func clearAllCache()
}
```

### 実装クラス

```swift
final class CacheManager: CacheManagerProtocol {
    private let userDefaults: UserDefaults
    private let dateFormatter: DateFormatter
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    // キー生成
    private func adviceKey(for date: Date) -> String {
        "advice_\(dateFormatter.string(from: date))"
    }
    
    private func additionalAdviceKey(for date: Date, timeSlot: TimeSlot) -> String {
        "additional_\(timeSlot.rawValue)_\(dateFormatter.string(from: date))"
    }
}
```

---

## 時間帯判定

### 時間帯定義

| 時間帯 | 開始 | 終了 | 用途 |
|--------|------|------|------|
| 朝（morning） | 6:00 | 12:59 | メインアドバイス生成 |
| 昼（afternoon） | 13:00 | 17:59 | 追加アドバイス（昼） |
| 夕（evening） | 18:00 | 翌5:59 | 追加アドバイス（夕） |

### 実装

```swift
enum TimeSlot: String, Codable {
    case morning
    case afternoon
    case evening
    
    static func current(at date: Date = Date()) -> TimeSlot {
        let hour = Calendar.current.component(.hour, from: date)
        
        switch hour {
        case 6..<13:
            return .morning
        case 13..<18:
            return .afternoon
        default:
            return .evening
        }
    }
    
    var greeting: String {
        switch self {
        case .morning:
            return "おはようございます"
        case .afternoon:
            return "こんにちは"
        case .evening:
            return "お疲れさまです"
        }
    }
}
```

### 挨拶の組み立て

```swift
func buildGreeting(nickname: String, timeSlot: TimeSlot) -> String {
    "\(nickname)さん、\(timeSlot.greeting)"
}
```

---

## 同日キャッシュ

### キャッシュ判定ロジック

```swift
func shouldFetchNewAdvice(for date: Date) -> Bool {
    guard let cached = loadAdvice(for: date) else {
        return true // キャッシュなし
    }
    
    // 生成時刻から24時間以内か
    guard let generatedAt = ISO8601DateFormatter().date(from: cached.generatedAt) else {
        return true // パースエラー
    }
    
    let hoursSinceGeneration = Date().timeIntervalSince(generatedAt) / 3600
    return hoursSinceGeneration >= 24
}
```

### 日付変更の検知

```swift
func isNewDay(since lastCheck: Date) -> Bool {
    !Calendar.current.isDate(Date(), inSameDayAs: lastCheck)
}
```

---

## オフラインフォールバック

### フォールバック優先順位

1. 今日のキャッシュ（あれば）
2. 昨日のキャッシュ
3. 一昨日のキャッシュ
4. 汎用フォールバックメッセージ

### 実装

```swift
func loadFallbackAdvice() -> DailyAdvice? {
    let today = Date()
    
    // 今日のキャッシュ
    if let todayAdvice = loadAdvice(for: today) {
        return todayAdvice
    }
    
    // 昨日のキャッシュ
    if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
       let yesterdayAdvice = loadAdvice(for: yesterday) {
        return yesterdayAdvice
    }
    
    // 一昨日のキャッシュ
    if let dayBefore = Calendar.current.date(byAdding: .day, value: -2, to: today),
       let dayBeforeAdvice = loadAdvice(for: dayBefore) {
        return dayBeforeAdvice
    }
    
    return nil
}
```

### フォールバック表示時のUI

前日のアドバイスを表示する際:

```
┌─────────────────────────────────────┐
│ ⚠️ オフライン                        │
│                                     │
│ 最新のアドバイスを取得できません。    │
│ 前回のアドバイスを表示しています。    │
│                                     │
│ [再読み込み]                        │
└─────────────────────────────────────┘

（以下、前日のアドバイス表示）
```

---

## トライ履歴管理

### 今日のトライ履歴

過去14日間のトピックを保存し、重複を防ぐ。

```swift
struct DailyTryHistory: Codable {
    var entries: [DailyTryEntry]
    
    struct DailyTryEntry: Codable {
        let topic: String
        let date: Date
    }
    
    mutating func add(topic: String, for date: Date) {
        entries.append(DailyTryEntry(topic: topic, date: date))
        
        // 14日以上前のエントリを削除
        let cutoff = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        entries = entries.filter { $0.date >= cutoff }
    }
    
    func recentTopics(days: Int) -> [String] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        return entries
            .filter { $0.date >= cutoff }
            .map { $0.topic }
    }
}
```

### 今週のトライ

週単位（月曜〜日曜）で管理。

```swift
func weekKey(for date: Date) -> String {
    let calendar = Calendar.current
    let weekOfYear = calendar.component(.weekOfYear, from: date)
    let year = calendar.component(.yearForWeekOfYear, from: date)
    return "weekly_try_\(year)-W\(String(format: "%02d", weekOfYear))"
}
```

---

## キャッシュクリーンアップ

### 自動クリーンアップ

アプリ起動時に古いキャッシュを削除:

```swift
func clearExpiredCache() {
    let allKeys = userDefaults.dictionaryRepresentation().keys
    
    for key in allKeys {
        if key.hasPrefix("advice_") || key.hasPrefix("additional_") {
            // 日付部分を抽出してチェック
            if let dateString = extractDateFromKey(key),
               let cacheDate = dateFormatter.date(from: dateString),
               shouldDeleteCache(for: cacheDate) {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}

private func shouldDeleteCache(for date: Date) -> Bool {
    let daysSinceCache = Calendar.current.dateComponents(
        [.day],
        from: date,
        to: Date()
    ).day ?? 0
    
    return daysSinceCache > 7 // 7日以上前のキャッシュを削除
}
```

### 手動クリア

設定画面から全キャッシュをクリア（デバッグ用、または将来の機能）:

```swift
func clearAllCache() {
    let allKeys = userDefaults.dictionaryRepresentation().keys
    
    for key in allKeys {
        if key.hasPrefix("advice_") ||
           key.hasPrefix("additional_") ||
           key.hasPrefix("daily_try_") ||
           key.hasPrefix("weekly_try_") {
            userDefaults.removeObject(forKey: key)
        }
    }
}
```

---

## 状態管理との連携

### HomeViewModelでの使用

```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var advice: DailyAdvice?
    @Published var isLoading = false
    @Published var isOffline = false
    @Published var showingCachedAdvice = false
    
    private let cacheManager: CacheManagerProtocol
    
    func loadAdvice() async {
        isLoading = true
        defer { isLoading = false }
        
        let today = Date()
        
        // キャッシュ確認
        if let cached = cacheManager.loadAdvice(for: today) {
            advice = cached
            showingCachedAdvice = false
            return
        }
        
        // API呼び出し
        do {
            let newAdvice = try await fetchAdviceFromAPI()
            cacheManager.saveAdvice(newAdvice, for: today)
            advice = newAdvice
            showingCachedAdvice = false
        } catch {
            // フォールバック
            if let fallback = cacheManager.loadFallbackAdvice() {
                advice = fallback
                showingCachedAdvice = true
                isOffline = true
            }
        }
    }
}
```

---

## テスト観点

### 正常系

- 初回起動 → API呼び出し → キャッシュ保存
- 2回目起動（同日） → キャッシュ使用 → API呼び出しなし
- 日付変更後 → 新規API呼び出し

### オフライン系

- オフライン + キャッシュあり → キャッシュ表示
- オフライン + キャッシュなし → エラー表示

### 時間帯系

- 6:00〜12:59 → morning判定
- 13:00〜17:59 → afternoon判定
- 18:00〜5:59 → evening判定

### クリーンアップ系

- 7日以上前のキャッシュが削除される
- 14日以上前のトライ履歴が削除される

---

## 今後のフェーズとの関係

### Phase 12で使用

- 追加アドバイスのキャッシュ
- 時間帯に基づく追加アドバイス表示

### Phase 13で使用

- オフラインエラー画面との連携

---

## 関連ドキュメント

- `technical-spec.md` - セクション2.4「キャッシュ戦略」
- `product-spec.md` - セクション6「キャッシュ戦略」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
