# Tempo AI 技術仕様書
## Technical Specification Document

### 概要 (Overview)
Tempo AIは、iOS SwiftUIアプリケーションとCloudflare Workers TypeScriptバックエンドで構成される健康アドバイスプラットフォームです。HealthKitデータ、位置情報、気象データを統合し、Claude AIによる高度な健康分析を提供します。

---

## 1. システム概要 (System Overview)

### 1.1 システムアーキテクチャ
```
┌─────────────────┐    ┌───────────────────┐    ┌─────────────────┐
│   iOS Client    │◄──►│ Cloudflare Workers │◄──►│   Claude AI     │
│   (SwiftUI)     │    │     (Hono)        │    │  (Anthropic)    │
└─────────────────┘    └───────────────────┘    └─────────────────┘
         │                       │                       
         ▼                       ▼                       
┌─────────────────┐    ┌───────────────────┐             
│   HealthKit     │    │   Open-Meteo API  │             
│   (Apple)       │    │   (Weather)       │             
└─────────────────┘    └───────────────────┘             
```

### 1.2 技術スタック

**バックエンド (Backend):**
- **ランタイム**: Cloudflare Workers (V8 JavaScript Engine)
- **フレームワーク**: Hono v4.10.7 (高速TypeScript Webフレームワーク)
- **言語**: TypeScript 5.9.3 (strict mode)
- **バリデーション**: Zod v4.1.13 (型安全スキーマ検証)
- **AI SDK**: @anthropic-ai/sdk v0.71.0
- **パッケージ管理**: pnpm
- **ビルド**: TypeScript Compiler + Wrangler v4.51.0

**フロントエンド (Frontend):**
- **プラットフォーム**: iOS 15.0+ (SwiftUI 5.9+)
- **言語**: Swift 5.9+ (strict mode)
- **フレームワーク**: SwiftUI, HealthKit, CoreLocation, UserNotifications
- **データ管理**: Core Data + @StateObject/@ObservedObject
- **ネットワーキング**: URLSession + Combine
- **国際化**: 日本語・英語対応 (ja.lproj, en.lproj)

**開発・デプロイツール:**
- **CI/CD**: GitHub Actions (iOS、Backend、Security、Coverage)
- **コード品質**: SwiftLint + swift-format (iOS), Biome (TypeScript)
- **テスト**: XCTest + UI Tests (iOS), Vitest + Coverage (Backend)
- **パッケージ管理**: Swift Package Manager, pnpm
- **デプロイ**: Cloudflare Workers (Backend), App Store Connect (iOS)

---

## 2. プロジェクト構成 (Project Structure)

### 2.1 ディレクトリ構成
```
tempo-ai/
├── backend/                     # Cloudflare Workers API
│   ├── src/
│   │   ├── routes/              # APIエンドポイント定義
│   │   ├── services/            # ビジネスロジック層
│   │   ├── types/               # TypeScript型定義
│   │   ├── utils/               # 共通ユーティリティ
│   │   └── index.ts             # メインエントリポイント
│   ├── tests/                   # テストスイート
│   │   ├── services/            # サービス層テスト
│   │   ├── routes/              # APIルートテスト
│   │   ├── utils/               # ユーティリティテスト
│   │   └── data/                # テストデータ
│   ├── package.json             # 依存関係・スクリプト
│   ├── tsconfig.json            # TypeScript設定
│   ├── wrangler.toml            # Cloudflare Workers設定
│   └── biome.json               # Linter/Formatter設定
│
├── ios/                         # iOS SwiftUIアプリケーション
│   ├── TempoAI/
│   │   ├── TempoAI/
│   │   │   ├── Models/          # データモデル定義
│   │   │   ├── Services/        # 健康データ・API通信
│   │   │   ├── Views/           # SwiftUI画面コンポーネント
│   │   │   ├── ViewModels/      # MVVM ViewModels
│   │   │   ├── DesignSystem/    # 再利用可能UIコンポーネント
│   │   │   ├── Resources/       # 多言語リソース
│   │   │   └── Assets.xcassets/ # アセット管理
│   │   ├── TempoAITests/        # 単体テスト
│   │   └── TempoAIUITests/      # UIテスト
│   ├── scripts/                 # ビルド・品質チェックスクリプト
│   ├── .swiftlint.yml          # SwiftLint設定
│   └── .swift-format           # コードフォーマット設定
│
├── scripts/                    # 共通開発スクリプト
├── guidelines/                 # 仕様書・計画書
├── .github/workflows/          # CI/CDパイプライン
└── CLAUDE.md                   # プロジェクト開発ガイドライン
```

