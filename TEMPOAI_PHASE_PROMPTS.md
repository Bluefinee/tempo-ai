# TempoAI フェーズ別開始プロンプト

各フェーズの開始時に、該当するプロンプトをClaude Codeに貼り付けてください。

---

## Phase 1: Backend基盤

```
# TempoAI 開発 - Phase 1: Backend基盤

## プロジェクト概要
TempoAIは、サーカディアンリズムと自律神経を整えるAIパートナーアプリです。
- iOS: SwiftUI + HealthKit
- Backend: Cloudflare Workers + Hono + TypeScript
- AI: Claude Sonnet 4

## 今回のフェーズ
**Phase 1: Backend基盤**

### ゴール
1. Honoアプリケーションの基本構造を構築
2. Open-Meteo API連携（Weather + Air Quality）を実装
3. ヘルスチェック・エラーハンドリングを実装

### 参照ドキュメント（必ず読んでください）
1. CLAUDE.md - 開発規約
2. TEMPOAI_MASTER_PROMPT.md - Phase 1 セクション
3. docs/specs/technical-spec.md - Section 4（API設計）

### 既存セットアップ（インストール済み）
- Framework: hono, @hono/zod-validator, zod
- AI SDK: @anthropic-ai/sdk（Phase 4で使用）
- Test: vitest, @cloudflare/vitest-pool-workers
- Lint: @biomejs/biome
- Pre-commit: husky, lint-staged

### 利用可能なコマンド（backend/）
| コマンド | 説明 |
|---------|------|
| pnpm dev | 開発サーバー起動 |
| pnpm build | ビルド（dry-run） |
| pnpm test | テスト実行 |
| pnpm test:watch | テスト（watchモード） |
| pnpm test:coverage | カバレッジ付きテスト |
| pnpm lint | Biome lint |
| pnpm format:check | フォーマットチェック |
| pnpm check | lint + format（推奨） |
| pnpm typecheck | TypeScript型チェック |

## タスク
1. 上記ドキュメントを読んでください
2. backend/ の現在の状態を確認してください
3. feature/phase-1-backend-foundation ブランチを作成してください
4. IMPLEMENTATION_PLAN.md を作成してください
5. TDDで実装を進めてください

## 成功基準
- pnpm test 全パス
- pnpm check エラーなし
- pnpm typecheck エラーなし
- GET /health → {"status":"ok"}
- GET /api/weather?lat=35.68&lon=139.76 → 天気データ

準備ができたら、プロジェクト状態の確認結果を報告してください。
```

---

## Phase 2: iOS基盤 + HealthKit

```
# TempoAI 開発 - Phase 2: iOS基盤 + HealthKit

## プロジェクト概要
TempoAIは、サーカディアンリズムと自律神経を整えるAIパートナーアプリです。
- iOS: SwiftUI + HealthKit
- Backend: Cloudflare Workers + Hono + TypeScript
- AI: Claude Sonnet 4

## 前提条件
Phase 1（Backend基盤）が完了し、mainにマージ済みであること。

## 今回のフェーズ
**Phase 2: iOS基盤 + HealthKit**

### ゴール
1. Xcodeプロジェクト構造を整備
2. ドメインモデルを実装（Score, HealthMetrics等）
3. HealthKitリポジトリを実装
4. ローカルストレージを実装

### 参照ドキュメント（必ず読んでください）
1. CLAUDE.md - 開発規約
2. TEMPOAI_MASTER_PROMPT.md - Phase 2 セクション
3. docs/specs/technical-spec.md - Section 3（iOS設計）
4. docs/specs/metrics-spec.md - スコア定義

## タスク
1. mainブランチを最新にしてください: git checkout main && git pull
2. 上記ドキュメントを読んでください
3. ios/TempoAI/ の現在の状態を確認してください
4. feature/phase-2-ios-foundation ブランチを作成してください
5. IMPLEMENTATION_PLAN.md を作成してください
6. TDDで実装を進めてください

## 成功基準
- Xcode ⌘+U 全テストパス
- SwiftLint警告なし
- HealthKit Entitlement設定済み
- ドメインモデルが仕様通りに実装

準備ができたら、プロジェクト状態の確認結果を報告してください。
```

---

## Phase 3: スコア計算エンジン

