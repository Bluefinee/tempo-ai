# 📋 Phase 0: 詳細実装計画書

**プロジェクト**: TempoAI  
**フェーズ**: Phase 0 - 基盤修正 + 多言語化基盤構築  
**作成日**: 2025年12月5日  
**実装担当**: Claude Code Agent  
**参照ドキュメント**: `guidelines/development-plans/phase-0-foundation-fixes.md`

---

## 🎯 実装目標

### 主要目的
1. **品質基盤の安定化**: リンティングエラー修正、テスト安定性向上
2. **多言語化アーキテクチャ構築**: 日英完全対応のi18n基盤実装
3. **開発効率向上**: 自動化スクリプトとワークフロー整備

### 成功指標
- [ ] SwiftLint エラー 0件
- [ ] Claude API テスト安定性 95%以上
- [ ] 多言語UI文字列 50項目以上実装
- [ ] LocalizationManager完全実装
- [ ] 開発自動化スクリプト完備

---

## 🔄 Git ワークフロー

### ブランチ戦略
```bash
# 1. mainブランチを最新化
git checkout main
git pull origin main

# 2. feature ブランチ作成
git checkout -b feature/phase-0-foundation-fixes

# 3. 実装完了後
git add .
git commit -m "feat: implement Phase 0 foundation fixes and i18n infrastructure

🚀 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## 📋 Stage 1: 基盤品質安定化

### 1.1 リンティングエラー修正

**対象ファイル**: `ios/TempoAI/TempoAI/Tests/Shared/UIIdentifiers.swift`

**問題**: 末尾改行不足によるSwiftLintエラー

**修正方法**:
```bash
# UIIdentifiers.swiftの末尾に改行を追加
echo "" >> ios/TempoAI/TempoAI/Tests/Shared/UIIdentifiers.swift
```

**検証**:
```bash
cd ios && swiftlint lint --strict
```

**期待結果**: SwiftLintエラー 0件

### 1.2 Claude API統合テスト安定化

**対象ファイル**: `backend/src/services/claude.ts`

**実装内容**:
1. **指数バックオフリトライロジック**
2. **エラー分類システム** (retryable vs non-retryable)
3. **タイムアウト処理強化** (15秒デフォルト)
4. **詳細ログ出力**

**新機能**:
```typescript
// generateAdviceWithRetry関数
// isRetryableError関数  
// calculateExponentialBackoff関数
// callClaudeAPIWithTimeout関数
```

**テスト目標**: 成功率 95%以上

### 1.3 品質ゲート検証

**実行スクリプト**: `scripts/quality-check-all.sh`

**チェック項目**:
- [ ] iOS SwiftLint strict mode
- [ ] iOS Unit Tests
- [ ] Backend TypeScript type check
- [ ] Backend Unit Tests  
- [ ] Backend Lint check

---

## 📋 Stage 2: 国際化基盤構築

### 2.1 iOS LocalizationManager実装

**新規ファイル**: `ios/TempoAI/TempoAI/Shared/Localization/LocalizationManager.swift`

**アーキテクチャ**:
```swift
@MainActor
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: SupportedLanguage
    
    enum SupportedLanguage: String, CaseIterable {
        case japanese = "ja"
        case english = "en"
    }
    
    func setLanguage(_ language: SupportedLanguage)
}
```

**機能**:
- [x] SwiftUI ObservableObject パターン
- [x] UserDefaults 永続化
- [x] 言語切り替えAPI
- [x] デフォルト日本語設定

### 2.2 String拡張実装

**新規ファイル**: `ios/TempoAI/TempoAI/Shared/Localization/String+Localization.swift`

```swift
extension String {
    var localized: String {
        // LocalizationManagerと連携
        // Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
    }
}
```

### 2.3 多言語リソース作成

**日本語リソース**: `ios/TempoAI/TempoAI/ja.lproj/Localizable.strings`

**英語リソース**: `ios/TempoAI/TempoAI/en.lproj/Localizable.strings`

**文字列カテゴリ** (合計50+項目):
1. **タブナビゲーション** (4項目)
2. **共通アクション** (10項目)  
3. **エラーメッセージ** (15項目)
4. **HealthKit権限** (10項目)
5. **一般UI要素** (15項目)

### 2.4 バックエンド多言語対応

**新規ファイル**: `backend/src/utils/localization.ts`

**実装内容**:
```typescript
interface LocalizedContent {
  ja: string;
  en: string;
}

