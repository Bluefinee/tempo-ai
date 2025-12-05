プロジェクトドキュメントを確認しました。Phase ごとのプロンプトを、プロジェクトの実態に合わせて最適化します。

## 全体確認のプロンプト

```
guidelines/development-plans に構築した Phase 0 から Phase 5 までの開発計画書が、guidelines/tempo-ai-product-spec.md と guidelines/tempo-ai-technical-spec.md に記載されているプロダクト仕様の機能要件を過不足なく網羅しているか、また差異や矛盾がないかを徹底的に確認してください。

確認観点:
- 各フェーズで実装される機能が仕様書の要件を満たしているか
- 機能の重複や漏れがないか
- Phase 間の依存関係が適切に設計されているか
- 技術仕様で定義されたアーキテクチャに準拠しているか
- テスト戦略が各フェーズで適切に定義されているか
```

## Phase 0 (Foundation Fixes)

```
CLAUDE.md およびその関連ドキュメント（.claude/swift-coding-standards.md、.claude/typescript-hono-standards.md）、guidelines/tempo-ai-product-spec.md、guidelines/tempo-ai-technical-spec.md の内容を確認した上で、Phase 0 の基盤修正を的確に実装できるよう、guidelines/development-plans/phase-0-foundation-fixes.md の内容をさらに充実させてください。

Phase 0 の計画書には以下の要素を含めてください:
- 現状の問題点と修正すべき箇所の明確な特定
- 修正の優先順位と依存関係
- テスト駆動開発（TDD）に基づく修正方針
  - 既存コードの動作を保証するテストケース
  - リファクタリング前後の振る舞い検証
- コーディング標準（CLAUDE.md、Swift/TypeScript standards）への準拠確認
- 品質ゲート基準（型エラー 0、Lint エラー 0、カバレッジ ≥80%）
- Phase 1 に進むための完了条件
```

## Phase 1 (MVP Core Experience)

```
CLAUDE.md およびその関連ドキュメント（.claude/swift-coding-standards.md、.claude/typescript-hono-standards.md）、guidelines/tempo-ai-product-spec.md、guidelines/tempo-ai-technical-spec.md の内容を確認した上で、Phase 1 の MVP コア機能を的確に実装できるよう、guidelines/development-plans/phase-1-mvp-core-experience.md の内容をさらに充実させてください。

Phase 1 の計画書には以下の要素を含めてください:
- 実装する機能の詳細な要件定義（仕様書との紐付け）
- テスト駆動開発（TDD）による実装手順
  - Unit Test: ビジネスロジック、データモデル
  - Integration Test: API 通信、HealthKit 連携
  - UI Test: SwiftUI ビュー、ユーザーインタラクション
- 技術的な実装方針
  - SwiftUI アーキテクチャ（MVVM、ObservableObject）
  - Hono API エンドポイント設計
  - Claude API 統合パターン
- 依存関係とその優先順位（Phase 0 完了が前提）
- 想定される課題とその対応策（HealthKit 権限、非同期処理、エラーハンドリング）
- 品質ゲート基準とレビュープロセス
```

## Phase 2 (Enhanced User Experience)

```
CLAUDE.md およびその関連ドキュメント（.claude/swift-coding-standards.md、.claude/typescript-hono-standards.md）、guidelines/tempo-ai-product-spec.md、guidelines/tempo-ai-technical-spec.md の内容を確認した上で、Phase 2 のユーザー体験向上を的確に実装できるよう、guidelines/development-plans/phase-2-enhanced-user-experience.md の内容をさらに充実させてください。

Phase 2 の計画書には以下の要素を含めてください:
- 実装する機能の詳細な要件定義（クイックチェックイン、環境データ拡充）
- テスト駆動開発（TDD）による実装手順
  - Unit Test: データ統合ロジック、AI プロンプト拡張
  - Integration Test: Open-Meteo API、IQAir API 連携
  - UI Test: チェックイン UI、環境アラート表示
- 技術的な実装方針
  - 2 段階アドバイス生成のフロー設計
  - 環境データ API の統合パターン
  - パーソナライゼーションロジックの強化
- 依存関係とその優先順位（Phase 1 完了が前提）
- 想定される課題とその対応策（API レート制限、データキャッシング）
- 品質ゲート基準とパフォーマンス要件
```

## Phase 3 (Multi-Tab Navigation)