```
# TempoAI 開発 - Phase 3: スコア計算エンジン

## プロジェクト概要
TempoAIは、サーカディアンリズムと自律神経を整えるAIパートナーアプリです。
- iOS: SwiftUI + HealthKit
- Backend: Cloudflare Workers + Hono + TypeScript
- AI: Claude Sonnet 4

## 前提条件
Phase 2（iOS基盤）が完了し、mainにマージ済みであること。

## 今回のフェーズ
**Phase 3: スコア計算エンジン**

### ゴール
1. Autonomic Score（自律神経スコア）計算
2. Sleep Score（睡眠スコア）計算
3. Rhythm Score（リズムスコア）計算
4. Activity Score（活動量スコア）計算

### 参照ドキュメント（必ず読んでください）
1. CLAUDE.md - 開発規約
2. TEMPOAI_MASTER_PROMPT.md - Phase 3 セクション
3. docs/specs/metrics-spec.md - **必読：アルゴリズム詳細**
4. docs/specs/knowledge-base.md - 科学的根拠

## タスク
1. mainブランチを最新にしてください: git checkout main && git pull
2. 上記ドキュメントを読んでください（特にmetrics-spec.mdは熟読）
3. ios/TempoAI/Domain/Services/ の状態を確認してください
4. feature/phase-3-score-engine ブランチを作成してください
5. IMPLEMENTATION_PLAN.md を作成してください
6. TDDで実装を進めてください

## 成功基準
- 全スコア計算テストパス
- metrics-spec.md のアルゴリズムと完全一致
- エッジケース（データ不足等）を適切にハンドリング

準備ができたら、プロジェクト状態の確認結果を報告してください。
```

---

## Phase 4: AI連携

```
# TempoAI 開発 - Phase 4: AI連携

## プロジェクト概要
TempoAIは、サーカディアンリズムと自律神経を整えるAIパートナーアプリです。
- iOS: SwiftUI + HealthKit
- Backend: Cloudflare Workers + Hono + TypeScript
- AI: Claude Sonnet 4

## 前提条件
Phase 3（スコア計算エンジン）が完了し、mainにマージ済みであること。

## 今回のフェーズ
**Phase 4: AI連携**

### ゴール
1. Backend: Claude API連携エンドポイント（POST /api/advice）
2. Backend: プロンプト構築ロジック（System Prompt + User Data XML）
3. iOS: AdviceAPIClient実装
4. iOS: DailyAdviceモデル実装

### 参照ドキュメント（必ず読んでください）
1. CLAUDE.md - 開発規約
2. TEMPOAI_MASTER_PROMPT.md - Phase 4 セクション
3. docs/specs/ai-prompt-spec.md - **必読：プロンプト設計**
4. docs/specs/technical-spec.md - Section 4.2（API仕様）

### 既存セットアップ（インストール済み）
- @anthropic-ai/sdk がインストール済み

### 利用可能なコマンド（backend/）
| コマンド | 説明 |
|---------|------|
| pnpm dev | 開発サーバー起動 |
| pnpm test | テスト実行 |
| pnpm check | lint + format |
| pnpm typecheck | TypeScript型チェック |

## タスク
1. mainブランチを最新にしてください: git checkout main && git pull
2. 上記ドキュメントを読んでください（特にai-prompt-spec.mdは熟読）
3. backend/src/ と ios/TempoAI/Infrastructure/API/ の状態を確認してください
4. feature/phase-4-ai-integration ブランチを作成してください
5. IMPLEMENTATION_PLAN.md を作成してください
6. TDDで実装を進めてください

## 成功基準
- POST /api/advice が正常に動作
- プロンプトが ai-prompt-spec.md 通りに構築される
- Prompt Caching が有効
- iOSからAPI呼び出しが成功
- エラー時のフォールバックが動作

## 環境変数
Backend実装時に ANTHROPIC_API_KEY が必要です：
wrangler secret put ANTHROPIC_API_KEY

準備ができたら、プロジェクト状態の確認結果を報告してください。
```

---

## Phase 5: UI実装

