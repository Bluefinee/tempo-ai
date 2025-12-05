# 📋 Phase 0: 基盤修正 + 多言語化基盤構築計画書

**実施期間**: 1.5-2 週間  
**対象読者**: 開発チーム  
**最終更新**: 2025 年 12 月 5 日

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

Phase 0 では、現在の実装基盤の品質を安定化し、**日英完全対応の多言語化アーキテクチャを構築**します。品質ゲートの強化、テストカバレッジの改善に加え、最初から日本語対応を組み込むことで、後続フェーズでスムーズな多言語展開を実現します。

---

## 📊 現状分析

### ✅ 良好な状態

- バックエンド API テストカバレッジ 93%以上
- CI/CD パイプライン構築済み
- TypeScript + Hono の堅固なアーキテクチャ
- SwiftUI UI テスト実装済み

### 🔧 修正が必要な項目

- **リンティングエラー**: UIIdentifiers.swift の末尾改行問題
- **テストの不安定性**: 一部のエラー処理テストでランダム失敗
- **品質ゲート**: iOS 側で SwiftLint 警告が残存
- **開発効率**: 繰り返し手動実行されているコマンドの自動化
- **多言語対応基盤**: 国際化アーキテクチャ未構築

---

## 🏗️ 実装計画

### Stage 1: 基盤品質安定化

#### 1.1 リンティングエラー修正

```bash
# UIIdentifiers.swiftの末尾改行追加
echo "" >> ios/TempoAI/TempoAI/Shared/UIIdentifiers.swift

# SwiftLint実行・確認
cd ios && swiftlint lint --strict
```

#### 1.2 テスト安定化

**対象**: Claude API 統合テストの信頼性向上

**修正アプローチ**:

```typescript
// backend/src/services/claude.ts - リトライロジック改善
export const generateAdviceWithRetry = async (
  healthData: HealthData,
  locationData: LocationData,
  options: { maxRetries?: number } = {}
): Promise<DailyAdvice> => {
  const maxRetries = options.maxRetries ?? 3;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await callClaudeAPIWithTimeout(
        healthData,
        locationData,
        15000
      );
      return parseAndValidateResponse(response.data);
    } catch (error) {
      if (attempt === maxRetries || !isRetryableError(error)) {
        throw error;
      }

      const backoffDelay = calculateExponentialBackoff(attempt);
      await new Promise((resolve) => setTimeout(resolve, backoffDelay));
    }
  }
};
```

#### 1.3 品質ゲート強化

**実装ファイル**: `scripts/quality-check-all.sh`

```bash
#!/bin/bash
set -e

echo "🔍 Running comprehensive quality checks..."

# iOS品質チェック
cd ios
echo "📱 iOS SwiftLint check..."
swiftlint lint --strict
echo "🧪 iOS Unit Tests..."
xcodebuild test -scheme TempoAI -destination 'platform=iOS Simulator,name=iPhone 15'

# Backend品質チェック
cd ../backend
echo "💻 Backend TypeScript check..."
npm run typecheck
echo "🧪 Backend Unit Tests..."
npm test
echo "✨ Backend Lint check..."
npm run lint

echo "✅ All quality checks passed!"
```

### Stage 2: 多言語化基盤構築

#### 2.1 iOS 国際化アーキテクチャ

**String Catalog 実装**:

```swift
// ios/TempoAI/TempoAI/Shared/Localization/LocalizationManager.swift
import Foundation
import SwiftUI

@MainActor
class LocalizationManager: ObservableObject {
    static let shared: LocalizationManager = LocalizationManager()

    @Published var currentLanguage: SupportedLanguage = .japanese

    enum SupportedLanguage: String, CaseIterable {
        case japanese = "ja"
        case english = "en"

        var displayName: String {
            switch self {
            case .japanese: return "日本語"
            case .english: return "English"
            }
        }
    }

    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "user_language")
    }

    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "user_language"),
           let language = SupportedLanguage(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
}

// String+Localization.swift
extension String {
    var localized: String {
        let language = LocalizationManager.shared.currentLanguage

        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }

        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
```

#### 2.2 多言語リソース構築

**ja.lproj/Localizable.strings**:

