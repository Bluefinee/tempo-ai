# Phase 17: ロケーション管理・履歴設計書

**フェーズ**: 17 / 19  
**Part**: E（トラベルモード）  
**前提フェーズ**: Phase 16（トラベルモード基盤）

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

1. **ロケーション管理**（Home / Current / Previous）
2. **ロケーション履歴の記録**
3. **滞在日数のカウント**
4. **7日滞在でPreviousクリアのロジック**
5. **環境差分の算出基盤**

---

## 完了条件

- [ ] 現在地（Current）が正しく取得・記録される
- [ ] 拠点（Home）との距離判定が動作する
- [ ] 前回の場所（Previous）が正しく記録される
- [ ] 同じ場所に7日滞在でPreviousがクリアされる
- [ ] ロケーション履歴がUserDefaultsに永続化される
- [ ] 環境差分が算出できる

---

## ロケーションの種類

### 3つのロケーション

| 種類 | 説明 | 用途 |
|------|------|------|
| **Home** | ユーザーが設定した拠点 | 基準点、環境差分の比較元 |
| **Current** | 現在地 | 今の環境情報 |
| **Previous** | 直前にいた場所 | 移動の経緯を把握 |

### 状態遷移の例

```
Day 1: 東京（Home）にいる
  → Current = 東京, Previous = null

Day 2: ニューヨークへ移動
  → Current = ニューヨーク, Previous = 東京

Day 5: ロサンゼルスへ移動
  → Current = ロサンゼルス, Previous = ニューヨーク

Day 12: ロサンゼルスに7日滞在
  → Current = ロサンゼルス, Previous = null（クリア）

Day 13: 東京へ帰宅
  → Current = 東京（= Home）, Previous = ロサンゼルス
  → トラベルモード自動OFF検討（または手動）
```

---

## データモデル

### LocationHistory

```swift
struct LocationHistory: Codable {
    var entries: [LocationEntry]
    var currentLocation: LocationEntry?
    var previousLocation: LocationEntry?
    
    struct LocationEntry: Codable, Identifiable {
        let id: UUID
        let city: String
        let latitude: Double
        let longitude: Double
        let timezone: String
        let arrivedAt: Date           // 到着日時
        var stayDays: Int             // 滞在日数
        var lastUpdated: Date         // 最終更新日時
    }
}
```

### LocationContext（Phase 18-19で使用）

```swift
struct LocationContext {
    let home: HomeLocation?
    let current: LocationHistory.LocationEntry?
    let previous: LocationHistory.LocationEntry?
    
    var isAwayFromHome: Bool {
        guard let home = home, let current = current else {
            return false
        }
        return !isNearby(home: home, current: current)
    }
    
    var timezoneOffset: Int? {
        guard let home = home, let current = current else {
            return nil
        }
        let homeZone = TimeZone(identifier: home.timezone) ?? .current
        let currentZone = TimeZone(identifier: current.timezone) ?? .current
        return (currentZone.secondsFromGMT() - homeZone.secondsFromGMT()) / 3600
    }
}
```

---

## 場所の判定ロジック

### 同じ場所の判定

```swift
/// 2つの場所が「同じ」とみなす距離（km）
let sameLocationThresholdKm: Double = 50.0

func isSameLocation(_ loc1: CLLocationCoordinate2D, _ loc2: CLLocationCoordinate2D) -> Bool {
    let location1 = CLLocation(latitude: loc1.latitude, longitude: loc1.longitude)
    let location2 = CLLocation(latitude: loc2.latitude, longitude: loc2.longitude)
    
    let distanceKm = location1.distance(from: location2) / 1000.0
    return distanceKm < sameLocationThresholdKm
}
```

### Homeとの距離判定

```swift
func isNearby(home: HomeLocation, current: LocationHistory.LocationEntry) -> Bool {
    let homeCoord = CLLocationCoordinate2D(
        latitude: home.latitude,
        longitude: home.longitude
    )
    let currentCoord = CLLocationCoordinate2D(
        latitude: current.latitude,
        longitude: current.longitude
    )
    return isSameLocation(homeCoord, currentCoord)
}
```

---

## LocationHistoryManager

### インターフェース

```swift
protocol LocationHistoryManagerProtocol {
    // 現在の状態
    var currentLocation: LocationHistory.LocationEntry? { get }
    var previousLocation: LocationHistory.LocationEntry? { get }
    var locationContext: LocationContext { get }
    
    // 更新
    func updateCurrentLocation(from location: CLLocation, city: String, timezone: String) async
    func refreshStayDays()
    
    // クリア
    func clearHistory()
    
    // 通知
    var contextPublisher: AnyPublisher<LocationContext, Never> { get }
}
```

### 実装

