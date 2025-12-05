# 📋 Phase 0: 基盤修正 + 多言語化基盤構築計画書

**実施期間**: 1.5-2 週間 | **対象読者**: 開発チーム | **最終更新**: 2025 年 12 月 5 日

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

Phase 0 では、実装基盤の品質安定化と**日英完全対応の多言語化アーキテクチャ構築**を実施。品質ゲート強化、テストカバレッジ改善により、後続フェーズでのスムーズな多言語展開を実現します。

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

## 🧪 テスト駆動開発（TDD）戦略

### TDD 実装フロー

```bash
# UIIdentifiers.swiftの末尾改行追加
echo "" >> ios/TempoAI/TempoAI/Shared/UIIdentifiers.swift

# SwiftLint実行・確認
cd ios && swiftlint lint --strict
```

#### 1.2 テスト安定化

#### Swift 既存動作保証テスト

```swift
// ios/TempoAI/TempoAITests/Foundation/RegressionTests.swift
import XCTest
@testable import TempoAI

class FoundationRegressionTests: XCTestCase {

    /// Phase 0修正前の動作を保証するテスト
    func testUIIdentifiersIntegrity() {
        // 既存のUIIdentifier値がすべて変更されていないことを確認
        XCTAssertEqual(UIIdentifiers.Today.todayTab, "today-tab")
        XCTAssertEqual(UIIdentifiers.History.historyTab, "history-tab")
        XCTAssertEqual(UIIdentifiers.Trends.trendsTab, "trends-tab")
        XCTAssertEqual(UIIdentifiers.Profile.profileTab, "profile-tab")

        // UIIdentifiers.swift ファイル自体の整合性確認
        let identifiersContent = try? String(contentsOfFile: getUIIdentifiersFilePath())
        XCTAssertNotNil(identifiersContent, "UIIdentifiers.swift must be readable")
        XCTAssertTrue(identifiersContent!.hasSuffix("\n"), "File must end with newline")
    }

    func testCurrentHealthKitIntegration() {
        // 既存のHealthKit統合が破損していないことを確認
        let expectation = XCTestExpectation(description: "HealthKit integration preserved")
        let manager = HealthKitManager()

        manager.requestAuthorization { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTAssertTrue(error is HealthKitError, "Expected HealthKitError type")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }

    private func getUIIdentifiersFilePath() -> String {
        return Bundle(for: type(of: self)).bundlePath + "/UIIdentifiers.swift"
    }
}
```

#### TypeScript 既存動作保証テスト

```typescript
// backend/tests/foundation/regression.test.ts
import { describe, it, expect, beforeEach } from "vitest";
import { testClient } from "hono/testing";
import app from "../../src/index";

describe("Phase 0 Regression Prevention", () => {
  const client = testClient(app);

  describe("Existing API Contracts", () => {
    it("should maintain health analyze endpoint signature", async () => {
      const mockRequest = {
        user_id: "test-user-123",
        health_data: {
          sleep: { duration: 8.5, deep: 2.1, rem: 1.8, light: 3.6, awake: 1.0 },
          hrv: { average: 42.5, trend: "stable" },
          heart_rate: { resting: 65, average: 78, max: 145 },
          activity: { steps: 8500, calories: 2100, distance: 6.2 },
        },
        location: { latitude: 35.6762, longitude: 139.6503 },
        user_profile: { age: 30, gender: "male" },
      };

      const response = await client.api.health.analyze.$post({
        json: mockRequest,
      });

      expect(response.status).toBe(200);
      const data = await response.json();
      expect(data).toHaveProperty("success");
      expect(data).toHaveProperty("data");
      expect(data.success).toBe(true);
    });

    it("should preserve Claude service response format", async () => {
      // 既存のClaudeサービスレスポンス形式を維持
      const mockHealthData = {
        sleep: { duration: 7.5, deep: 1.8, rem: 1.5, light: 3.2, awake: 1.0 },
        hrv: { average: 38.2, trend: "declining" },
      };

      const response = await claudeService.generateAdvice(
        mockHealthData,
        mockLocationData
      );

      // 既存フォーマットの構造確認
      expect(response).toHaveProperty("theme");
      expect(response).toHaveProperty("summary");
      expect(response).toHaveProperty("meal_plan");
      expect(response).toHaveProperty("exercise_plan");
      expect(response).toHaveProperty("wellness_plan");
      expect(response.theme).toBeOneOf(["optimal", "care", "recovery"]);
    });
  });
});
```

### 品質ゲート強制テスト

#### Swift 品質基準テスト

```swift
// ios/TempoAI/TempoAITests/Quality/QualityGateTests.swift
class QualityGateTests: XCTestCase {
    func testSwiftLintStrictCompliance() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/swiftlint")
        process.arguments = ["--strict"]
        XCTAssertEqual(process.terminationStatus, 0)
    }

    func testExplicitTypeDeclarations() {
        let violatingPatterns = ["let .* =", "var .* =", "@Published var .* ="]
        let sourceFiles = findSwiftFiles()
        for file in sourceFiles {
            let content = try! String(contentsOfFile: file)
            for pattern in violatingPatterns {
                let regex = try! NSRegularExpression(pattern: pattern)
                XCTAssertEqual(regex.matches(in: content, range: NSRange(content.startIndex..., in: content)).count, 0)
            }
        }
    }
}
```