```
// タブナビゲーション
"tab_today" = "今日";
"tab_history" = "履歴";
"tab_trends" = "傾向";
"tab_profile" = "プロフィール";

// 一般的なアクション
"button_get_started" = "始める";
"button_continue" = "続ける";
"button_cancel" = "キャンセル";
"button_done" = "完了";

// エラーメッセージ
"error_network" = "ネットワークに接続できません";
"error_healthkit_denied" = "HealthKitへのアクセスが拒否されました";
"error_location_denied" = "位置情報へのアクセスが拒否されました";

// HealthKit権限
"healthkit_permission_title" = "ヘルスケアデータへのアクセス";
"healthkit_permission_description" = "より良いアドバイスを提供するため、あなたのヘルスケアデータを使用させてください";
```

**en.lproj/Localizable.strings**:

```
// Tab Navigation
"tab_today" = "Today";
"tab_history" = "History";
"tab_trends" = "Trends";
"tab_profile" = "Profile";

// Common Actions
"button_get_started" = "Get Started";
"button_continue" = "Continue";
"button_cancel" = "Cancel";
"button_done" = "Done";

// Error Messages
"error_network" = "Unable to connect to network";
"error_healthkit_denied" = "HealthKit access denied";
"error_location_denied" = "Location access denied";

// HealthKit Permissions
"healthkit_permission_title" = "Access to Health Data";
"healthkit_permission_description" = "To provide better advice, please allow us to use your health data";
```

#### 2.3 バックエンド多言語対応

```typescript
// backend/src/utils/localization.ts
export interface LocalizedContent {
  ja: string;
  en: string;
}

export const getLocalizedMessage = (
  content: LocalizedContent,
  language: "ja" | "en" = "ja"
): string => {
  return content[language] || content.en;
};

// 使用例
const errorMessages = {
  networkError: {
    ja: "ネットワークエラーが発生しました",
    en: "A network error occurred",
  },
  invalidData: {
    ja: "無効なデータです",
    en: "Invalid data",
  },
};
```

### Stage 3: 開発効率化

#### 3.1 CLAUDE.md 準拠の自動化スクリプト

**実装ファイル**: `scripts/dev-commands.sh`

```bash
#!/bin/bash

# よく使用されるコマンドの統合スクリプト

case "$1" in
  "test-all")
    echo "🧪 Running all tests..."
    ./scripts/quality-check-all.sh
    ;;
  "build-ios")
    echo "📱 Building iOS app..."
    cd ios && xcodebuild -scheme TempoAI -destination generic/platform=iOS
    ;;
  "dev-backend")
    echo "💻 Starting backend development server..."
    cd backend && npm run dev
    ;;
  "lint-fix")
    echo "🔧 Running lint fixes..."
    cd ios && swiftlint --fix
    cd ../backend && npm run lint:fix
    ;;
  *)
    echo "Usage: $0 {test-all|build-ios|dev-backend|lint-fix}"
    exit 1
    ;;
esac
```

#### 3.2 CLAUDE.md アップデート

````markdown
# Phase 0 で推奨されるコマンド

## 品質チェック

```bash
# 包括的品質チェック
./scripts/quality-check-all.sh

# 特定プラットフォームのテスト
./scripts/dev-commands.sh test-all
```
````

## 開発サーバー

```bash
# バックエンド開発サーバー
./scripts/dev-commands.sh dev-backend

# iOSビルド
./scripts/dev-commands.sh build-ios
```

## リント修正

```bash
# 自動リント修正
./scripts/dev-commands.sh lint-fix
```

````

---

## 🧪 テスト戦略

### TDD実装アプローチ
1. **Red**: 現状動作保証テスト作成（失敗）
2. **Green**: 最小限修正でテスト通過
3. **Refactor**: コード品質改善
4. **Verify**: 品質ゲート全通過確認

### 必須テストカバレッジ
- **Unit Tests**: LocalizationManager, Claude API安定性
- **Integration Tests**: 多言語切り替え、権限管理
- **UI Tests**: 基本ナビゲーション（日英両言語）
- **Regression Tests**: 既存機能保護