### 2.2 主要コンポーネント

**バックエンドアーキテクチャ:**
- **ルート層** (`routes/`): HTTP エンドポイント・リクエスト検証
- **サービス層** (`services/`): ビジネスロジック・外部API統合
- **型層** (`types/`): データ型定義・API インターフェース
- **ユーティリティ層** (`utils/`): 共通機能・エラーハンドリング

**iOSアーキテクチャ (MVVM + Service Layer):**
- **Models**: データ構造・Core Dataエンティティ
- **Services**: HealthKit・API通信・データ永続化
- **ViewModels**: 画面状態管理・ビジネスロジック
- **Views**: SwiftUIコンポーネント・画面構成
- **DesignSystem**: 再利用可能UI要素

---

## 3. データベース・データモデル (Data Architecture)

### 3.1 iOS Core Data モデル
```swift
// HealthKitデータキャッシュ
Entity: HealthDataEntry
- id: UUID
- timestamp: Date
- dataType: HealthDataType
- value: Double
- unit: String
- sourceApp: String?

Entity: UserProfile
- id: UUID
- age: Int16
- language: String
- goals: [String]
- preferences: Data (JSON)

Entity: AdviceHistory
- id: UUID
- adviceText: String
- category: AdviceCategory
- timestamp: Date
- executed: Bool
- effectiveness: Int16?
```

### 3.2 API データ型定義 (TypeScript)
```typescript
// 健康データ統合型
interface ComprehensiveHealthData {
  heartRate: HealthMetric[]
  sleep: SleepData[]
  activity: ActivityData[]
  stress: HRVData[]
  timestamp: Date
}

// Claude AI分析要求
interface AnalysisRequest {
  healthData: ComprehensiveHealthData
  userProfile: UserProfile
  location?: GeolocationData
  weatherData?: WeatherData
  language: 'japanese' | 'english'
}

// AI生成アドバイス
interface AIHealthInsights {
  theme: string
  summary: string
  meals: MealAdvice[]
  exercise: ExerciseAdvice
  sleep: SleepAdvice
  mindfulness: MindfulnessAdvice
  confidence: number
  timestamp: Date
}
```

---

## 4. API設計 (API Architecture)

### 4.1 REST API エンドポイント

**ヘルス分析API:**
```
POST /api/health/analyze
- 基本的な健康データ分析とアドバイス生成
- Input: AnalysisRequest
- Output: DailyAdvice

POST /api/health/ai/analyze-comprehensive  
- Claude AI による包括的健康分析
- Input: ComprehensiveAnalysisRequest
- Output: AIHealthInsights

POST /api/health/ai/quick-analyze
- 高速AI分析 (基本データのみ)
- Input: QuickAnalysisRequest  
- Output: QuickAIInsights

GET /api/health/status
- ヘルス分析サービス状態確認
- Output: ServiceStatus

GET /api/health/ai/health-check
- Claude AI サービス可用性チェック
- Output: AIServiceStatus
```

**テスト・開発API (非本番環境):**
```
POST /api/test/claude-integration
- Claude AI統合テスト
- Input: TestRequest
- Output: TestResponse

GET /api/test/health-check
- システム全体ヘルスチェック
- Output: SystemStatus
```

### 4.2 レスポンス形式
```typescript
// 統一レスポンス形式
interface APIResponse<T> {
  success: boolean
  data?: T
  error?: string
  timestamp?: Date
  requestId?: string
}

// エラーレスポンス
interface APIError {
  success: false
  error: string
  code?: string
  details?: Record<string, unknown>
}
```

### 4.3 認証・セキュリティ
- **API Key認証**: Anthropic Claude API (環境変数)
- **CORS設定**: 開発環境localhost許可
- **入力検証**: Zod スキーマバリデーション
- **レート制限**: Cloudflare Workers 組み込み
- **データ暗号化**: HTTPS/TLS (Cloudflare)

---

## 5. AI統合アーキテクチャ (AI Integration)