#### TypeScript 品質基準テスト

```typescript
// backend/tests/quality/quality-gate.test.ts
describe("Quality Gate Enforcement", () => {
  it("should have zero TypeScript errors in strict mode", async () => {
    execSync("npx tsc --noEmit --strict", { stdio: "pipe" });
  });

  it("should achieve minimum test coverage threshold", async () => {
    const coverage = JSON.parse(
      execSync("npx vitest run --coverage --reporter=json", {
        encoding: "utf8",
      })
    );
    expect(coverage.total.lines.pct).toBeGreaterThanOrEqual(95);
  });

  it("should have no any types in codebase", async () => {
    const files = await glob("src/**/*.ts");
    for (const file of files) {
      const content = await fs.readFile(file, "utf8");
      expect(content.match(/:\s*any[^a-zA-Z]/)).toBeNull();
    }
  });
});
```

## 📋 実装タスク

### 1. 品質問題の即座修正（TDD 準拠）

#### 1.1 Swift Linting 修正

- **ファイル**: `ios/TempoAI/TempoAI/Tests/Shared/UIIdentifiers.swift:317`
- **問題**: 末尾改行不足（trailing_newline violation）
- **修正**: ファイル末尾に適切な改行を追加
- **テスト**: `cd ios && ./scripts/fix-all.sh`で自動修正確認

#### 1.2 バックエンドテスト安定化（TDD）

- **対象**: Claude API サービステスト
- **問題**: JSON レスポンス解析エラーのランダム発生
- **TDD アプローチ**:

**Step 1: Red - 不安定性を再現するテスト作成**

```typescript
// backend/tests/services/claude-instability.test.ts
describe("Claude Service Instability", () => {
  it("should fail with malformed JSON", async () => {
    const flakyClaude = vi.fn().mockResolvedValue({ data: '{"incomplete' });
    await expect(
      claudeService.generateAdvice(mockHealthData, flakyClaude)
    ).rejects.toBeInstanceOf(Error);
  });
});
```

**Step 2: Green - 最小限の安定化実装**

```typescript
// backend/src/services/claude.ts - Enhanced Error Handling
import { z } from "zod";

const ClaudeResponseSchema = z.object({
  theme: z.enum(["optimal", "care", "recovery"]),
  summary: z.string(),
  meal_plan: z.object({
    breakfast: z.string(),
    lunch: z.string(),
    dinner: z.string(),
  }),
  exercise_plan: z.string(),
  wellness_plan: z.string(),
});

export const generateAdvice = async (
  healthData: HealthData,
  locationData: LocationData,
  options: { maxRetries?: number } = {}
): Promise<DailyAdvice> => {
  const { maxRetries = 3, timeout = 30000 } = options;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const rawResponse = await callClaudeAPIWithTimeout(
        healthData,
        locationData,
        timeout
      );

      // JSON解析の安全性向上
      let parsedData: unknown;
      try {
        parsedData =
          typeof rawResponse.data === "string"
            ? JSON.parse(rawResponse.data)
            : rawResponse.data;
      } catch (parseError) {
        throw new ClaudeServiceError(
          `JSON parsing failed (attempt ${attempt}/${maxRetries})`,
          "JSON_PARSE_ERROR",
          { originalData: rawResponse.data, parseError: parseError.message }
        );
      }

      // スキーマ検証の厳格化
      const validationResult = ClaudeResponseSchema.safeParse(parsedData);
      if (!validationResult.success) {
        throw new ClaudeServiceError(
          `Response validation failed (attempt ${attempt}/${maxRetries})`,
          "SCHEMA_VALIDATION_ERROR",
          {
            validationErrors: validationResult.error.issues,
            receivedData: parsedData,
          }
        );
      }

      return validationResult.data;
    } catch (error) {
      const isLastAttempt = attempt === maxRetries;
      const shouldRetry = isRetryableError(error) && !isLastAttempt;

      if (shouldRetry) {
        const backoffDelay = calculateExponentialBackoff(attempt);
        await new Promise((resolve) => setTimeout(resolve, backoffDelay));
        continue;
      }

      throw error;
    }
  }
};

const callClaudeAPIWithTimeout = async (
  healthData: HealthData,
  locationData: LocationData,
  timeout: number
): Promise<{ data: unknown }> => {
  return Promise.race([
    callClaudeAPI(healthData, locationData),
    new Promise((_, reject) =>
      setTimeout(
        () =>
          reject(
            new ClaudeServiceError(
              `Request timed out after ${timeout}ms`,
              "TIMEOUT_ERROR"
            )
          ),
        timeout
      )
    ),
  ]);
};

const isRetryableError = (error: Error): boolean => {
  if (error instanceof ClaudeServiceError) {
    return (
      error.code === "JSON_PARSE_ERROR" ||
      error.code === "TIMEOUT_ERROR" ||
      error.code === "NETWORK_ERROR"
    );
  }
  return false;
};

const calculateExponentialBackoff = (attempt: number): number => {
  const baseDelay = 1000; // 1秒
  const maxDelay = 10000; // 10秒
  const delay = Math.min(baseDelay * Math.pow(2, attempt - 1), maxDelay);
  const jitter = Math.random() * 0.3 * delay; // 30%のジッター
  return delay + jitter;
};

class ClaudeServiceError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly context?: Record<string, unknown>
  ) {
    super(message);
    this.name = "ClaudeServiceError";
  }
}
```

