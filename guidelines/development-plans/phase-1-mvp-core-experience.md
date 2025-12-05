# 🚀 Phase 1: MVP コア体験実装計画書

**実施期間**: 3-4 週間 | **対象読者**: 開発チーム | **最終更新**: 2025 年 12 月 5 日  
**前提条件**: Phase 0 完了（品質基盤安定化 + 多言語化基盤構築）

---

## 🔧 実装前必須確認事項

### 📚 参照必須ドキュメント

1. **全体仕様把握**: [guidelines/tempo-ai-product-spec.md](../tempo-ai-product-spec.md) - プロダクト全体像とターゲット理解
2. **開発ルール確認**: [CLAUDE.md](../../CLAUDE.md) - 開発哲学、品質基準、プロセス
3. **Swift 標準確認**: [.claude/swift-coding-standards.md](../../.claude/swift-coding-standards.md) - Swift 実装ルール
4. **TypeScript 標準確認**: [.claude/typescript-hono-standards.md](../../.claude/typescript-hono-standards.md) - Backend 実装ルール

### 🧪 テスト駆動開発（TDD）必須要件

- **カバレッジ目標**: Backend ≥80%, iOS ≥80%
- **TDD サイクル**: Red → Green → Blue → Integrate
- **継続的品質**: 全実装でテストファースト
- **品質ゲート**: 実装完了前に必ずテスト実行・確認

### 📦 コミット戦略

- **細かい単位でコミット**: 機能単位、テスト単位での適切な粒度
- **明確なコミットメッセージ**: 変更内容と理由を簡潔に記載
- **継続的統合**: 各コミット後の CI/CD 確認

---

## 🎯 概要

Phase 1 では、Tempo AI の**コア体験**を実装します。美麗なオンボーディングフロー、HealthKit と環境データを活用したパーソナライズアドバイス、カラーコード化ヘルスステータス、基本的な環境アラートによって、ユーザーが毎朝最適化された健康アドバイスを受け取れる MVP を完成させます。

---

## 📊 Phase 1 目標と成果物

### 実装範囲

- **🌟 美麗 4 ページオンボーディングフロー** - 権限取得とアプリ価値訴求
- **🏠 メインホーム画面** - パーソナライズ挨拶とヘルスステータス表示
- **🎨 カラーコード化ヘルスステータス** - 絶好調/良好/ケア/休息モード（4 段階）
- **🤖 AI アドバイス生成エンジン** - HealthKit + 環境データ + Claude API 統合
- **🌤️ 環境対応システム** - 天気・気温に基づくパーソナライズアドバイス
- **⚠️ 基本環境アラート** - 極端な気温・悪天候時のアラート
- **📱 基本ナビゲーション** - プレースホルダーを含む 5 タブ構造

### 技術目標

- **テストカバレッジ**: Backend ≥80%, iOS ≥80%
- **パフォーマンス**: アドバイス生成 ≤5 秒、画面遷移 ≤1 秒
- **多言語対応**: 日英完全対応（基本リソース実装済み）
- **エラーハンドリング**: 全 API 呼び出しで適切なエラー処理と再試行機構

---

## 🧪 テスト駆動開発（TDD）アプローチ

### TDD 実装フロー

1. **Red** - 機能要件テスト作成（失敗確認）
2. **Green** - 最小限実装でテスト通過
3. **Blue** - リファクタリング（テスト維持）
4. **Integrate** - 統合テストで品質確保

### テスト戦略

- **Unit Tests**: 各 ViewModel と Service 個別テスト
- **Integration Tests**: API 連携とデータフロー検証
- **UI Tests**: ユーザーフロー全体の End-to-End テスト
- **Performance Tests**: レスポンス時間と同期処理検証

---

## 📋 実装タスク

### 1. オンボーディングフロー実装（TDD）

#### 1.1 OnboardingFlow 実装

```swift
// ios/TempoAI/TempoAI/Views/Onboarding/OnboardingFlowView.swift
struct OnboardingFlowView: View {
    @StateObject private var viewModel: OnboardingViewModel = OnboardingViewModel()

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            WelcomePageView().tag(0)
            HealthKitPermissionPageView().tag(1)
            LocationPermissionPageView().tag(2)
            CompletionPageView().tag(3)
        }
        .tabViewStyle(.page)
        .onAppear { viewModel.trackOnboardingStart() }
    }
}
```

**コミットポイント**: オンボーディング基本構造実装

#### 1.2 PermissionManager 統合

```swift
// ios/TempoAI/TempoAI/Services/PermissionManager.swift
class PermissionManager: ObservableObject {
    @Published var healthKitStatus: PermissionStatus = .notDetermined
    @Published var locationStatus: PermissionStatus = .notDetermined

    func requestHealthKitPermission() async -> PermissionStatus {
        // HealthKit権限要求実装
    }

    func requestLocationPermission() async -> PermissionStatus {
        // 位置情報権限要求実装
    }
}
```

**コミットポイント**: 権限管理機能実装

#### 1.3 TDD テスト実装