### 主要テスト例
```swift
class LocalizationTests: XCTestCase {
    func testLanguageSwitching() {
        let manager = LocalizationManager.shared

        manager.setLanguage(.english)
        XCTAssertEqual(manager.currentLanguage, .english)
        XCTAssertEqual("tab_today".localized, "Today")

        manager.setLanguage(.japanese)
        XCTAssertEqual(manager.currentLanguage, .japanese)
        XCTAssertEqual("tab_today".localized, "今日")
    }
}
````

---

## 📅 実装スケジュール

### Week 1: 基盤安定化

- **Day 1-2**: リンティングエラー修正・品質ゲート強化
- **Day 3-4**: Claude API テスト安定化
- **Day 5**: 開発効率化スクリプト実装

### Week 2: 多言語化基盤

- **Day 1-2**: iOS 国際化アーキテクチャ構築
- **Day 3-4**: 多言語リソース実装（日英）
- **Day 5**: バックエンド多言語対応・統合テスト

---

## 🔧 技術実装詳細

### SwiftUI 多言語対応パターン

```swift
struct ContentView: View {
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("tab_today".localized, systemImage: "house")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("tab_history".localized, systemImage: "clock")
                }
                .tag(1)
        }
        .environmentObject(localization)
    }
}
```

### API 多言語レスポンス

```typescript
interface AdviceResponse {
  advice: LocalizedContent;
  recommendations: {
    breakfast: LocalizedContent;
    exercise: LocalizedContent;
    sleep: LocalizedContent;
  };
}

export const generateLocalizedAdvice = async (
  healthData: HealthData,
  language: "ja" | "en"
): Promise<AdviceResponse> => {
  const prompt =
    language === "ja"
      ? buildJapanesePrompt(healthData)
      : buildEnglishPrompt(healthData);

  const response = await callClaudeAPI(prompt);
  return parseLocalizedResponse(response, language);
};
```

---

## ⚡ パフォーマンス考慮

### iOS 最適化

- String Catalog の遅延読み込み
- 言語切り替え時のメモリ効率化
- UserDefaults 最小アクセス

### バックエンド最適化

- 多言語プロンプトのキャッシュ化
- Claude API レスポンス効率化
- 言語判定の最適化

---

## 🛡️ 品質保証

### 必須クライテリア

- [ ] SwiftLint エラー 0 件
- [ ] TypeScript エラー 0 件
- [ ] 全 Unit Test パス
- [ ] UI Test（日英両言語）パス
- [ ] Claude API テスト安定性 95%以上

### パフォーマンス基準

- [ ] アプリ起動時間 < 3 秒（両言語）
- [ ] 言語切り替え < 1 秒
- [ ] API レスポンス < 10 秒
- [ ] メモリ使用量 < 150MB

### 多言語品質基準

- [ ] 日本語 UI 完全表示
- [ ] 英語 UI 完全表示
- [ ] 文字化け 0 件
- [ ] レイアウト崩れ 0 件

---

## 📚 関連ドキュメント

- **[Swift Coding Standards](.claude/swift-coding-standards.md)** - Swift 実装規約
- **[TypeScript Hono Standards](.claude/typescript-hono-standards.md)** - バックエンド規約
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン
- **Apple Internationalization Guide** - iOS 多言語化

---

## ✅ Definition of Done

### 基盤修正完了条件

1. **品質ゲート**: 全リンティングエラー解消
2. **テスト安定性**: Claude API テスト成功率 95%以上
3. **開発効率**: 自動化スクリプト実装・動作確認
4. **ドキュメント**: CLAUDE.md 更新完了

### 多言語化完了条件

1. **アーキテクチャ**: LocalizationManager 実装・動作確認
2. **リソース**: 基本 UI 文言日英完備（50 項目以上）
3. **統合**: iOS/バックエンド多言語連携動作確認
4. **テスト**: 多言語 UI テスト完備

### デプロイ準備完了条件

1. **ビルド**: iOS/バックエンド共にエラーフリー
2. **テスト**: 全自動テストパス
3. **品質**: パフォーマンス基準クリア
4. **ドキュメント**: 実装ドキュメント完備

---

**Next Phase**: [Phase 1: MVP Core Experience](phase-1-mvp-core-experience.md)