```swift
final class LocationHistoryManager: LocationHistoryManagerProtocol, ObservableObject {
    @Published private var history: LocationHistory
    
    private let userDefaults: UserDefaults
    private let travelModeManager: TravelModeManagerProtocol
    
    var currentLocation: LocationHistory.LocationEntry? { history.currentLocation }
    var previousLocation: LocationHistory.LocationEntry? { history.previousLocation }
    
    var locationContext: LocationContext {
        LocationContext(
            home: travelModeManager.homeLocation,
            current: history.currentLocation,
            previous: history.previousLocation
        )
    }
    
    var contextPublisher: AnyPublisher<LocationContext, Never> {
        $history
            .map { [weak self] _ in
                self?.locationContext ?? LocationContext(home: nil, current: nil, previous: nil)
            }
            .eraseToAnyPublisher()
    }
    
    init(
        userDefaults: UserDefaults = .standard,
        travelModeManager: TravelModeManagerProtocol
    ) {
        self.userDefaults = userDefaults
        self.travelModeManager = travelModeManager
        self.history = Self.loadHistory(from: userDefaults)
    }
    
    func updateCurrentLocation(
        from location: CLLocation,
        city: String,
        timezone: String
    ) async {
        let newCoord = location.coordinate
        
        // 現在地と同じ場所かチェック
        if let current = history.currentLocation {
            let currentCoord = CLLocationCoordinate2D(
                latitude: current.latitude,
                longitude: current.longitude
            )
            
            if isSameLocation(newCoord, currentCoord) {
                // 同じ場所 → 滞在日数を更新
                updateStayDays(for: current.id)
                return
            }
        }
        
        // 新しい場所に移動
        let newEntry = LocationHistory.LocationEntry(
            id: UUID(),
            city: city,
            latitude: newCoord.latitude,
            longitude: newCoord.longitude,
            timezone: timezone,
            arrivedAt: Date(),
            stayDays: 1,
            lastUpdated: Date()
        )
        
        // Previous を更新（現在地が Previous になる）
        history.previousLocation = history.currentLocation
        history.currentLocation = newEntry
        
        // 履歴に追加
        history.entries.append(newEntry)
        
        // 7日滞在チェック
        checkAndClearPreviousIfNeeded()
        
        saveHistory()
    }
    
    func refreshStayDays() {
        guard let current = history.currentLocation else { return }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: current.arrivedAt,
            to: Date()
        ).day ?? 0
        
        // currentLocation の stayDays を更新
        if var updatedCurrent = history.currentLocation {
            updatedCurrent.stayDays = days + 1  // 到着日を含む
            updatedCurrent.lastUpdated = Date()
            history.currentLocation = updatedCurrent
            
            // entries 内も更新
            if let index = history.entries.firstIndex(where: { $0.id == updatedCurrent.id }) {
                history.entries[index] = updatedCurrent
            }
        }
        
        // 7日滞在チェック
        checkAndClearPreviousIfNeeded()
        
        saveHistory()
    }
    
    private func updateStayDays(for entryId: UUID) {
        guard var current = history.currentLocation, current.id == entryId else {
            return
        }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: current.arrivedAt,
            to: Date()
        ).day ?? 0
        
        current.stayDays = days + 1
        current.lastUpdated = Date()
        history.currentLocation = current
        
        // entries 内も更新
        if let index = history.entries.firstIndex(where: { $0.id == entryId }) {
            history.entries[index] = current
        }
        
        // 7日滞在チェック
        checkAndClearPreviousIfNeeded()
        
        saveHistory()
    }
    
    private func checkAndClearPreviousIfNeeded() {
        guard let current = history.currentLocation else { return }
        
        // 同じ場所に7日以上滞在 → Previous をクリア
        if current.stayDays >= 7 {
            history.previousLocation = nil
        }
    }
    
    func clearHistory() {
        history = LocationHistory(entries: [], currentLocation: nil, previousLocation: nil)
        saveHistory()
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: "location_history")
        }
    }
    
    private static func loadHistory(from userDefaults: UserDefaults) -> LocationHistory {
        guard let data = userDefaults.data(forKey: "location_history"),
              let history = try? JSONDecoder().decode(LocationHistory.self, from: data) else {
            return LocationHistory(entries: [], currentLocation: nil, previousLocation: nil)
        }
        return history
    }
}
```

---

## 環境差分の算出

### EnvironmentDelta

```swift
struct EnvironmentDelta {
    let tempDiff: Int           // 気温差（℃）
    let humidityDiff: Int       // 湿度差（%）
    let pressureDiff: Int       // 気圧差（hPa）
    let timezoneOffset: Int     // 時差（時間）
    let sunriseDiff: Int        // 日の出時刻差（分）
    let sunsetDiff: Int         // 日没時刻差（分）
}
```