```swift
// ios/TempoAI/TempoAITests/Onboarding/OnboardingFlowTests.swift
class OnboardingFlowTests: XCTestCase {
    func testOnboardingCompleteFlow() {
        let expectation = XCTestExpectation(description: "Onboarding completed")
        let viewModel = OnboardingViewModel()

        // ページ遷移テスト
        XCTAssertEqual(viewModel.currentPage, 0)
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 1)

        // 権限取得完了テスト
        viewModel.completeOnboarding {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(viewModel.isOnboardingCompleted)
    }
}
```

**コミットポイント**: オンボーディングテスト完了

### 2. ヘルスステータス分析エンジン実装（TDD）

#### 2.1 HealthStatusAnalyzer 実装

```swift
// ios/TempoAI/TempoAI/Services/HealthStatusAnalyzer.swift
class HealthStatusAnalyzer: ObservableObject {
    @Published var currentStatus: HealthStatus = .unknown

    func analyzeHealthStatus(from data: HealthKitData) async -> HealthStatus {
        // HRV、睡眠、心拍数を総合分析
        let hvrScore = analyzeHRV(data.hrv)
        let sleepScore = analyzeSleep(data.sleep)
        let activityScore = analyzeActivity(data.activity)

        return calculateOverallStatus(hrv: hvrScore, sleep: sleepScore, activity: activityScore)
    }

    private func calculateOverallStatus(hrv: Double, sleep: Double, activity: Double) -> HealthStatus {
        let average = (hrv + sleep + activity) / 3
        switch average {
        case 0.8...1.0: return .optimal    // 絶好調
        case 0.6..<0.8: return .good       // 良好
        case 0.4..<0.6: return .care       // ケアモード
        default: return .rest              // 休息モード
        }
    }
}

enum HealthStatus: String, CaseIterable {
    case optimal = "optimal"    // 🟢 絶好調
    case good = "good"         // 🟡 良好
    case care = "care"         // 🟠 ケアモード
    case rest = "rest"         // 🔴 休息モード
    case unknown = "unknown"   // ⚪ 分析中

    var color: Color {
        switch self {
        case .optimal: return .green
        case .good: return .yellow
        case .care: return .orange
        case .rest: return .red
        case .unknown: return .gray
        }
    }

    var localizedTitle: String {
        NSLocalizedString("health_status_\(rawValue)", comment: "")
    }
}
```

**コミットポイント**: ヘルスステータス分析エンジン実装

#### 2.2 Backend TDD テスト実装

```typescript
// backend/tests/services/health-analyzer.test.ts
describe("HealthStatus Analysis", () => {
  it("should return optimal status for excellent metrics", () => {
    const mockData = {
      hrv: { average: 55, trend: "stable" },
      sleep: { duration: 8.5, deep: 2.2, rem: 1.8, efficiency: 0.95 },
      heart_rate: { resting: 58, average: 75 },
      activity: { steps: 12000, calories: 2400 },
    };

    const result = analyzer.analyzeHealthStatus(mockData);
    expect(result.status).toBe("optimal");
    expect(result.confidence).toBeGreaterThan(0.8);
  });
});
```

**コミットポイント**: ヘルスステータステスト完了

### 3. AI アドバイス生成エンジン実装（TDD）

#### 3.1 AdviceGenerationService 実装

```typescript
// backend/src/services/advice-generation.ts
export interface DailyAdvice {
  theme: "optimal" | "care" | "recovery";
  summary: string;
  greeting: string;
  meal_plan: {
    breakfast: string;
    lunch: string;
    dinner: string;
  };
  exercise_plan: string;
  wellness_plan: string;
  environmental_alerts: EnvironmentAlert[];
}

export const generateDailyAdvice = async (
  request: DailyAdviceRequest
): Promise<DailyAdvice> => {
  const prompt = buildAdvicePrompt(request);
  const rawAdvice = await claudeService.generateAdvice(prompt);
  const structuredAdvice = parseAdviceResponse(rawAdvice);

  const environmentAlerts = generateEnvironmentAlerts(
    request.environmentData,
    request.healthData.status
  );

  return {
    ...structuredAdvice,
    environmental_alerts: environmentAlerts,
    greeting: generatePersonalizedGreeting(
      request.userProfile,
      request.environmentData,
      request.healthData.status
    ),
  };
};
```

**コミットポイント**: AI アドバイス生成機能実装

### 4. ホーム画面実装（TDD）

#### 4.1 HomeView 実装

```swift
// ios/TempoAI/TempoAI/Views/Home/HomeView.swift
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    @State private var showingAdviceDetail: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    GreetingCardView(greeting: viewModel.greeting)
                    HealthStatusCardView(
                        status: viewModel.healthStatus,
                        onTap: { showingAdviceDetail = true }
                    )

                    if !viewModel.environmentAlerts.isEmpty {
                        EnvironmentAlertsView(alerts: viewModel.environmentAlerts)
                    }

                    AdviceSummaryCardView(
                        advice: viewModel.dailyAdvice,
                        onViewDetails: { showingAdviceDetail = true }
                    )
                }
                .padding()
            }
            .navigationTitle("today")
            .refreshable { await viewModel.refreshData() }
        }
        .sheet(isPresented: $showingAdviceDetail) {
            AdviceDetailView(advice: viewModel.dailyAdvice)
        }
        .task { await viewModel.loadInitialData() }
    }
}
```