```
# TempoAI 開発 - Phase 5: UI実装

## プロジェクト概要
TempoAIは、サーカディアンリズムと自律神経を整えるAIパートナーアプリです。
- iOS: SwiftUI + HealthKit
- Backend: Cloudflare Workers + Hono + TypeScript
- AI: Claude Sonnet 4

## 前提条件
Phase 4（AI連携）が完了し、mainにマージ済みであること。

## 今回のフェーズ
**Phase 5: UI実装**

### ゴール
1. Onboarding画面フロー（9ステップ）
2. Home画面（AI Insight, Check-in, Scores, Clock, Environment, Quick Action）
3. Analytics画面（トレンド、リズム一貫性、インサイト）
4. Settings画面

### 参照ドキュメント（必ず読んでください）
1. CLAUDE.md - 開発規約
2. TEMPOAI_MASTER_PROMPT.md - Phase 5 セクション
3. docs/specs/product-spec.md - **必読：画面構成・ワイヤーフレーム**
4. docs/specs/ui-spec.md - **必読：カラー・フォント・インタラクション**
5. .claude/ux_concepts.md - UXデザイン原則

## タスク
1. mainブランチを最新にしてください: git checkout main && git pull
2. 上記ドキュメントを読んでください（product-spec.mdとui-spec.mdは熟読）
3. ios/TempoAI/Features/ の状態を確認してください
4. feature/phase-5-ui-implementation ブランチを作成してください
5. IMPLEMENTATION_PLAN.md を作成してください
6. 共通コンポーネント → Onboarding → Home → Analytics → Settings の順で実装

## 成功基準
- 全画面が product-spec.md のワイヤーフレーム通り
- カラー・フォントが ui-spec.md 通り
- VoiceOver対応
- Dynamic Type対応
- キャリブレーション期間中の表示対応

## 注意点
- このフェーズは最も作業量が多いです
- 必要に応じてサブフェーズ（5a, 5b, 5c）に分割してください
- 各画面ごとにコミットすることを推奨

準備ができたら、プロジェクト状態の確認結果を報告してください。
```

---

## Phase 6: 統合・最終調整

```
# TempoAI 開発 - Phase 6: 統合・最終調整

## プロジェクト概要
TempoAIは、サーカディアンリズムと自律神経を整えるAIパートナーアプリです。
- iOS: SwiftUI + HealthKit
- Backend: Cloudflare Workers + Hono + TypeScript
- AI: Claude Sonnet 4

## 前提条件
Phase 5（UI実装）が完了し、mainにマージ済みであること。

## 今回のフェーズ
**Phase 6: 統合・最終調整**

### ゴール
1. E2E動作確認（実機テスト）
2. オフラインフォールバック実装
3. バックグラウンド処理実装（Background App Refresh）
4. パフォーマンス最適化

### 参照ドキュメント（必ず読んでください）
1. CLAUDE.md - 開発規約
2. TEMPOAI_MASTER_PROMPT.md - Phase 6 セクション
3. docs/specs/technical-spec.md - Section 7, 8（バックグラウンド処理、オフライン対応）
4. docs/specs/product-spec.md - Section 4（レイテンシ対策）

## タスク
1. mainブランチを最新にしてください: git checkout main && git pull
2. 上記ドキュメントを読んでください
3. feature/phase-6-integration ブランチを作成してください
4. IMPLEMENTATION_PLAN.md を作成してください
5. 以下の順で実装・確認を進めてください：
   - E2E統合テスト
   - オフラインフォールバック
   - バックグラウンド処理
   - パフォーマンス最適化

## 成功基準
- 実機で全機能動作
- オフライン時にローカルアドバイス表示
- 起床時にキャッシュ済みInsight表示
- クラッシュなし
- 起動時間 < 2秒

## 実機テストチェックリスト
- [ ] HealthKit認証フロー
- [ ] 位置情報認証フロー
- [ ] AI Insight取得・表示
- [ ] スコア計算・表示
- [ ] オフライン時の動作
- [ ] バックグラウンドからの復帰

準備ができたら、プロジェクト状態の確認結果を報告してください。
```

---

## 🔄 フェーズ完了時のプロンプト（共通）

各フェーズの最後に使用：

```
Phase [N] の完了処理を行います。

1. 全テストがパスしていることを確認してください
2. Lint/Formatエラーがないことを確認してください
3. IMPLEMENTATION_PLAN.md の完了チェックリストを更新してください
4. 全ての変更をコミットしてください
5. ブランチをプッシュしてください: git push origin feature/phase-[N]-[name]
6. PRの本文として使えるサマリーを出力してください

PRサマリーには以下を含めてください：
- 実装した機能の概要
- 追加/変更したファイル一覧
- テストカバレッジ
- 次のフェーズへの引き継ぎ事項（あれば）
```

---

## 💡 使い方まとめ

| タイミング | 使用するプロンプト |
|-----------|------------------|
| Phase 1 開始 | Phase 1 プロンプト |
| Phase 1 完了 | フェーズ完了プロンプト |
| Phase 2 開始 | Phase 2 プロンプト |
| ... | ... |
| Phase 6 完了 | フェーズ完了プロンプト |

**ポイント**: 
- 各フェーズの最初に必ず `git checkout main && git pull` を実行させる
- 仕様書を毎回読ませることで、コンテキストを維持
- IMPLEMENTATION_PLAN.md を作成させることで、進捗管理が可能