### 5.1 Claude AI統合フロー
```
1. iOS App → HealthKitデータ収集
2. iOS App → 位置情報・天気データ取得  
3. iOS App → Cloudflare Workers API呼び出し
4. Backend → データ前処理・プロンプト生成
5. Backend → Claude AI API呼び出し
6. Backend → AI レスポンス後処理・構造化
7. iOS App ← 構造化アドバイスレスポンス
8. iOS App → UI更新・通知配信
```

### 5.2 プロンプトエンジニアリング
```typescript
// プロンプト構築ユーティリティ
const buildPrompt = (params: PromptParams): string => {
  return `
健康専門家として、以下のデータに基づいて具体的なアドバイスを提供してください：

健康データ:
${formatHealthData(params.healthData)}

環境データ:  
${formatWeatherData(params.weatherData)}

ユーザー情報:
${formatUserProfile(params.userProfile)}

言語: ${params.language}

回答形式: JSON
必須フィールド: theme, summary, breakfast, lunch, dinner, exercise, sleep, mindfulness
`
}
```

### 5.3 AI レスポンス処理
- **バリデーション**: Zod スキーマによるレスポンス検証
- **フォールバック**: AI 失敗時のローカル分析
- **キャッシング**: 最近の分析結果キャッシュ
- **エラーハンドリング**: レート制限・タイムアウト対応

---

## 6. iOS アプリケーションアーキテクチャ

### 6.1 MVVM + Service Layer パターン
```swift
// Service Layer
protocol HealthDataService {
    func fetchHealthData() async throws -> ComprehensiveHealthData
}

class HealthKitManager: HealthDataService {
    func fetchHealthData() async throws -> ComprehensiveHealthData {
        // HealthKit データ取得実装
    }
}

// ViewModel Layer  
@MainActor
class HomeViewModel: ObservableObject {
    @Published var healthScore: Double = 0.0
    @Published var dailyAdvice: DailyAdvice?
    
    private let healthService: HealthDataService
    private let apiClient: TempoAIAPIClient
    
    func refreshHealthData() async {
        // データ更新ロジック
    }
}

// View Layer
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        // SwiftUI画面構成
    }
}
```

### 6.2 主要サービス

**HealthKitManager:**
- HealthKitアクセス許可管理
- 20種類以上の健康メトリクス取得
- リアルタイムデータ同期
- プライバシー保護実装

**TempoAIAPIClient:**
- バックエンドAPI通信  
- 自動リトライ・エラーハンドリング
- ネットワーク状態監視
- レスポンスキャッシング

**SmartNotificationEngine:**
- コンテキスト最適化通知
- ユーザー行動パターン学習
- 配信タイミング最適化
- A/B テスト対応

**HealthAnalysisEngine:**
- ローカル健康データ分析
- トレンド検出・異常値検知  
- パーソナライゼーション
- AIフォールバック機能

### 6.3 状態管理
```swift
// アプリ全体状態
@main
struct TempoAIApp: App {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    var body: some Scene {
        WindowGroup {
            if onboardingViewModel.isOnboardingCompleted {
                ContentView()
            } else {
                OnboardingFlowView()
                    .environmentObject(onboardingViewModel)
            }
        }
    }
}

// 画面レベル状態管理
class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var selectedLanguage: AppLanguage = .japanese
    @Published var permissionsGranted: Set<PermissionType> = []
}
```

---

## 7. データフロー・通信プロトコル (Data Flow)

### 7.1 HealthKit データフロー
```
1. HealthKitManager.requestPermissions()
   └── ユーザー許可要求 (20+ data types)
   
2. HealthKitManager.startBackgroundObservation()
   └── バックグラウンドデータ監視開始
   
3. HealthKitManager.fetchHealthData()
   └── 最新データ取得・正規化
   
4. HealthDataStore.cacheData()  
   └── Core Data永続化
   
5. HomeViewModel.processHealthData()
   └── UI状態更新
```

### 7.2 API通信フロー
```swift
// 非同期API呼び出し
@MainActor
class APIService {
    func analyzeHealth(request: AnalysisRequest) async throws -> AIHealthInsights {
        let response: APIResponse<AIHealthInsights> = try await performRequest(
            endpoint: "ai/analyze-comprehensive",
            request: request
        )
        
        guard let insights = response.data else {
            throw TempoAIAPIError.analysisError(response.error ?? "Unknown error")
        }
        
        return insights
    }
}
```