**コミットポイント**: ホーム画面 UI 実装

### 5. 環境アラート統合

#### 5.1 EnvironmentAlertService 実装

```typescript
// backend/src/services/environment-alert.ts
export interface EnvironmentAlert {
  type: "temperature" | "weather" | "air_quality" | "pressure";
  severity: "low" | "medium" | "high";
  title: string;
  message: string;
  actionable_advice: string;
}

export const generateEnvironmentAlerts = (
  environmentData: EnvironmentData,
  healthStatus: HealthStatus
): EnvironmentAlert[] => {
  const alerts: EnvironmentAlert[] = [];

  // 極端な気温アラート
  if (environmentData.weather.temperature > 30) {
    alerts.push({
      type: "temperature",
      severity: "high",
      title: "暑さ注意",
      message: `気温が${environmentData.weather.temperature}°Cです`,
      actionable_advice: "十分な水分補給と日陰での休息を心がけましょう",
    });
  }

  return alerts;
};
```

**コミットポイント**: 環境アラート機能実装

### 6. 基本ナビゲーション実装

```swift
// ios/TempoAI/TempoAI/Views/MainTabView.swift
struct MainTabView: View {
    @State private var selectedTab: Tab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("today")
                }
                .tag(Tab.today)

            PlaceholderView(feature: "history")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("history")
                }
                .tag(Tab.history)

            // 他のタブも同様に実装
        }
    }
}
```

**コミットポイント**: 基本ナビゲーション完了

---

## 🧪 テスト戦略

### テスト完了基準

1. **Unit Tests**: ViewModel と Service 層で ≥80%カバレッジ
2. **Integration Tests**: API 連携とデータフロー検証
3. **UI Tests**: オンボーディング〜ホーム画面の完全フロー
4. **Performance Tests**: アドバイス生成 ≤5 秒、画面遷移 ≤1 秒

### 実行コマンド

```bash
# iOS テスト実行
cd ios && swift test

# Backend テスト実行
cd backend && pnpm run test

# カバレッジ確認
cd backend && pnpm run test:coverage
```

---

## 📦 成果物

### 新規実装ファイル

**iOS (Swift)**

- `Views/Onboarding/OnboardingFlowView.swift`
- `Views/Home/HomeView.swift`
- `ViewModels/HomeViewModel.swift`
- `Services/HealthStatusAnalyzer.swift`
- `Services/PermissionManager.swift`
- `Views/MainTabView.swift`

**Backend (TypeScript)**

- `src/services/advice-generation.ts`
- `src/services/environment-alert.ts`
- `src/types/daily-advice.ts`
- `src/api/health/analyze.ts`

### テストファイル

- `TempoAITests/Onboarding/OnboardingFlowTests.swift`
- `TempoAITests/ViewModels/HomeViewModelTests.swift`
- `backend/tests/services/advice-generation.test.ts`
- `backend/tests/services/health-analyzer.test.ts`

---

## ⏱️ スケジュール

| タスク                           | 期間      | コミットポイント                  |
| -------------------------------- | --------- | --------------------------------- |
| オンボーディングフロー実装       | 4 日      | 基本構造 → 権限管理 → テスト      |
| ヘルスステータス分析エンジン実装 | 3 日      | エンジン実装 → テスト完了         |
| AI アドバイス生成エンジン実装    | 5 日      | サービス実装 → API 統合 → テスト  |
| ホーム画面実装                   | 4 日      | UI 実装 → ViewModel → 統合テスト  |
| 環境アラート統合                 | 2 日      | アラート機能 → 統合完了           |
| 基本ナビゲーション実装           | 2 日      | タブ構造 → プレースホルダー       |
| 統合テスト・パフォーマンステスト | 3 日      | E2E テスト → パフォーマンス最適化 |
| **合計**                         | **23 日** |                                   |

---

## 🎯 Phase 2 への準備

Phase 1 完了により、以下が整備され Phase 2 の実装が可能になります：

### 引き継ぎ項目

- **安定したオンボーディング体験** - ユーザー権限管理とデータ収集基盤
- **コアアドバイス生成機能** - Claude API 統合と HealthKit データ活用
- **基本 UI/UX パターン** - カード型レイアウトとカラーコード化ステータス
- **多言語対応基盤** - 日英リソース管理とローカライゼーション

### Phase 2 での拡張点

- **朝のクイックチェックイン機能** - 主観的データによるアドバイス再カスタマイズ
- **詳細教育的アドバイス画面** - インタラクティブコンテンツと理由説明
- **文化適応システム** - 地域別食材データベースと季節対応
- **拡張環境アラート** - 気圧病・花粉・大気質統合

---

**🔍 Phase 1 の成功により、ユーザーは毎朝パーソナライズされた健康アドバイスを受け取り、データドリブンなヘルスケア体験を開始できるようになります。**
