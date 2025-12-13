# Swift Coding Standards

> **Prerequisite**: Read [CLAUDE.md](../CLAUDE.md) for architecture principles (SOLID). This document covers Swift-specific patterns.

## 🎯 Philosophy

Modern Swift development following Apple's API Design Guidelines, emphasizing type safety, clarity, and SwiftUI best practices for iOS health applications.

## 📝 Naming Conventions

### Types & Properties

```swift
// ✅ Types: PascalCase
struct HealthData { }
class HealthKitManager: ObservableObject { }
enum NetworkError: Error { }

// ✅ Properties: camelCase with explicit types
@Published var isAuthorized: Bool = false
@Published var authorizationStatus: String = "Not Determined"
private let healthStore: HKHealthStore = HKHealthStore()

// ✅ Boolean properties: Use descriptive prefixes
var isLoading: Bool = false
var hasHealthData: Bool = false
var canFetchData: Bool = false
```

### Constants & Configuration

```swift
// ✅ camelCase for Swift constants (not SCREAMING_SNAKE_CASE)
private let maxRetryCount: Int = 3
static let defaultTimeout: TimeInterval = 30.0

// ✅ Configuration constants
private let apiBaseURL: String = "https://api.tempo-ai.com"
```

## 🔧 Type Safety & Explicit Declarations

### Explicit Type Requirements

```swift
// ✅ ALWAYS declare property types explicitly
class APIClient: ObservableObject {
    static let shared: APIClient = APIClient()
    private let baseURL: String
    private let session: URLSession = URLSession.shared

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
}

// ❌ Avoid type inference for properties
static let shared = APIClient()  // Type unclear
@Published var isLoading = false // Type unclear
```

### SwiftUI State Management

```swift
// ✅ Explicit types for all State properties
struct HomeView: View {
    @StateObject private var healthKitManager: HealthKitManager = HealthKitManager()
    @StateObject private var locationManager: LocationManager = LocationManager()
    @State private var todayAdvice: DailyAdvice? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
}
```

## 🏗️ Architecture Patterns

### File Organization

```text
TempoAI/
├── App/
│   ├── TempoAIApp.swift       # App entry point
│   └── ContentView.swift      # Main tab view
├── Features/
│   ├── Health/
│   │   ├── Views/             # Health-related views
│   │   ├── Models/            # Health data models
│   │   └── Managers/          # HealthKit integration
│   └── Location/
│       ├── Views/
│       └── Managers/
├── Shared/
│   ├── Models/                # Shared data models
│   ├── Extensions/            # Type extensions
│   ├── Utilities/             # Pure functions
│   └── Components/            # Reusable UI components
└── Resources/
    └── Assets.xcassets/
```

### View Decomposition (400 line limit)

```swift
// ✅ Break down large views
struct HomeView: View {
    @StateObject private var healthManager: HealthKitManager = HealthKitManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                HeaderSection(manager: healthManager)
                AdviceSection(advice: todayAdvice)
                StatusSection(isLoading: isLoading)
            }
        }
    }
}

// ✅ Extract components to separate files
struct HeaderSection: View {
    let manager: HealthKitManager

    var body: some View { /* ... */ }
}
```

## 📏 Code Formatting

### Line Length & Structure

```swift
// ✅ Max 120 characters, logical breaks
func analyzeHealth(
    healthData: HealthData,
    location: LocationData,
    userProfile: UserProfile
) async throws -> DailyAdvice {
    // Implementation
}

// ✅ Consistent spacing and organization
class HealthKitManager: ObservableObject {
    // MARK: - Properties

    @Published var isAuthorized: Bool = false
    private let healthStore: HKHealthStore = HKHealthStore()

    // MARK: - Public Methods

    func requestAuthorization() async throws {
        // Implementation
    }

    // MARK: - Private Methods

    private func setupHealthStore() {
        // Implementation
    }
}
```

### Import Organization

```swift
// ✅ System frameworks first, alphabetical order
import Combine
import CoreLocation
import Foundation
import HealthKit
import SwiftUI
```

## 🔒 Error Handling

### Health-Specific Errors

```swift
// ✅ Domain-specific error types
enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case notAuthorized
    case dataUnavailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized"
        case .dataUnavailable:
            return "Health data is not available"
        }
    }
}
```