### 7.3 エラーハンドリング戦略
```typescript
// バックエンドエラーハンドリング
enum APIErrorType {
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  EXTERNAL_API_ERROR = 'EXTERNAL_API_ERROR', 
  RATE_LIMIT_EXCEEDED = 'RATE_LIMIT_EXCEEDED',
  INTERNAL_ERROR = 'INTERNAL_ERROR'
}

class APIError extends Error {
  constructor(
    message: string,
    public type: APIErrorType,
    public statusCode: number = 500
  ) {
    super(message)
  }
}
```

---

## 8. セキュリティ・プライバシー (Security & Privacy)

### 8.1 データ保護実装

**iOS プライバシー保護:**
```swift
// HealthKitデータ最小化
class PrivacyManager {
    func anonymizeHealthData(_ data: ComprehensiveHealthData) -> AnonymizedHealthData {
        // 個人特定情報除去
        // 統計化処理
        // 必要最小限データのみ抽出
    }
    
    func encryptSensitiveData(_ data: Data) -> Data {
        // AES暗号化実装
    }
}
```

**バックエンドセキュリティ:**
```typescript
// 入力サニタイゼーション
const sanitizeHealthData = (data: unknown): ComprehensiveHealthData => {
  const schema = ComprehensiveHealthDataSchema
  return schema.parse(data) // Zod validation
}

// 機密情報フィルタリング
const filterSensitiveInfo = (data: HealthData): SafeHealthData => {
  // PII除去・匿名化処理
  return { ...data, personalInfo: undefined }
}
```

### 8.2 コンプライアンス
- **Apple HealthKit**: プライバシーラベル・使用許可
- **GDPR/CCPA**: データ削除権・透明性要求
- **医療規制**: 診断・治療免責事項
- **API セキュリティ**: OWASP ベストプラクティス

---

## 9. テスト戦略 (Testing Strategy)

### 9.1 バックエンドテスト (Vitest)
```typescript
// API統合テスト
describe('Health Analysis API', () => {
  it('should analyze health data successfully', async () => {
    const request: AnalysisRequest = createTestRequest()
    const response = await analyzeHealth(request)
    
    expect(response.success).toBe(true)
    expect(response.data).toBeDefined()
    expect(response.data.theme).toMatch(/^.{1,100}$/)
  })
  
  it('should handle invalid input gracefully', async () => {
    const invalidRequest = { invalid: 'data' }
    
    await expect(
      analyzeHealth(invalidRequest as any)
    ).rejects.toThrow('Validation failed')
  })
})
```

### 9.2 iOS テスト (XCTest)
```swift
// ViewModelテスト
class HomeViewModelTests: XCTestCase {
    @MainActor
    func testHealthScoreCalculation() async {
        let viewModel = HomeViewModel(
            healthService: MockHealthService(),
            apiClient: MockAPIClient()
        )
        
        await viewModel.refreshHealthData()
        
        XCTAssertGreaterThan(viewModel.healthScore, 0.0)
        XCTAssertLessThanOrEqual(viewModel.healthScore, 1.0)
    }
}

// UI統合テスト
class OnboardingUITests: XCTestCase {
    func testOnboardingFlow() {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.buttons["japaneseButton"].exists)
        app.buttons["japaneseButton"].tap()
        
        XCTAssertTrue(app.buttons["welcomeNextButton"].waitForExistence(timeout: 2))
    }
}
```

### 9.3 テストカバレッジ目標
- **バックエンド**: 90%以上 (Vitest + C8)
- **iOS**: 80%以上 (XCTest)  
- **重要パス**: 100% (認証・データ処理・AI統合)
- **UI/UX**: E2E シナリオテスト

---

## 10. CI/CD・デプロイメント (DevOps)

### 10.1 GitHub Actions CI/CD
```yaml
# .github/workflows/backend.yml
name: Backend CI/CD
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install
      - run: pnpm run type-check
      - run: pnpm run lint  
      - run: pnpm run test:coverage
      
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: pnpm run deploy
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

### 10.2 iOS CI/CD
```yaml
# .github/workflows/ios.yml  
name: iOS CI/CD
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: SwiftLint
        run: cd ios && swiftlint lint --strict
      - name: Swift Format Check
        run: cd ios && swift-format lint -r TempoAI/TempoAI/
      - name: Build & Test
        run: |
          cd ios
          xcodebuild test -scheme TempoAI -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 10.3 品質管理自動化
