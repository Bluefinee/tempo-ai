# 📱 Phase 1: MVP コア体験実装計画書

**実施期間**: 3-4週間  
**対象読者**: 開発チーム  
**最終更新**: 2025年12月5日  
**前提条件**: Phase 0 完了（品質基盤安定化）

---

## ⚠️ 重要：実装開始前の必須手順

**実装を開始する前に、必ず以下の手順を実行してください：**

1. **📋 全体像の把握**: [`guidelines/tempo-ai-product-spec.md`](../tempo-ai-product-spec.md) を熟読し、プロダクト全体のビジョン・要件・アーキテクチャを理解する

2. **📝 開発ルールの確認**: [`CLAUDE.md`](../../CLAUDE.md) とその関連ドキュメント（[Swift Coding Standards](.claude/swift-coding-standards.md), [TypeScript Hono Standards](.claude/typescript-hono-standards.md)）を確認し、コーディング規約・品質基準・開発プロセスを把握する

3. **🧪 テスト駆動開発**: **テストカバレッジ80%以上を維持**しながら、TDD（Test-Driven Development）でコードを実装する
   - Red: テストを書く（失敗）
   - Green: テストを通すための最小限のコード実装
   - Refactor: コード品質向上
   - **カバレッジ確認**: 各実装後に必ずテストカバレッジが80%を下回らないことを確認

---

## 🎯 概要

Phase 1では、仕様書に定義された洗練されたユーザー体験の基盤を構築します。美しいオンボーディングフロー、環境情報統合、カラーコード化された健康状態システム、天気対応挨拶システムの実装により、現在の基本MVPを魅力的なヘルスアドバザーアプリに変換します。

---

## 📊 現状と目標

### 現在の状態（Phase 0完了後）
- 基本的な4タブナビゲーション
- 単純なHomeView（Today）
- 基本的なヘルス・位置情報権限管理
- シンプルなアドバイス表示
- **✅ 日英多言語化基盤構築済み**

### Phase 1 終了時の目標
- 🌟 **4ページ美麗オンボーディングフロー**（**日本語・英語完全対応**）
- 🎨 **カラーコード化ヘルスステータス**（最適/標準/ケア/休息モード）
- 🌤️ **天気・時間対応パーソナライズ挨拶**（**日本語での自然な表現**）
- ⚠️ **環境アラートシステム**（気圧・花粉・大気質）
- 💫 **洗練されたUI/UX体験**（**日本語レイアウト最適化**）

---

## 📋 実装要件

### 1. オンボーディングフロー実装

#### 実装ファイル
- `OnboardingView.swift` - メイン管理
- `WelcomePageView.swift` - Page 1: コンセプト紹介
- `DataExplanationPageView.swift` - Page 2: データ統合説明
- `AIAnalysisPageView.swift` - Page 3: AI分析説明
- `GetStartedPageView.swift` - Page 4: 開始画面

#### 技術要件
- SwiftUI TabView with .page style
- 多言語対応（String Catalog使用）
- アクセシビリティ識別子
- UI テスト対応

#### 多言語リソース（主要項目）
```swift
// 日本語
"onboarding_welcome_title" = "Tempo AI へようこそ"
"onboarding_data_title" = "3つのデータを統合"
"onboarding_analysis_title" = "AIが分析すること"
"onboarding_start_title" = "毎朝届くもの"

// English  
"onboarding_welcome_title" = "Welcome to Tempo AI"
"onboarding_data_title" = "Three Data Sources"
"onboarding_analysis_title" = "What AI Analyzes"
"onboarding_start_title" = "What You Get"
```

### 2. ヘルスステータス システム