export const getLocalizedMessage = (
  content: LocalizedContent,
  language: "ja" | "en" = "ja"
): string => {
  return content[language] || content.en;
};
```

**エラーメッセージ定数**:
```typescript
const errorMessages = {
  networkError: {
    ja: "ネットワークエラーが発生しました",
    en: "A network error occurred"
  },
  // 追加のエラーメッセージ...
}
```

---

## 📋 Stage 3: 開発効率化

### 3.1 開発コマンド自動化

**新規ファイル**: `scripts/dev-commands.sh`

**サポートコマンド**:
```bash
./scripts/dev-commands.sh test-all      # 全テスト実行
./scripts/dev-commands.sh build-ios     # iOS ビルド
./scripts/dev-commands.sh dev-backend   # バックエンド開発サーバー
./scripts/dev-commands.sh lint-fix      # リント自動修正
```

**実装詳細**:
- case文による分岐処理
- 既存スクリプトとの連携
- エラーハンドリング
- 使用方法ヘルプ表示

### 3.2 CLAUDE.md更新

**追加セクション**:
```markdown
# Phase 0 推奨コマンド

## 品質チェック
./scripts/quality-check-all.sh
./scripts/dev-commands.sh test-all

## 開発サーバー  
./scripts/dev-commands.sh dev-backend
./scripts/dev-commands.sh build-ios

## リント修正
./scripts/dev-commands.sh lint-fix
```

---

## 🧪 テスト戦略

### TDD実装フロー
1. **Red**: 失敗するテスト作成
2. **Green**: 最小限実装でテスト通過
3. **Refactor**: コード品質向上
4. **Verify**: 品質ゲート通過確認

### テスト対象

#### Unit Tests
- [ ] LocalizationManager.setLanguage()
- [ ] LocalizationManager.currentLanguage永続化
- [ ] String.localized 動作検証
- [ ] getLocalizedMessage() 関数

#### Integration Tests  
- [ ] 言語切り替えUI反映
- [ ] バックエンドAPIレスポンス多言語化
- [ ] Claude APIリトライロジック

#### UI Tests
- [ ] 日本語UIナビゲーション
- [ ] 英語UIナビゲーション  
- [ ] 言語切り替えフロー

#### Regression Tests
- [ ] 既存機能保護
- [ ] パフォーマンス維持

---

## 📊 進捗追跡

### Stage 1 進捗
- [ ] UIIdentifiers.swift修正
- [ ] Claude APIリトライ実装
- [ ] SwiftLint strict mode通過
- [ ] 品質ゲート全通過

### Stage 2 進捗  
- [ ] LocalizationManager実装
- [ ] String拡張実装
- [ ] 日本語リソース作成 (25+項目)
- [ ] 英語リソース作成 (25+項目)  
- [ ] バックエンドlocalization.ts実装

### Stage 3 進捗
- [ ] dev-commands.sh実装
- [ ] CLAUDE.md更新
- [ ] スクリプト動作検証

### 最終検証
- [ ] 全ユニットテスト通過
- [ ] UIテスト通過 (日英両言語)
- [ ] パフォーマンス基準クリア
- [ ] ドキュメント更新完了

---

## ⚠️ 課題と解決策

### 予想される課題

#### 1. Xcode プロジェクト設定
**課題**: 新しい.lprojフォルダの追加時にXcodeプロジェクト設定が必要
**解決策**: 手動でXcodeプロジェクトにlocalizationリソースを追加

#### 2. バンドル読み込み
**課題**: String拡張でのBundle読み込み失敗の可能性
**解決策**: フォールバック機構をNSLocalizedStringで実装

#### 3. テストエラー
**課題**: Claude APIテスト環境依存の不安定性
**解決策**: モックサービス併用とリトライ機構強化

### 対応方針
- 各課題に対して2つ以上の解決アプローチを準備
- テスト失敗時の詳細ログ出力
- 段階的実装によるリスク軽減

---

## 📚 参考資料

### 技術ドキュメント
- [Swift Coding Standards](.claude/swift-coding-standards.md)
- [TypeScript Hono Standards](.claude/typescript-hono-standards.md)  
- [CLAUDE.md](../../CLAUDE.md)

### Apple 公式ドキュメント
- Apple Internationalization and Localization Guide
- NSLocalizedString Reference
- SwiftUI Localization Best Practices

---

## ✅ Definition of Done

### 品質要件
1. **コード品質**
   - [ ] SwiftLint警告 0件
   - [ ] TypeScriptエラー 0件
   - [ ] 全ユニットテスト通過

2. **機能要件**  
   - [ ] 日英言語切り替え動作
   - [ ] UI文字列完全ローカライズ
   - [ ] 言語設定永続化

3. **パフォーマンス要件**
   - [ ] アプリ起動時間 < 3秒
   - [ ] 言語切り替え < 1秒  
   - [ ] メモリ使用量 < 150MB

4. **ドキュメント要件**
   - [ ] 実装ドキュメント更新
   - [ ] 使用方法文書化
   - [ ] 次フェーズ引き継ぎ準備

---

## 🚀 次フェーズ準備

### Phase 1への引き継ぎ
- 多言語化アーキテクチャの活用方針
- 品質ゲート維持のためのCI/CD設定  
- パフォーマンス最適化の継続点
- ユーザーフィードバック収集準備

---

**実装開始日**: 2025年12月5日  
**予定完了日**: 2025年12月19日 (2週間)  
**次回レビュー**: Stage 1完了時