```
CLAUDE.md およびその関連ドキュメント（.claude/swift-coding-standards.md、.claude/typescript-hono-standards.md）、guidelines/tempo-ai-product-spec.md、guidelines/tempo-ai-technical-spec.md の内容を確認した上で、Phase 3 のマルチタブナビゲーションを的確に実装できるよう、guidelines/development-plans/phase-3-multi-tab-navigation.md の内容をさらに充実させてください。

Phase 3 の計画書には以下の要素を含めてください:
- 実装する機能の詳細な要件定義（履歴、トレンド、プロフィール画面）
- テスト駆動開発（TDD）による実装手順
  - Unit Test: データ永続化、トレンド分析ロジック
  - Integration Test: ローカルストレージ、データ同期
  - UI Test: タブ切り替え、画面遷移、リスト表示
- 技術的な実装方針
  - SwiftUI TabView アーキテクチャ
  - データモデルの永続化戦略（UserDefaults、将来的な DB 移行）
  - 時系列データの効率的な処理
- 依存関係とその優先順位（Phase 2 完了が前提）
- 想定される課題とその対応策（データ量増加、パフォーマンス最適化）
- 品質ゲート基準と UX 要件
```

## Phase 4 (Educational System)

```
CLAUDE.md およびその関連ドキュメント（.claude/swift-coding-standards.md、.claude/typescript-hono-standards.md）、guidelines/tempo-ai-product-spec.md、guidelines/tempo-ai-technical-spec.md の内容を確認した上で、Phase 4 の教育システムを的確に実装できるよう、guidelines/development-plans/phase-4-educational-system.md の内容をさらに充実させてください。

Phase 4 の計画書には以下の要素を含めてください:
- 実装する機能の詳細な要件定義（学ぶタブ、教育コンテンツ、段階的学習）
- テスト駆動開発（TDD）による実装手順
  - Unit Test: コンテンツ管理ロジック、パーソナライズされたデータ例生成
  - Integration Test: コンテンツ表示、リンク遷移
  - UI Test: 記事閲覧、ⓘアイコンタップ、関連記事ナビゲーション
- 技術的な実装方針
  - コンテンツ管理システム（静的 Markdown vs 動的取得）
  - 段階的学習システムの設計（レベル 1-3）
  - パーソナライズされた図解・データ例の生成
- 依存関係とその優先順位（Phase 3 完了が前提）
- 想定される課題とその対応策（コンテンツ量、多言語対応の準備）
- 品質ゲート基準と教育効果の測定方法
```

## Phase 5 (Polish & Internationalization)

```
CLAUDE.md およびその関連ドキュメント（.claude/swift-coding-standards.md、.claude/typescript-hono-standards.md）、guidelines/tempo-ai-product-spec.md、guidelines/tempo-ai-technical-spec.md の内容を確認した上で、Phase 5 の仕上げと国際化を的確に実装できるよう、guidelines/development-plans/phase-5-polish-internationalization.md の内容をさらに充実させてください。

Phase 5 の計画書には以下の要素を含めてください:
- 実装する機能の詳細な要件定義（多言語対応、文化適応、通知システム、最終調整）
- テスト駆動開発（TDD）による実装手順
  - Unit Test: ローカライゼーションロジック、文化適応ロジック
  - Integration Test: 言語切り替え、通知スケジューリング
  - UI Test: 全画面の多言語表示、通知動作、全体フロー
- 技術的な実装方針
  - SwiftUI ローカライゼーション（Localizable.strings、String Catalog）
  - バックエンド多言語対応（Claude API への言語指定）
  - 文化適応データベース（地域別食材・料理）
  - 通知システムの実装（UserNotifications、時間帯・天気対応）
- 依存関係とその優先順位（Phase 4 完了が前提）
- 想定される課題とその対応策（翻訳品質、文化的適切性、通知許可率）
- リリース前の最終品質チェックリスト
  - 全機能のエンドツーエンドテスト
  - パフォーマンステスト
  - セキュリティ監査
  - App Store 審査準備
```

---

主な変更点：

1. **「計画書には以下の要素を含めてください」の内容を Phase ごとに最適化**：

   - Phase 0: 基盤修正に特化（既存コード保証、リファクタリング）
   - Phase 1: MVP コア機能（HealthKit、API、基本 UI）
   - Phase 2: UX 向上（クイックチェックイン、環境データ）
   - Phase 3: ナビゲーション（履歴、トレンド、永続化）
   - Phase 4: 教育システム（コンテンツ管理、段階的学習）
   - Phase 5: 国際化と最終調整（多言語、文化適応、通知、リリース準備）

2. **技術的詳細を Phase に応じて具体化**：

   - SwiftUI、Hono、Claude API の統合パターン
   - データ永続化戦略
   - ローカライゼーション手法

3. **品質ゲートを Phase ごとに明確化**：
   - テストカバレッジ
   - パフォーマンス要件
   - セキュリティチェック