**Step 3: Blue - 安定化されたテスト実装**

```typescript
// backend/tests/services/claude-stable.test.ts
describe("Claude Service Stability (Post-Fix)", () => {
  describe("Error Handling Robustness", () => {
    it("should handle malformed JSON gracefully", async () => {
      const mockAPI = vi
        .fn()
        .mockResolvedValue({ data: '{"advice": "incomplete' });

      await expect(
        claudeService.generateAdvice(mockHealthData, mockLocationData, {
          claudeAPI: mockAPI,
        })
      )
        .rejects.toThrow(ClaudeServiceError)
        .rejects.toHaveProperty("code", "JSON_PARSE_ERROR");
    });

    it("should retry on transient failures with exponential backoff", async () => {
      let callCount = 0;
      const mockAPI = vi.fn().mockImplementation(() => {
        callCount++;
        if (callCount < 3) {
          throw new ClaudeServiceError("Transient failure", "NETWORK_ERROR");
        }
        return { data: validClaudeResponse };
      });

      const startTime = Date.now();
      const result = await claudeService.generateAdvice(
        mockHealthData,
        mockLocationData,
        {
          claudeAPI: mockAPI,
          maxRetries: 3,
        }
      );
      const endTime = Date.now();

      expect(callCount).toBe(3);
      expect(result).toBeDefined();
      expect(endTime - startTime).toBeGreaterThan(1000); // バックオフ確認
    });

    it("should validate response schema strictly", async () => {
      const mockAPI = vi.fn().mockResolvedValue({
        data: { incomplete: "response", missing: "required fields" },
      });

      await expect(
        claudeService.generateAdvice(mockHealthData, mockLocationData, {
          claudeAPI: mockAPI,
        })
      )
        .rejects.toThrow(ClaudeServiceError)
        .rejects.toHaveProperty("code", "SCHEMA_VALIDATION_ERROR");
    });

    it("should handle timeout scenarios", async () => {
      const mockAPI = vi
        .fn()
        .mockImplementation(
          () =>
            new Promise((resolve) =>
              setTimeout(() => resolve({ data: validClaudeResponse }), 5000)
            )
        );

      await expect(
        claudeService.generateAdvice(mockHealthData, mockLocationData, {
          claudeAPI: mockAPI,
          timeout: 1000,
        })
      )
        .rejects.toThrow(ClaudeServiceError)
        .rejects.toHaveProperty("code", "TIMEOUT_ERROR");
    });
  });

  describe("Stability Under Load", () => {
    it("should maintain stability across 100 concurrent requests", async () => {
      const promises = Array.from({ length: 100 }, () =>
        claudeService.generateAdvice(mockHealthData, mockLocationData)
      );

      const results = await Promise.allSettled(promises);
      const successCount = results.filter(
        (r) => r.status === "fulfilled"
      ).length;
      const errorCount = results.filter((r) => r.status === "rejected").length;

      // 95%以上の成功率を期待
      expect(successCount).toBeGreaterThanOrEqual(95);
      expect(errorCount).toBeLessThanOrEqual(5);
    });
  });
});
```

- **確認**: `pnpm run test:coverage`で安定動作確認
- **品質目標**: 連続 10 回実行で失敗率 0%

#### 2.1 iOS 国際化アーキテクチャ

#### 2.1 エッジケーステスト追加

```typescript
// backend/tests/services/claude.test.ts
describe("Claude Service Edge Cases", () => {
  it("should handle malformed JSON response gracefully");
  it("should retry on transient failures");
  it("should validate response schema strictly");
});
```

#### 2.2 iOS 統合テスト強化

```swift
// ios/TempoAI/TempoAITests/Integration/
class HealthKitIntegrationTests: XCTestCase {
    func testHealthKitPermissionFlow()
    func testLocationPermissionFlow()
    func testAPIClientErrorHandling()
}
```

### 3. 多言語化基盤構築

#### 3.1 iOS 国際化アーキテクチャ

```swift
// ios/TempoAI/TempoAI/Localization/LocalizationManager.swift
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: SupportedLanguage = .systemDefault

    static let shared = LocalizationManager()

    var isJapanese: Bool { currentLanguage == .japanese }
    var isEnglish: Bool { currentLanguage == .english }

    func localizedString(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}

enum SupportedLanguage: String, CaseIterable {
    case japanese = "ja"
    case english = "en"
    case systemDefault = "system"

    var displayName: String {
        switch self {
        case .japanese: return "日本語"
        case .english: return "English"
        case .systemDefault: return NSLocalizedString("system_language", comment: "")
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

#### 3.2 基本多言語リソース作成

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

**日本語リソース例**:

```
// ja.lproj/Localizable.strings
"app_name" = "Tempo AI";
"today" = "今日";
"history" = "履歴";
"trends" = "傾向";
"profile" = "プロフィール";
"learn" = "学ぶ";
"good_morning" = "おはようございます";
"health_status_optimal" = "絶好調";
"health_status_care" = "ケアモード";
```

#### 3.3 バックエンド多言語対応

```typescript
// backend/src/utils/localization.ts
export interface LocalizationContext {
  language: "ja" | "en";
  region: "JP" | "US" | "CA" | "GB";
  timeZone: string;
}

