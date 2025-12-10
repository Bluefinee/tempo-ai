# Tempo AI 開発フェーズ管理書

**バージョン**: 1.0  
**作成日**: 2025年12月10日

---

## 概要

本ドキュメントは、Tempo AI の開発を14のフェーズに分割し、各フェーズの目的・成果物・依存関係を管理するものです。

---

## ⚠️ 重要：全フェーズ共通の要件

### 📋 実装前の必須確認事項

**各フェーズの実装を開始する前に、必ず以下のドキュメントを確認してください：**

**全フェーズ共通**:
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI設計指針
- **[UI Specification](../ui-spec.md)** - UI設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書

**Swift/iOS フェーズ (1-6, 10-14)**:
- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX設計原則
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準

**Backend フェーズ (7-9, 10-14)**:
- **[TypeScript Hono Standards](../../.claude/typescript-hono-standards.md)** - TypeScript + Hono 開発標準

### ✅ 実装完了後の必須作業

**各フェーズの実装完了後は、必ず以下の品質チェックを実行してください：**

**Swift/iOS側** (該当フェーズ):
```bash
# リント・フォーマット確認
swiftlint
swift-format --lint --recursive ios/

# テスト実行
swift test
```

**Backend側** (該当フェーズ):
```bash
# TypeScript型チェック
npm run typecheck

# リント・フォーマット確認
npm run lint

# テスト実行
npm test
```

これらのチェックがすべて通ることをCI通過の前提条件とします。

---

## 全体構成

| Part | フェーズ | 概要 |
|------|---------|------|
| **A: iOS UI** | Phase 1〜6 | Mockデータを使用したUI実装 |
| **B: Backend** | Phase 7〜9 | API・外部サービス統合 |
| **C: 結合** | Phase 10〜12 | UI と API の接続、状態管理 |
| **D: 仕上げ** | Phase 13〜14 | エラー処理、ポリッシュ |

---

## 並行開発について

Part A（iOS UI）と Part B（Backend）は並行開発が可能です。

```
Part A (iOS)          Part B (Backend)
    │                      │
Phase 1 ──────────────── Phase 7
    │                      │
Phase 2 ──────────────── Phase 8
    │                      │
Phase 3 ──────────────── Phase 9
    │                      │
Phase 4                    │
    │                      │
Phase 5                    │
    │                      │
Phase 6                    │
    └──────────┬───────────┘
               │
         Part C (結合)
         Phase 10〜12
               │
         Part D (仕上げ)
         Phase 13〜14
```

Git Worktreeを使用して、iOS と Backend を同時に進めることを想定しています。

---

## Part A: iOS UI（Mockデータ使用）

### Phase 1: オンボーディング

**目的**: ユーザーの初回起動体験を完成させる

**スコープ**:
- オンボーディング全7画面
- HealthKitManager（権限リクエスト + データ取得）
- LocationManager（権限リクエスト + 位置取得）
- UserDefaultsへのプロフィール保存
- テストデータ生成（DEBUG用）

**成果物**:
- オンボーディングフロー完動
- シミュレータでHealthKitテストデータを使った動作確認が可能

**設計書**: `01-phase-onboarding.md`

---

### Phase 2: ホーム画面UI（基本構造）

**目的**: メイン画面の骨格を作る

**スコープ**:
- ヘッダー（日付、挨拶）
- アドバイスサマリーカード
- タブバー（ホーム / 設定）

**成果物**:
- Mockデータでホーム画面が表示される
- タブ切り替えが動作する

**設計書**: `02-phase-home-basic.md`

---

### Phase 3: ホーム画面UI（メトリクス・トライ）

**目的**: ホーム画面の全要素を揃える

**スコープ**:
- メトリクスカード4つ（回復・睡眠・エネルギー・ストレス）
- 今日のトライカード
- 今週のトライカード
- 追加アドバイス（フローティング吹き出し）

**成果物**:
- ホーム画面の全UIコンポーネントが揃う
- 月曜日の今週のトライ表示切り替え

**設計書**: `03-phase-home-metrics.md`

---

### Phase 4: 詳細画面UI

**目的**: アドバイス・トライの詳細表示

**スコープ**:
- アドバイス詳細画面
- 今日のトライ詳細画面
- 今週のトライ詳細画面
- 画面遷移アニメーション

**成果物**:
- ホーム画面からタップで詳細画面へ遷移
- 詳細画面から戻る動作

**設計書**: `04-phase-detail-screens.md`

---

### Phase 5: メトリクス詳細画面UI

**目的**: 各指標の詳細表示

**スコープ**:
- 回復詳細画面
- 睡眠詳細画面
- エネルギー詳細画面
- ストレス詳細画面