```bash
# scripts/quality-check-all.sh
#!/bin/bash

echo "🔍 Running comprehensive quality checks..."

# Backend checks
cd backend
pnpm run type-check
pnpm run lint
pnpm run test:coverage
pnpm run security:check

# iOS checks  
cd ../ios
./scripts/quality-check.sh

echo "✅ All quality checks passed!"
```

---

## 11. パフォーマンス・スケーリング (Performance)

### 11.1 最適化戦略

**バックエンド最適化:**
- **Cloudflare Workers**: エッジコンピューティング・低レイテンシ
- **Claude AIキャッシング**: 類似リクエスト結果再利用  
- **データ圧縮**: Gzip・Brotli圧縮
- **レート制限**: API過負荷防止

**iOS最適化:**
- **SwiftUI最適化**: @State・@Published適切使用
- **HealthKitバッチ処理**: バックグラウンドデータ取得
- **画像・リソース最適化**: WebP・Vector Assets
- **メモリ管理**: [weak self]・適切なライフサイクル

### 11.2 監視・分析
```typescript
// パフォーマンスメトリクス
interface PerformanceMetrics {
  apiLatency: number
  claudeResponseTime: number  
  healthDataProcessingTime: number
  errorRate: number
  userEngagement: number
}

// Cloudflare Analytics統合
const trackPerformance = (metrics: PerformanceMetrics) => {
  // Cloudflare Workers Analytics
  // カスタムメトリクス送信
}
```

---

## 12. 運用・メンテナンス (Operations)

### 12.1 ログ・監視
```typescript
// 構造化ログ
const logger = {
  info: (message: string, context?: Record<string, unknown>) => {
    console.log(JSON.stringify({
      level: 'info',
      message,
      context,
      timestamp: new Date().toISOString()
    }))
  },
  
  error: (error: Error, context?: Record<string, unknown>) => {
    console.error(JSON.stringify({
      level: 'error', 
      message: error.message,
      stack: error.stack,
      context,
      timestamp: new Date().toISOString()
    }))
  }
}
```

### 12.2 アラート・障害対応
- **Cloudflare Monitoring**: アップタイム・レスポンスタイム監視
- **Error Tracking**: 構造化エラーログ・アラート
- **Health Check**: 定期的なサービス可用性確認
- **Rollback Strategy**: 問題発生時の迅速な復旧手順

### 12.3 バックアップ・災害復旧
- **Code Repository**: GitHub (multiple backups)
- **Cloudflare Workers**: 自動バックアップ・復旧
- **iOS App Store**: バージョン管理・ロールバック可能
- **User Data**: Core Data + iCloud同期

---

## 13. 今後の技術的拡張 (Future Technical Roadmap)

### 13.1 短期的拡張 (3-6ヶ月)
- **Apple Watch統合**: リアルタイムヘルスモニタリング
- **WidgetKit**: ホーム画面ウィジェット
- **Shortcuts統合**: Siriショートカット対応
- **Enhanced Notifications**: インテリジェント通知

### 13.2 中期的拡張 (6-12ヶ月)  
- **多言語対応**: 中国語・韓国語・スペイン語
- **Advanced AI Features**: GPT-4/Claude-3 統合
- **Wearable Integration**: Fitbit・Garmin対応
- **Social Features**: 家族・医師とのデータ共有

### 13.3 長期的拡張 (12ヶ月+)
- **Android版開発**: React Native・Flutter検討
- **Healthcare API統合**: 病院・クリニックシステム連携
- **AI研究協力**: 学術機関との共同研究
- **B2B展開**: 企業健康管理ソリューション

---

## 14. まとめ (Summary)

Tempo AIは最新のWeb技術(TypeScript + Hono + Cloudflare Workers)とネイティブiOS技術(SwiftUI + HealthKit)を組み合わせた、スケーラブルで保守性の高い健康管理プラットフォームです。

**主要な技術的優位性:**
- **型安全性**: TypeScript strict mode + Swift strong typing
- **パフォーマンス**: Cloudflare エッジコンピューティング + SwiftUI最適化  
- **スケーラビリティ**: サーバーレスアーキテクチャ
- **品質保証**: 包括的CI/CD + 自動テスト
- **プライバシー**: End-to-end暗号化 + データ最小化

継続的な技術革新とユーザー中心設計により、次世代の個人健康管理ソリューションとして発展していきます。