export const generateLocalizedAdvice = async (
  healthData: HealthData,
  localization: LocalizationContext
): Promise<LocalizedAdvice> => {
  const prompt = `
言語: ${localization.language === "ja" ? "日本語" : "英語"}
地域: ${localization.region}

以下のHealthKitデータから今日のパーソナライズされたアドバイスを生成:
${JSON.stringify(healthData)}

形式:
- 自然で親しみやすいトーン
- 文化的に適切な食事・運動提案
- ${
    localization.language === "ja"
      ? "敬語は使わず、フレンドリーな表現"
      : "Casual but professional tone"
  }
`;

  const response = await callClaudeAPI(prompt);
  return parseAdviceResponse(response, localization);
};
```

### Stage 3: 開発効率化

#### 3.1 CLAUDE.md 準拠の自動化スクリプト

**実装ファイル**: `scripts/dev-commands.sh`

#### 4.1 Enhanced Quality Gates Integration

```bash
# scripts/pre-commit-check.sh - Enhanced pre-commit quality verification
#!/bin/bash
set -e

# Stage 1: Fast checks
if ! npx tsc --noEmit --strict; then echo "❌ TypeScript violations"; exit 1; fi
if ! cd ios && ./scripts/quality-check.sh; then echo "❌ Swift violations"; exit 1; fi
if ! cd backend && npx biome check .; then echo "❌ Biome violations"; exit 1; fi

# Stage 2: Test suites
if ! cd backend && pnpm run test; then echo "❌ Backend tests failed"; exit 1; fi
if ! cd ios && swift test; then echo "❌ Swift tests failed"; exit 1; fi

# Stage 3: Quality gates
if ! cd backend && pnpm run test tests/architecture/claude-md-compliance.test.ts; then
    echo "❌ CLAUDE.md compliance violations"; exit 1
fi

COVERAGE=$(cd backend && npx vitest run --coverage --reporter=json | jq '.total.lines.pct')
if (( $(echo "$COVERAGE < 95" | bc -l) )); then
    echo "❌ Test coverage below 95%"; exit 1
fi

echo "✅ All quality gates passed"
```

#### 4.2 Auto-fix Integration

```bash
# scripts/fix-all.sh - Enhanced auto-fixing with safety checks
#!/bin/bash
set -e

# Backup and fix iOS
git stash push -m "Auto-fix backup $(date)" || true
cd ios && swiftlint --fix --quiet
find . -name "*.swift" -not -path "./build/*" | xargs swift-format --in-place

# Fix backend
cd ../backend
npx biome check --write .
npx biome format --write .

# Verify all fixes
cd .. && make check || { git stash pop; exit 1; }
echo "✅ Auto-fix completed"
```

#### 4.3 Enhanced Development Scripts

```bash
# scripts/dev-setup.sh - Complete development environment setup
#!/bin/bash
set -e

# Check requirements and install tools
for cmd in brew node pnpm xcode-select; do
  command -v "$cmd" || { echo "❌ $cmd required"; exit 1; }
done

brew install swiftlint swift-format || true
cd backend && pnpm install
cd ../ios && swift package resolve || true

echo "✅ Setup completed. Run 'make check' to verify"
```

#### 4.4 Continuous Quality Monitoring

```bash
# scripts/quality-monitor.sh - Continuous quality monitoring
#!/bin/bash

echo "📊 Quality Metrics Dashboard"

# Get metrics
ts_errors=$(cd backend && npx tsc --noEmit --strict 2>&1 | wc -l || echo "0")
swift_warnings=$(cd ios && swiftlint --strict 2>&1 | grep -c "warning\|error" || echo "0")
coverage=$(cd backend && npx vitest run --coverage --reporter=json 2>/dev/null | jq -r '.total.lines.pct // 0')

# Display status
echo "TypeScript Errors: $ts_errors"
echo "Swift Warnings: $swift_warnings"
echo "Test Coverage: ${coverage}%"

# Overall readiness
if [ "$ts_errors" -eq 0 ] && [ "$swift_warnings" -eq 0 ] && (( $(echo "$coverage >= 95" | bc -l) )); then
    echo "Phase 1 Ready: ✅ YES"
else
    echo "Phase 1 Ready: ❌ NO"
fi
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

### テスト完了基準

1. **バックエンド**: 全テスト成功、カバレッジ 95%以上維持
2. **iOS**: SwiftLint エラー/警告 0 件、全 UI テスト成功
3. **統合**: `make check`エラーなし完走
4. **CI/CD**: 全品質ゲートパス

### 実行コマンド

```bash
# 全体品質チェック
make check

# バックエンド個別チェック
cd backend && pnpm run quality:check

# iOS個別チェック
cd ios && ./scripts/quality-check.sh

# 自動修正実行
./scripts/fix-all.sh
```

---