#### カラーコード仕様
- **🟢 最適**: 良好な状態 - Green (#00C851)
- **🔵 標準**: 平常状態 - Blue (#2196F3) 
- **🟡 ケア**: 注意必要 - Amber (#FFC107)
- **🔴 休息**: 休息必要 - Red (#F44336)

#### 実装ファイル
- `HealthStatusView.swift` - ステータス表示
- `HealthStatusCalculator.swift` - ロジック
- `HealthStatusColors.swift` - カラー定義

#### 判定ロジック
```swift
struct HealthStatusCalculator {
    static func calculateStatus(from healthData: HealthData) -> HealthStatus {
        let sleepScore = calculateSleepScore(healthData.sleep)
        let hrvScore = calculateHRVScore(healthData.hrv)
        let activityScore = calculateActivityScore(healthData.activity)
        
        let overallScore = (sleepScore + hrvScore + activityScore) / 3
        
        switch overallScore {
        case 80...100: return .optimal
        case 60..<80: return .good
        case 40..<60: return .care
        default: return .rest
        }
    }
}
```

### 3. 天気対応パーソナライズ挨拶

#### 実装ファイル
- `GreetingView.swift` - 挨拶UI
- `GreetingService.swift` - 挨拶生成ロジック
- `WeatherGreetingMapper.swift` - 天気対応

#### 挨拶パターン（時間帯別・天気別）
```swift
// 朝の挨拶（6-12時）
"morning_greeting_sunny" = "おはようございます！今日は晴れて気持ちの良い朝ですね"
"morning_greeting_cloudy" = "おはようございます。少し曇り気味ですが、良い1日にしましょう"
"morning_greeting_rainy" = "おはようございます。雨の日はゆったりと過ごしましょう"

// 昼の挨拶（12-18時）  
"afternoon_greeting_sunny" = "こんにちは！日差しが気持ちいい午後ですね"

// 夜の挨拶（18-22時）
"evening_greeting_clear" = "お疲れ様でした。夜空がきれいな良い夜ですね"
```

### 4. 環境アラートシステム

#### アラート種類
- **気圧変化**: 頭痛・体調不良リスク
- **花粉情報**: アレルギー対策
- **大気質**: 運動・外出推奨度

#### 実装アプローチ
```swift
struct EnvironmentAlert {
    let type: AlertType
    let severity: Severity
    let message: String
    let recommendation: String
    let color: Color
}

enum AlertType {
    case pressure, pollen, airQuality, uvIndex
}
```

---

## 🧪 テスト戦略

### TDD 実装アプローチ

#### Phase 1 実装サイクル
1. **Red**: 機能テスト作成（失敗）
2. **Green**: 最小実装（テスト通過）
3. **Refactor**: コード品質改善
4. **Blue**: UIテスト追加

#### 主要テストカバレッジ
- **Unit Tests**: HealthStatusCalculator, GreetingService
- **Integration Tests**: 多言語化、API統合
- **UI Tests**: オンボーディングフロー
- **Accessibility Tests**: VoiceOver対応

### テスト例
```swift
class HealthStatusTests: XCTestCase {
    func testOptimalStatus() {
        let healthData = HealthData(
            sleep: SleepData(quality: 0.9, duration: 8.0),
            hrv: 50.0,
            activity: ActivityData(steps: 10000)
        )
        let status = HealthStatusCalculator.calculateStatus(from: healthData)
        XCTAssertEqual(status, .optimal)
    }
}
```

---

## 🏗️ アーキテクチャ詳細

### SwiftUI MVVM + Coordinator パターン

#### View層
```swift
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    @StateObject private var coordinator: HomeCoordinator = HomeCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 20) {
                GreetingView(greeting: viewModel.greeting)
                HealthStatusView(status: viewModel.healthStatus)
                EnvironmentAlertView(alerts: viewModel.environmentAlerts)
            }
        }
    }
}
```

#### ViewModel層
```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var healthStatus: HealthStatus = .unknown
    @Published var greeting: String = ""
    @Published var environmentAlerts: [EnvironmentAlert] = []
    
    private let healthService: HealthServiceProtocol
    private let greetingService: GreetingServiceProtocol
    
    func loadData() async {
        do {
            let healthData = try await healthService.fetchTodayData()
            self.healthStatus = HealthStatusCalculator.calculateStatus(from: healthData)
            self.greeting = await greetingService.generateGreeting()
        } catch {
            // エラーハンドリング
        }
    }
}
```

### バックエンド Hono アーキテクチャ

#### API エンドポイント
```typescript
// src/routes/advice.ts
const adviceRoutes = new Hono<{ Bindings: Bindings }>()

adviceRoutes.post('/daily', async (c) => {
  try {
    const body = await c.req.json()
    
    if (!isValidAdviceRequest(body)) {
      return c.json({ error: 'Invalid request' }, 400)
    }
    
    const advice = await generateDailyAdvice({
      ...body,
      apiKey: c.env.ANTHROPIC_API_KEY
    })
    
    return c.json({ success: true, data: advice })
  } catch (error) {
    return handleApiError(c, error)
  }
})
```

#### Claude AI統合
```typescript
export const generateDailyAdvice = async (params: AdviceParams): Promise<DailyAdvice> => {
  const prompt = buildAdvicePrompt(params)
  
  const response = await anthropic.messages.create({
    model: 'claude-3-sonnet-20240229',
    max_tokens: 1000,
    messages: [{ role: 'user', content: prompt }],
    temperature: 0.7
  })
  
  return parseAdviceResponse(response.content[0].text)
}
```

---

## 📅 実装スケジュール

### Week 1: オンボーディング + 基盤
- **Day 1-2**: OnboardingView実装
- **Day 3-4**: 多言語リソース完備
- **Day 5**: UIテスト作成

### Week 2: ヘルス機能 + 挨拶
- **Day 1-2**: HealthStatus計算ロジック
- **Day 3-4**: 天気対応挨拶システム
- **Day 5**: 統合テスト

### Week 3: 環境統合 + 調整
- **Day 1-2**: 環境アラート実装
- **Day 3-4**: UI/UX調整・最適化
- **Day 5**: パフォーマンステスト

### Week 4: テスト + デプロイ
- **Day 1-3**: 包括的テスト実施
- **Day 4-5**: バグ修正・最終調整

---

## 🔧 技術実装ガイドライン

### Swift コーディング規約準拠
- Swift Coding Standards (.claude/swift-coding-standards.md) 遵守
- 明示的型宣言必須
- MVVM + Coordinator パターン
- async/await 使用
- SwiftLint 違反ゼロ

### TypeScript + Hono 準拠  
- TypeScript Hono Standards (.claude/typescript-hono-standards.md) 遵守
- 厳密型安全性
- エラーハンドリング統一
- Cloudflare Workers最適化

---

## 📦 依存関係管理

### 高優先度
- **HealthKit**: iOS ヘルスデータ統合
- **Core Location**: 位置情報・天気API
- **Claude API**: AI アドバイス生成

### 中優先度  
- **WeatherKit**: Apple天気サービス
- **UserNotifications**: ローカル通知

### リスク管理
- **HealthKit権限**: ユーザー拒否時の代替フロー
- **位置情報権限**: 手動入力オプション
- **Claude API**: レート制限・フォールバック

---

## ⚡ パフォーマンス最適化

### iOS最適化
- LazyVStack使用（長リスト）
- @StateObject vs @ObservedObject適切使用
- メモリ効率的な画像読み込み
- バックグラウンド処理最小化

### API最適化  
- レスポンスキャッシュ（5分間）
- リクエスト重複排除
- Claude APIトークン効率化

---

## 🛡️ セキュリティ・プライバシー

### データ保護
- HealthKitデータはデバイス内処理
- 位置情報は即座に破棄
- ログに機密データ記録禁止

### 暗号化
- Keychain使用（APIキー保存）
- TLS 1.3通信（API）
- ローカルデータベース暗号化

---

## 🧪 品質ゲートクライテリア

### 必須条件
- [ ] 全Unit Testパス（カバレッジ85%以上）
- [ ] UIテスト主要フローパス
- [ ] SwiftLint/TypeScriptエラーゼロ
- [ ] アクセシビリティ検証完了
- [ ] 多言語表示確認（日英）

### パフォーマンス条件
- [ ] アプリ起動時間 < 3秒
- [ ] アドバイス生成 < 10秒
- [ ] メモリ使用量 < 150MB
- [ ] バッテリー効率: 良好レベル

### UX条件
- [ ] オンボーディング完了率 > 90%
- [ ] 主要操作3タップ以内
- [ ] エラー状態適切表示
- [ ] オフライン機能動作確認

---

## 📚 関連ドキュメント

### 必読文書
- **[Swift Coding Standards](.claude/swift-coding-standards.md)** - Swift実装規約
- **[TypeScript Hono Standards](.claude/typescript-hono-standards.md)** - バックエンド規約  
- **[Product Specification](../tempo-ai-product-spec.md)** - 製品仕様
- **[Technical Specification](../tempo-ai-technical-spec.md)** - 技術仕様

### 開発参考資料
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン
- **Apple Human Interface Guidelines** - iOS UI/UX
- **SwiftUI Documentation** - フレームワーク仕様
- **Claude API Documentation** - AI統合

---

## ✅ Definition of Done

### 機能完了条件
1. **オンボーディング**: 4ページ完全実装・多言語対応
2. **ヘルスステータス**: カラーコード表示・計算ロジック動作
3. **挨拶システム**: 天気・時間対応・自然な日本語
4. **環境アラート**: 気圧・花粉・大気質統合
5. **テスト**: Unit/Integration/UI テスト完備

### 技術完了条件
1. **コード品質**: Swift/TypeScript規約100%準拠
2. **テストカバレッジ**: 85%以上達成
3. **パフォーマンス**: 全指標クリア
4. **アクセシビリティ**: VoiceOver完全対応
5. **多言語化**: 日英完全対応・テスト済み

### デプロイ準備完了条件
1. **ビルド**: エラー/警告ゼロ
2. **セキュリティ**: 脆弱性スキャンパス
3. **ドキュメント**: 実装ドキュメント更新完了
4. **設定**: 本番環境準備完了
5. **監視**: ログ・メトリクス設定完了

---

**Next Phase**: [Phase 2: Advanced AI Features](phase-2-advanced-ai-features.md)