**成果物**:
- メトリクスカードから詳細画面へ遷移

**設計書**: `05-phase-metrics-detail.md`

---

### Phase 6: 設定画面UI

**目的**: ユーザー設定の編集機能

**スコープ**:
- 設定トップ画面
- プロフィール編集画面
- 関心ごとタグ編集画面
- データとプライバシー画面
- アプリについて画面

**成果物**:
- 設定からプロフィール・タグを編集可能
- UserDefaultsへの保存

**設計書**: `06-phase-settings.md`

---

## Part B: バックエンド

### Phase 7: Backend基盤

**目的**: APIの骨格を作り、iOS との疎通を確認する

**スコープ**:
- Hono Router セットアップ
- `/api/advice` エンドポイント（固定JSON）
- 型定義（リクエスト・レスポンス）
- iOS APIClient実装・疎通確認

**成果物**:
- iOS から Backend へリクエストが通る
- 固定JSONが返却される

**設計書**: `07-phase-backend-foundation.md`

---

### Phase 8: 外部API統合

**目的**: 気象・大気汚染データの取得

**スコープ**:
- Open-Meteo Weather API 統合
- Open-Meteo Air Quality API 統合
- フォールバック処理

**成果物**:
- 位置情報から気象データを取得
- API失敗時のフォールバック動作

**設計書**: `08-phase-external-api.md`

---

### Phase 9: Claude API統合

**目的**: AIによるアドバイス生成

**スコープ**:
- プロンプト構造（Layer 1〜3）
- Claude Sonnet 呼び出し（メインアドバイス）
- Claude Haiku 呼び出し（追加アドバイス）
- Prompt Caching設定
- JSONパース

**成果物**:
- 実際のパーソナライズドアドバイスが生成される

**設計書**: `09-phase-claude-api.md`

---

## Part C: 結合・調整

### Phase 10: UI結合・調整

**目的**: Mock を実APIに置き換え、UIを調整する

**スコープ**:
- Mockデータ削除
- 実APIレスポンスとの接続
- レイアウト調整（文長変動への対応）
- データバインディング確認

**成果物**:
- 全画面が実APIデータで動作する
- 文長の変動に対応したUI

**設計書**: `10-phase-integration.md`

---

### Phase 11: キャッシュ・状態管理

**目的**: キャッシュとオフライン対応

**スコープ**:
- CacheManager実装
- 時間帯判定ロジック（朝・昼・夕）
- 同日キャッシュ
- オフラインフォールバック

**成果物**:
- 同日2回目の起動でキャッシュが使われる
- オフライン時に前日のアドバイスが表示される

**設計書**: `11-phase-cache.md`

---

### Phase 12: 追加機能結合

**目的**: 追加アドバイス・トライ履歴の完成

**スコープ**:
- 追加アドバイス生成・表示（昼・夕）
- 今日のトライ履歴管理（重複防止）
- 今週のトライ（月曜判定）

**成果物**:
- 13時以降、18時以降に追加アドバイスが表示
- 過去2週間と被らないトライが提案される

**設計書**: `12-phase-additional-features.md`

---

## Part D: 仕上げ

### Phase 13: エラーハンドリング

**目的**: エッジケースへの対応

**スコープ**:
- エラー画面UI（オフライン、データ不足、位置情報失敗）
- 都市手動選択ダイアログ
- エラー状態の伝播

**成果物**:
- 各種エラー時に適切な画面が表示される
- ユーザーが次のアクションを取れる

**設計書**: `13-phase-error-handling.md`

---

### Phase 14: ポリッシュ

**目的**: UXの仕上げ

**スコープ**:
- ローディング表示（0.4秒ルール）
- アニメーション・マイクロインタラクション
- 最終調整

**成果物**:
- MVP品質のアプリ完成

**設計書**: `14-phase-polish.md`

---

## 依存関係

```
Phase 1  ← 独立
Phase 2  ← Phase 1（オンボーディング完了後にホームへ遷移）
Phase 3  ← Phase 2
Phase 4  ← Phase 2, 3
Phase 5  ← Phase 3
Phase 6  ← Phase 2（タブバーから設定へ遷移）

Phase 7  ← 独立
Phase 8  ← Phase 7
Phase 9  ← Phase 7, 8

Phase 10 ← Phase 1〜6, Phase 7〜9（全て完了後）
Phase 11 ← Phase 10
Phase 12 ← Phase 10, 11

Phase 13 ← Phase 10
Phase 14 ← Phase 10〜13
```

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| `product-spec.md` | プロダクト仕様書 |
| `technical-spec.md` | 技術仕様書 |
| `ui-spec.md` | UI/UX仕様書 |
| `ai-prompt-design.md` | AIプロンプト設計書 |

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