## 📦 成果物

---

## 🎯 CLAUDE.md 準拠品質基準

### Mandatory Quality Criteria

#### TypeScript/JavaScript Standards

- [ ] **Type Safety**: `tsc --strict --noEmit` で 0 エラー
- [ ] **No Any Types**: `any` type の使用禁止（`unknown` 使用）
- [ ] **Arrow Functions**: 関数宣言の代わりにアロー関数一貫使用
- [ ] **Explicit Return Types**: 全関数の戻り値型明示
- [ ] **Named Exports**: デフォルトエクスポート禁止
- [ ] **DRY Principle**: 共通ロジックの抽出とユーティリティ化

#### Swift Standards

- [ ] **Explicit Type Declarations**: 全プロパティの明示的型宣言
- [ ] **SwiftLint Compliance**: `swiftlint --strict` で 0 エラー・0 警告
- [ ] **File Length**: 1 ファイル 400 行以内（View 分解）
- [ ] **Line Length**: 1 行 120 文字以内
- [ ] **No Force Unwrapping**: 正当化なしの強制アンラップ禁止
- [ ] **Async/Await**: 非同期処理の現代的パターン使用

#### Architecture Standards (SOLID)

- [ ] **Single Responsibility**: 1 クラス 1 責任の原則
- [ ] **Open/Closed**: 拡張オープン・修正クローズ
- [ ] **Dependency Inversion**: 抽象への依存
- [ ] **Interface Segregation**: 小さな専用インターフェース

### 品質ゲート自動検証

#### Backend Quality Gates

```typescript
// backend/tests/architecture/claude-md-compliance.test.ts
import { describe, it, expect } from "vitest";
import { execSync } from "child_process";
import { glob } from "glob";
import fs from "fs/promises";

describe("CLAUDE.md Compliance Verification", () => {
  describe("TypeScript Standards", () => {
    it("should pass TypeScript strict mode with zero errors", async () => {
      const result = execSync("npx tsc --strict --noEmit", {
        encoding: "utf8",
        stdio: "pipe",
      });
      expect(result).toBe(""); // No output means no errors
    });

    it("should have zero any types in codebase", async () => {
      const files = await glob("src/**/*.ts");
      const violations: string[] = [];

      for (const file of files) {
        const content = await fs.readFile(file, "utf8");
        const anyMatches = content.match(/:\s*any[^a-zA-Z]/g);
        if (anyMatches) {
          violations.push(`${file}: ${anyMatches.join(", ")}`);
        }
      }

      expect(violations).toHaveLength(0);
    });

    it("should use arrow functions exclusively", async () => {
      const files = await glob("src/**/*.ts");
      const violations: string[] = [];

      for (const file of files) {
        const content = await fs.readFile(file, "utf8");
        const functionDeclarations = content.match(/^function\s+/gm);
        if (functionDeclarations) {
          violations.push(...functionDeclarations.map((f) => `${file}: ${f}`));
        }
      }

      expect(violations).toHaveLength(0);
    });

    it("should have explicit return types for all functions", async () => {
      const files = await glob("src/**/*.ts");
      const violations: string[] = [];

      for (const file of files) {
        const content = await fs.readFile(file, "utf8");
        // アロー関数で戻り値型が明示されていないパターンをチェック
        const implicitReturnTypes = content.match(/=\s*\([^)]*\)\s*=>\s*[^:]/g);
        if (implicitReturnTypes) {
          violations.push(...implicitReturnTypes.map((f) => `${file}: ${f}`));
        }
      }

      expect(violations).toHaveLength(0);
    });

    it("should use named exports only", async () => {
      const files = await glob("src/**/*.ts");
      const violations: string[] = [];

      for (const file of files) {
        const content = await fs.readFile(file, "utf8");
        const defaultExports = content.match(/export\s+default/g);
        if (defaultExports) {
          violations.push(
            `${file}: ${defaultExports.length} default export(s)`
          );
        }
      }

      expect(violations).toHaveLength(0);
    });
  });

  describe("Code Quality Standards", () => {
    it("should achieve minimum test coverage thresholds", async () => {
      const result = execSync("npx vitest run --coverage --reporter=json", {
        encoding: "utf8",
      });
      const coverage = JSON.parse(result);

      expect(coverage.total.lines.pct).toBeGreaterThanOrEqual(95);
      expect(coverage.total.branches.pct).toBeGreaterThanOrEqual(90);
      expect(coverage.total.functions.pct).toBeGreaterThanOrEqual(95);
      expect(coverage.total.statements.pct).toBeGreaterThanOrEqual(95);
    });

    it("should pass all biome checks without violations", async () => {
      const result = execSync("npx biome check .", {
        encoding: "utf8",
        stdio: "pipe",
      });
      expect(result).toBe(""); // No violations
    });

    it("should have JSDoc for all public APIs", async () => {
      const files = await glob("src/**/*.ts");
      const violations: string[] = [];

      for (const file of files) {
        const content = await fs.readFile(file, "utf8");
        // export された関数でJSDocコメントがないものをチェック
        const publicFunctions = content.match(/export\s+const\s+\w+\s*=.*?=>/g);
        if (publicFunctions) {
          for (const func of publicFunctions) {
            const funcIndex = content.indexOf(func);
            const beforeFunc = content
              .substring(0, funcIndex)
              .split("\n")
              .slice(-3)
              .join("\n");
            if (!beforeFunc.includes("/**")) {
              violations.push(`${file}: Missing JSDoc for ${func}`);
            }
          }
        }
      }

      expect(violations).toHaveLength(0);
    });
  });

  describe("Error Handling Standards", () => {
    it("should use custom error types for domain errors", async () => {
      const files = await glob("src/**/*.ts");
      const hasCustomErrors = files.some(async (file) => {
        const content = await fs.readFile(file, "utf8");
        return content.includes("extends Error");
      });

      expect(hasCustomErrors).toBe(true);
    });

    it("should never silently swallow exceptions", async () => {
      const files = await glob("src/**/*.ts");
      const violations: string[] = [];

      for (const file of files) {
        const content = await fs.readFile(file, "utf8");
        // 空のcatchブロックをチェック
        const emptyCatchBlocks = content.match(/catch\s*\([^)]*\)\s*\{\s*\}/g);
        if (emptyCatchBlocks) {
          violations.push(
            `${file}: ${emptyCatchBlocks.length} empty catch block(s)`
          );
        }
      }

      expect(violations).toHaveLength(0);
    });
  });
});
```