### 算出サービス

```swift
protocol EnvironmentDeltaServiceProtocol {
    func calculateDelta(
        home: EnvironmentData,
        current: EnvironmentData
    ) -> EnvironmentDelta
}

struct EnvironmentDeltaService: EnvironmentDeltaServiceProtocol {
    func calculateDelta(
        home: EnvironmentData,
        current: EnvironmentData
    ) -> EnvironmentDelta {
        return EnvironmentDelta(
            tempDiff: current.temp - home.temp,
            humidityDiff: current.humidity - home.humidity,
            pressureDiff: current.pressure - home.pressure,
            timezoneOffset: calculateTimezoneOffset(
                from: home.timezone,
                to: current.timezone
            ),
            sunriseDiff: calculateTimeDiff(
                from: home.sunrise,
                to: current.sunrise
            ),
            sunsetDiff: calculateTimeDiff(
                from: home.sunset,
                to: current.sunset
            )
        )
    }
    
    private func calculateTimezoneOffset(from: String, to: String) -> Int {
        guard let fromZone = TimeZone(identifier: from),
              let toZone = TimeZone(identifier: to) else {
            return 0
        }
        return (toZone.secondsFromGMT() - fromZone.secondsFromGMT()) / 3600
    }
    
    private func calculateTimeDiff(from: Date, to: Date) -> Int {
        Int(to.timeIntervalSince(from) / 60)
    }
}
```

---

## アプリ起動時の処理

### LocationUpdateCoordinator

```swift
final class LocationUpdateCoordinator {
    private let locationManager: LocationManagerProtocol
    private let locationHistoryManager: LocationHistoryManagerProtocol
    private let travelModeManager: TravelModeManagerProtocol
    
    func updateLocationOnAppLaunch() async {
        // トラベルモードOFFの場合はスキップ
        guard travelModeManager.isEnabled else { return }
        
        do {
            // 現在地を取得
            let location = try await locationManager.getCurrentLocation()
            let placemark = try await geocoder.reverseGeocode(location)
            
            let city = placemark.locality ?? "不明"
            let timezone = placemark.timeZone?.identifier ?? TimeZone.current.identifier
            
            // ロケーション履歴を更新
            await locationHistoryManager.updateCurrentLocation(
                from: location,
                city: city,
                timezone: timezone
            )
        } catch {
            // 位置情報取得失敗 → 滞在日数のみ更新
            locationHistoryManager.refreshStayDays()
        }
    }
}
```

---

## 実装コンポーネント

### Managers

```
Core/
└── Managers/
    ├── TravelModeManager.swift           # Phase 16
    └── LocationHistoryManager.swift      # NEW
```

### Services

```
Core/
└── Services/
    └── EnvironmentDeltaService.swift     # NEW
```

### Coordinators

```
Core/
└── Coordinators/
    └── LocationUpdateCoordinator.swift   # NEW
```

### Models

```
Core/
└── Models/
    ├── TravelMode.swift                  # Phase 16
    ├── LocationHistory.swift             # NEW
    ├── LocationContext.swift             # NEW
    └── EnvironmentDelta.swift            # NEW
```

---

## 依存関係図

```
LocationUpdateCoordinator
    │
    ├── LocationManager（位置情報取得）
    │
    ├── LocationHistoryManager
    │       │
    │       ├── UserDefaults（永続化）
    │       │
    │       └── TravelModeManager（Home取得）
    │
    └── CLGeocoder（逆ジオコーディング）

EnvironmentDeltaService
    │
    └── EnvironmentData（Home & Current）
```

---

## テスト観点

### 正常系

- 新しい場所に移動 → Current更新、Previous設定
- 同じ場所に滞在 → stayDays増加
- 7日滞在 → Previousクリア
- 履歴がアプリ再起動後も保持される

### 異常系

- 位置情報取得失敗 → stayDaysのみ更新
- 逆ジオコーディング失敗 → 「不明」で記録

### 境界値

- 50km境界での同一場所判定
- 6日と7日の滞在日数境界
- タイムゾーンまたぎ（日付変更）

### 環境差分

- 時差の正負計算
- 気温・湿度・気圧の差分計算

---

## 今後のフェーズとの関係

### Phase 18で使用

- LocationContext を使ってトラベルモードUIを制御
- 環境差分セクションの表示

### Phase 19で使用

- LocationContext をAIプロンプトに含める
- timezoneOffset を使ってリセットポイントを算出

---

## 関連ドキュメント

- `16-phase-travel-mode-foundation.md` - トラベルモード基盤
- `travel-mode-condition-spec.md` - トラベルモード詳細仕様

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-11 | 初版作成 |