## 🧪 Async/Await Patterns

### Modern Concurrency

```swift
// ✅ Use async/await for health data fetching
func fetchTodayHealthData() async throws -> HealthData {
    guard isAuthorized else {
        throw HealthKitError.notAuthorized
    }

    async let sleepData = fetchSleepData()
    async let hrvData = fetchHRVData()
    async let heartRateData = fetchHeartRateData()
    async let activityData = fetchActivityData()

    return try await HealthData(
        sleep: sleepData,
        hrv: hrvData,
        heartRate: heartRateData,
        activity: activityData
    )
}

// ✅ MainActor for UI updates
@MainActor
class HealthKitManager: ObservableObject {
    @Published var isLoading: Bool = false

    func updateLoadingState(_ loading: Bool) {
        // Guaranteed to run on main thread
        isLoading = loading
    }
}
```

## 🎨 SwiftUI Best Practices

### State Management Patterns

```swift
// ✅ Choose appropriate property wrappers
struct HomeView: View {
    @StateObject private var healthManager: HealthKitManager = HealthKitManager()  // Create and own
    @ObservedObject var apiClient: APIClient                                      // Passed from parent
    @State private var isLoading: Bool = false                                    // Local UI state
    @Environment(\.dismiss) private var dismiss                                   // Environment value
}
```

### View Composition

```swift
// ✅ Compose views with clear data flow
struct AdviceView: View {
    let advice: DailyAdvice

    var body: some View {
        VStack(spacing: 16) {
            ThemeSection(theme: advice.theme, summary: advice.summary)
            MealSection(breakfast: advice.breakfast, lunch: advice.lunch, dinner: advice.dinner)
            ActivitySection(exercise: advice.exercise, sleep: advice.sleep)
        }
    }
}

// ✅ Reusable components with clear interface
struct AdviceCard: View {
    let title: String
    let content: String
    let color: Color

    var body: some View {
        // Implementation
    }
}
```

## 📊 Performance Optimization

### Lazy Properties

```swift
// ✅ Expensive computations
private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
```

### Efficient Data Handling

```swift
// ✅ Choose appropriate collection types
private var healthDataCache: [String: HealthData] = [:]    // Fast lookups
private var recentSessions: [HealthSession] = []           // Ordered access
private var permissionStatus: Set<HKObjectType> = []       // Unique items
```

## 📚 Documentation

### Function Documentation

```swift
/// Fetches comprehensive health data for the current day
///
/// Retrieves sleep, heart rate variability, heart rate, and activity data
/// from HealthKit, combining them into a unified HealthData structure.
///
/// - Returns: Complete health data for today
/// - Throws: `HealthKitError.notAuthorized` if HealthKit access is denied
/// - Note: Requires HealthKit authorization before calling
func fetchTodayHealthData() async throws -> HealthData {
    // Implementation
}
```

## ✅ Swift Quality Checklist

Before committing Swift code:

- [ ] All properties have explicit types declared
- [ ] Lines are ≤ 120 characters
- [ ] Files are ≤ 400 lines (extract components if longer)
- [ ] Imports are sorted alphabetically
- [ ] No force unwrapping without clear justification
- [ ] Async/await used for asynchronous operations
- [ ] Errors have descriptive LocalizedError conformance
- [ ] SwiftUI views use appropriate property wrappers
- [ ] MARK comments organize large classes
- [ ] SwiftLint violations: 0

## 🚫 Anti-Patterns

### Avoid These Patterns

```swift
// ❌ Type inference for properties
let manager = HealthKitManager()

// ❌ Force unwrapping without justification
let data = healthManager.data!

// ❌ Massive view controllers/managers (>400 lines)
class MegaHealthManager: ObservableObject {
    // 500+ lines of mixed responsibilities
}

// ❌ String-based configuration
let userType = "premium"  // Use enum instead

// ❌ Global mutable state
var globalHealthData: HealthData?  // Use proper state management
```

---

## 📁 File Organization Guidelines

### Single Responsibility Principle

1つのファイルに複数のクラス/構造体を含める場合:
- 密接に関連するもののみ（例: ErrorとそのExtension）
- 合計400行を超えない
- 独立して使用されるものは別ファイルに分割