#### iOS Quality Gates

```swift
class LocalizationTests: XCTestCase {
    func testLanguageSwitching() {
        let manager = LocalizationManager.shared

class ClaudeMdComplianceTests: XCTestCase {

    func testSwiftCodingStandardsCompliance() {
        let violations = SwiftCodingStandardsChecker.checkCompliance()
        XCTAssertEqual(violations.count, 0,
                      "Swift Coding Standards violations: \(violations)")
    }

    func testExplicitTypeDeclarationsForAllProperties() {
        let sourceFiles = findAllSwiftFiles()
        var violations: [String] = []

        for file in sourceFiles {
            let content = try! String(contentsOfFile: file)

            // プロパティ宣言で型推論を使用している箇所をチェック
            let propertyPatterns = [
                "@Published var \\w+ =",
                "@State private var \\w+ =",
                "@StateObject private var \\w+ =",
                "let \\w+ =",
                "var \\w+ ="
            ]

            for pattern in propertyPatterns {
                let regex = try! NSRegularExpression(pattern: pattern)
                let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
                if matches.count > 0 {
                    violations.append("\(file): \(matches.count) implicit type declarations")
                }
            }
        }

        XCTAssertEqual(violations.count, 0,
                      "All properties must have explicit type declarations: \(violations)")
    }

    func testFileLengthLimits() {
        let sourceFiles = findAllSwiftFiles()
        var violations: [String] = []

        for file in sourceFiles {
            let content = try! String(contentsOfFile: file)
            let lineCount = content.components(separatedBy: .newlines).count

            if lineCount > 400 {
                violations.append("\(file): \(lineCount) lines (max 400)")
            }
        }

        XCTAssertEqual(violations.count, 0,
                      "Files must be ≤400 lines: \(violations)")
    }

    func testLineLengthLimits() {
        let sourceFiles = findAllSwiftFiles()
        var violations: [String] = []

        for file in sourceFiles {
            let content = try! String(contentsOfFile: file)
            let lines = content.components(separatedBy: .newlines)

            for (index, line) in lines.enumerated() {
                if line.count > 120 {
                    violations.append("\(file):\(index + 1): \(line.count) chars (max 120)")
                }
                .tag(1)
        }

        XCTAssertEqual(violations.count, 0,
                      "Lines must be ≤120 characters: \(violations)")
    }

    func testNoUnauthorizedForceUnwrapping() {
        let sourceFiles = findAllSwiftFiles()
        var violations: [String] = []

        for file in sourceFiles {
            let content = try! String(contentsOfFile: file)

            // ! マークの使用をチェック（オプショナルチェーン以外）
            let forceUnwrapMatches = content.matches(of: /[^?]!/)
            if forceUnwrapMatches.count > 0 {
                violations.append("\(file): \(forceUnwrapMatches.count) potential force unwraps")
            }
        }

        XCTAssertEqual(violations.count, 0,
                      "Minimize force unwrapping: \(violations)")
    }

    func testAsyncAwaitUsageForAsynchronousOperations() {
        let sourceFiles = findAllSwiftFiles()
        var legacyCompletionHandlers: [String] = []

        for file in sourceFiles {
            let content = try! String(contentsOfFile: file)

            // 旧式の completion handler パターンをチェック
            let completionHandlerMatches = content.matches(of: /completion:\s*@escaping/)
            if completionHandlerMatches.count > 0 {
                legacyCompletionHandlers.append("\(file): \(completionHandlerMatches.count) completion handlers")
            }
        }

        // 完全禁止ではなく、async/awaitが利用可能な場所での使用を推奨
        if legacyCompletionHandlers.count > 10 {
            XCTFail("Consider migrating completion handlers to async/await: \(legacyCompletionHandlers)")
        }
    }

    private func findAllSwiftFiles() -> [String] {
        let fileManager = FileManager.default
        let projectRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/ios/TempoAI")
        var swiftFiles: [String] = []

        if let enumerator = fileManager.enumerator(at: projectRoot, includingPropertiesForKeys: [.isRegularFileKey]) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "swift" &&
                   !fileURL.path.contains("/build/") &&
                   !fileURL.path.contains("/.build/") {
                    swiftFiles.append(fileURL.path)
                }
            }
        }

        return swiftFiles
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

### 修正対象ファイル

- `ios/TempoAI/TempoAI/Tests/Shared/UIIdentifiers.swift`
- `backend/tests/services/claude.test.ts`
- `Makefile`
- `scripts/` ディレクトリの新規スクリプト

### 新規作成テストファイル（TDD）

- `ios/TempoAI/TempoAITests/Foundation/RegressionTests.swift`
- `ios/TempoAI/TempoAITests/Quality/QualityGateTests.swift`
- `ios/TempoAI/TempoAITests/Architecture/ClaudeMdComplianceTests.swift`
- `backend/tests/foundation/regression.test.ts`
- `backend/tests/quality/quality-gate.test.ts`
- `backend/tests/architecture/claude-md-compliance.test.ts`

### 新規作成ファイル（多言語化）

- `ios/TempoAI/TempoAI/Localization/LocalizationManager.swift`
- `ios/TempoAI/TempoAI/Resources/ja.lproj/Localizable.strings`
- `ios/TempoAI/TempoAI/Resources/en.lproj/Localizable.strings`
- `backend/src/utils/localization.ts`
- `backend/src/types/localization.ts`

### ドキュメント更新

- `README.md` - 開発セットアップ手順更新 + 多言語化情報
- `.claude/swift-coding-standards.md` - 品質基準明確化 + 多言語化ガイドライン
- `.claude/typescript-hono-standards.md` - テスト戦略追加 + 国際化対応

---

## ⏱️ スケジュール

| タスク                     | 期間     | 担当 | 状態 |
| -------------------------- | -------- | ---- | ---- |
| Swift Linting 修正         | 0.5 日   | Dev  | ⏳   |
| バックエンドテスト安定化   | 1 日     | Dev  | ⏳   |
| 多言語化アーキテクチャ構築 | 2 日     | Dev  | ⏳   |
| 基本多言語リソース作成     | 1.5 日   | Dev  | ⏳   |
| テストカバレッジ強化       | 1.5 日   | Dev  | ⏳   |
| 開発ワークフロー改善       | 1.5 日   | Dev  | ⏳   |
| ドキュメント更新           | 0.5 日   | Dev  | ⏳   |
| **合計**                   | **8 日** |      |      |

---

## 🎯 Phase 1 進行のための完了条件と品質指標

### 必須完了条件（Phase 1 Ready Checklist）

#### Code Quality (P0 - 必須)

- [ ] **TypeScript Strict Mode**: `tsc --strict --noEmit` で 0 エラー
- [ ] **SwiftLint Compliance**: `swiftlint --strict` で 0 エラー・0 警告
- [ ] **No Any Types**: TypeScript コードベース内の`any`型使用 0 件
- [ ] **Explicit Type Declarations**: Swift 全プロパティの明示的型宣言 100%
- [ ] **Arrow Functions**: TypeScript 関数宣言の代わりにアロー関数 100%使用

#### Test Coverage (P0 - 必須)

- [ ] **Backend Coverage**: ≥95% (lines, branches, functions, statements)
- [ ] **iOS Coverage**: ≥90% (unit tests)
- [ ] **Test Stability**: 連続 10 回実行で失敗率 0%
- [ ] **Regression Tests**: 既存動作保証テスト 100%パス

#### Architecture Compliance (P0 - 必須)

- [ ] **SOLID Principles**: 自動検証テストで 100%準拠
- [ ] **Error Handling**: カスタムエラータイプによる例外処理
- [ ] **JSDoc Coverage**: 全 public API の 100%ドキュメント化
- [ ] **File Organization**: Swift 400 行以内、TypeScript 適切な分割

#### Internationalization Foundation (P1 - 高優先度)

- [ ] **LocalizationManager**: iOS 日英切り替え機能実装
- [ ] **Basic Resource Files**: 日英リソースファイル各 100 項目以上
- [ ] **Backend Localization**: API 多言語対応アーキテクチャ構築
- [ ] **Language Detection**: システム言語自動検出機能

### 品質メトリクス目標

#### Performance Targets

```bash
# 目標値（Phase 1 Ready基準）
make quality-check-time: ≤2分
make build-time (iOS): ≤3分
make build-time (backend): ≤1分
make test-run-time: ≤90秒
```

#### Quality Gates Dashboard

```bash
# scripts/phase-0-ready-check.sh - Phase 1進行可否判定
#!/bin/bash

## ⚡ パフォーマンス考慮

### iOS 最適化

- String Catalog の遅延読み込み
- 言語切り替え時のメモリ効率化
- UserDefaults 最小アクセス

### バックエンド最適化

if [ "$SWIFT_WARNINGS" -eq 0 ]; then
    echo "  ✅ SwiftLint Compliance: PASS"
else
    echo "  ❌ SwiftLint Compliance: FAIL ($SWIFT_WARNINGS warnings)"
    READY=false
fi

if [ "$ANY_TYPES" -eq 0 ]; then
    echo "  ✅ No Any Types: PASS"
else
    echo "  ❌ No Any Types: FAIL ($ANY_TYPES violations)"
    READY=false
fi

# Test Coverage Verification
echo "2. Test Coverage Verification:"
BACKEND_COVERAGE=$(cd backend && npx vitest run --coverage --reporter=json 2>/dev/null | jq -r '.total.lines.pct // 0')
IOS_COVERAGE=$(cd ios && swift test 2>/dev/null && echo "85" || echo "0") # Placeholder

if (( $(echo "$BACKEND_COVERAGE >= 95" | bc -l) )); then
    echo "  ✅ Backend Coverage: PASS (${BACKEND_COVERAGE}%)"
else
    echo "  ❌ Backend Coverage: FAIL (${BACKEND_COVERAGE}% < 95%)"
    READY=false