```swift
// ❌ 複数の責務を1ファイルに（悪い例）
// CacheManager.swift (700行)
class CacheManager { ... }
class HealthKitManager { ... }
class LocationManager { ... }

// ✅ 責務ごとに分割（良い例）
// CacheManager.swift (200行)
class CacheManager { ... }

// HealthKitManager.swift (150行)
class HealthKitManager { ... }

// LocationManager.swift (150行)
class LocationManager { ... }
```

### Manager/Service Class Organization

サービスクラスは以下のルールで分割:
- 1ファイル = 1つの主要クラス
- 関連するError enumは同じファイルに含めてOK
- Extensionは同ファイルまたは `+Extension.swift` に分割

```text
Services/
├── CacheManager.swift           # キャッシュ管理のみ
├── HealthKitManager.swift       # HealthKit統合
├── LocationManager.swift        # 位置情報サービス
├── APIClient.swift              # API通信
└── DebugHelpers.swift           # #if DEBUG 用ユーティリティ
```

---

## 🐛 DEBUG Code Organization

### Preview/Debug拡張は別ファイルに

本番コードの可読性を保つため、DEBUGコードは分離:

```swift
// ✅ 推奨: 別ファイルで管理
// HomeView+Preview.swift
#if DEBUG
extension HomeView {
    static var previewAdvice: DailyAdvice {
        DailyAdvice.createMock()
    }

    static var previewMetrics: [MetricData] {
        MockData.mockMetrics
    }
}
#endif

// ❌ 避ける: 本番コードにDEBUGブロックが散在
struct HomeView: View {
    #if DEBUG
    static var previewData: DailyAdvice { ... }
    #endif

    var body: some View { ... }

    #if DEBUG
    func debugHelper() { ... }
    #endif

    // さらに #if DEBUG が続く...
}
```

### ルール
- 1ファイルに `#if DEBUG` ブロックが3箇所以上 → 別ファイルに分離
- Preview用データは `+Preview.swift` サフィックスで管理
- デバッグヘルパーは `DebugHelpers.swift` に集約

---

## 🔄 Reusable Components

### 共通UIパターンの抽出

2箇所以上で使用されるUIパターンは `Shared/Components/` に抽出:

```swift
// ✅ 再利用可能なコンポーネント
// Shared/Components/ToastView.swift
import SwiftUI

struct ToastView: View {
    let message: String
    let systemImage: String
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                Text(message)
                    .font(.subheadline)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(25)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// 使用側
ToastView(
    message: "保存しました",
    systemImage: "checkmark.circle.fill",
    isShowing: $showToast
)
```

### 抽出の判断基準
- 同じUIパターンが2箇所以上で使用
- コピペではなく、パラメータ化可能
- 独立してテスト・プレビュー可能

---

## ⚠️ Error Handling Best Practices

### サイレントフェイルの禁止

エラーをログ出力だけで握り潰さない:

```swift
// ❌ 禁止: ログのみでユーザーに通知なし
do {
    try await healthKitManager.requestAuthorization()
} catch {
    print("Error: \(error)")  // ユーザーには何も伝わらない
}

// ✅ 推奨: ユーザーに適切に通知
do {
    try await healthKitManager.requestAuthorization()
} catch {
    errorMessage = error.localizedDescription
    showErrorAlert = true
}
```

### DEBUGフォールバックの明示

```swift
// ❌ 避ける: 本番で黙ってモックを返す
func fetchData() async throws -> HealthData {
    do {
        return try await realFetch()
    } catch {
        #if DEBUG
        return mockData  // 本番では何が起きる？
        #else
        throw error
        #endif
    }
}

// ✅ 推奨: 明示的なエラー処理とログ
func fetchData() async throws -> HealthData {
    do {
        return try await realFetch()
    } catch {
        #if DEBUG
        print("⚠️ Using mock data due to: \(error)")
        return HealthKitManager.generateMockData()
        #else
        throw error
        #endif
    }
}
```

### エラー情報の保持

```swift
// ❌ 避ける: 元のエラー情報を消失
catch {
    throw APIError.networkError("通信エラーが発生しました")
}

// ✅ 推奨: 元のエラー情報を保持
catch {
    throw APIError.networkError(error.localizedDescription)
}
```

---

**Note**: This supplements CLAUDE.md architecture principles with Swift-specific patterns for iOS health app development.