fi

if (( $(echo "$IOS_COVERAGE >= 90" | bc -l) )); then
    echo "  ✅ iOS Coverage: PASS (${IOS_COVERAGE}%)"
else
    echo "  ❌ iOS Coverage: FAIL (${IOS_COVERAGE}% < 90%)"
    READY=false
fi

# Architecture Compliance
echo "3. Architecture Compliance:"
if cd backend && pnpm run test tests/architecture/claude-md-compliance.test.ts >/dev/null 2>&1; then
    echo "  ✅ CLAUDE.md Compliance: PASS"
else
    echo "  ❌ CLAUDE.md Compliance: FAIL"
    READY=false
fi

# Internationalization Foundation
echo "4. Internationalization Foundation:"
LOCALIZATION_FILES_COUNT=$(find ios/TempoAI/TempoAI/Resources -name "*.strings" | wc -l || echo "0")
if [ "$LOCALIZATION_FILES_COUNT" -ge 2 ]; then
    echo "  ✅ Localization Files: PASS ($LOCALIZATION_FILES_COUNT files)"
else
    echo "  ❌ Localization Files: FAIL ($LOCALIZATION_FILES_COUNT < 2)"
    READY=false
fi

# Performance Check
echo "5. Performance Verification:"
START_TIME=$(date +%s)
make check >/dev/null 2>&1
END_TIME=$(date +%s)
QUALITY_CHECK_TIME=$((END_TIME - START_TIME))

if [ "$QUALITY_CHECK_TIME" -le 120 ]; then
    echo "  ✅ Quality Check Time: PASS (${QUALITY_CHECK_TIME}s ≤ 120s)"
else
    echo "  ❌ Quality Check Time: FAIL (${QUALITY_CHECK_TIME}s > 120s)"
    READY=false
fi

# Final Decision
echo ""
echo "=================================="
if [ "$READY" = true ]; then
    echo "🎉 Phase 1 READY - All quality gates passed!"
    echo ""
    echo "Next Steps:"
    echo "  1. Create git commit with Phase 0 improvements"
    echo "  2. Update team on Phase 0 completion"
    echo "  3. Begin Phase 1: MVP Core Experience"
    exit 0
else
    echo "❌ Phase 1 NOT READY - Quality gates failed"
    echo ""
    echo "Action Required:"
    echo "  1. Run 'make fix' to auto-resolve issues"
    echo "  2. Manually fix remaining violations"
    echo "  3. Re-run this check until all gates pass"
    exit 1
fi
```

### 自動化品質保証

#### Pre-Phase-1 Verification

```bash
# .github/workflows/phase-0-completion.yml
name: Phase 0 Completion Verification
on:
  push:
    branches: [ feature/phase-0-* ]
  pull_request:
    branches: [ main ]

jobs:
  phase-0-ready-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - name: Install dependencies
        run: pnpm install
      - name: Phase 0 Readiness Check
        run: ./scripts/phase-0-ready-check.sh
      - name: Performance Benchmarking
        run: ./scripts/quality-monitor.sh
```

### 完了証跡（Definition of Done）

#### 必須ドキュメント

- [ ] **Phase 0 実装完了レポート**: 修正内容・テスト結果・品質改善の詳細
- [ ] **品質メトリクス記録**: Before/After 比較データ
- [ ] **Phase 1 開始準備チェックリスト**: 次フェーズへの引き継ぎ事項
- [ ] **開発環境セットアップガイド**: 新規参加者用の完全な手順書

#### 技術負債解消証明

- [ ] **SwiftLint 違反**: 0 件（自動テストで継続検証）
- [ ] **TypeScript 警告**: 0 件（strict mode 完全対応）
- [ ] **テスト不安定性**: 解消（10 回連続成功実証）
- [ ] **手動作業**: 自動化（scripts/で全作業自動化）

この基準を満たすことで、**Phase 1 の美麗 UI 開発を安全かつ効率的に開始**できます。

---

## 🛡️ 品質保証

### 必須クライテリア

- **引き継ぎ項目**: 安定したテスト環境、品質ゲート、開発ワークフロー
- **前提条件**: Phase 0 の全成功基準クリア
- **開始時期**: Phase 0 完了確認から 1 営業日以内

---

**🔍 詳細な実装手順は、各タスク実行時に別途技術仕様書を作成します**
