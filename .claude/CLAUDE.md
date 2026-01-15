# TempoAI - Claude Code Project Context

**「自分のテンポを知り、テンポに乗る」**

TempoAI は、サーカディアンリズム（体内時計）と自律神経の状態を可視化し、AI が毎朝パーソナライズされたアドバイスを提供するヘルスケアアプリです。

---

## 技術スタック

### モバイルアプリ (`/app`)

| カテゴリ | 技術 |
|---------|------|
| フレームワーク | React Native (Expo SDK 54) |
| 言語 | TypeScript 5.x |
| ルーティング | expo-router 6.x |
| 状態管理 | Zustand 5.x |
| スタイリング | NativeWind (Tailwind CSS) |
| バリデーション | Zod |
| 国際化 | i18n-js + expo-localization |

### バックエンド (`/backend`)

| カテゴリ | 技術 |
|---------|------|
| ホスティング | Cloudflare Workers |
| フレームワーク | Hono 4.x |
| 言語 | TypeScript 5.x |
| リンター/フォーマッター | Biome |
| テスト | Vitest |
| AI | Anthropic Claude API |

### 外部サービス

| サービス | 用途 |
|---------|------|
| Anthropic Claude API | AI アドバイス生成 |
| Open-Meteo | 天気情報取得（無料） |
| Apple HealthKit | ヘルスデータ取得 |

---

## ディレクトリ構成

```
tempo-ai/
├── .claude/                    # Claude Code 設定・規約
│   ├── CLAUDE.md              # このファイル（プロジェクトコンテキスト）
│   ├── commands/              # スラッシュコマンド
│   ├── memory/                # 技術的意思決定・コンテキスト記録
│   ├── react-native-standards.md
│   ├── typescript-hono-standards.md
│   └── ux-concepts.md
├── app/                        # React Native (Expo) アプリ
│   ├── app/                   # expo-router ページ
│   │   ├── (onboarding)/      # オンボーディングフロー
│   │   ├── (main)/            # メインタブ画面
│   │   └── _layout.tsx        # ルートレイアウト
│   └── src/
│       ├── components/        # 再利用可能 UI コンポーネント
│       ├── domain/            # ドメインモデル・ビジネスロジック
│       │   ├── models/        # 型定義
│       │   └── services/      # スコア計算・リズム分析
│       ├── stores/            # Zustand ストア
│       ├── api/               # API クライアント
│       ├── hooks/             # カスタムフック
│       ├── constants/         # 定数・モックデータ
│       └── i18n/              # 多言語リソース
├── backend/                    # Cloudflare Workers API
│   └── src/
│       ├── routes/            # Hono ルート定義
│       ├── services/          # ビジネスロジック
│       └── types/             # 型定義
└── docs/
    └── specs/                 # 仕様書（必読）
```

---

## 仕様書（必読）

実装前に必ず参照してください：

| ドキュメント | パス | 内容 |
|-------------|------|------|
| プロダクト仕様 | `docs/specs/tempoai_product_spec.md` | 画面構成・機能要件 |
| 技術仕様 | `docs/specs/tempoai_technical_spec.md` | システム構成・API設計 |
| メトリクス仕様 | `docs/specs/tempoai_metrics_spec.md` | スコア算出アルゴリズム |
| AI プロンプト仕様 | `docs/specs/tempoai_ai_prompt_spec.md` | プロンプト設計・トークン管理 |
| UI/UX 設計 | `docs/specs/tempoai_ui_spec.md` | デザインシステム |
| UX コンセプト | `docs/specs/tempoai_ux_concepts.md` | デザイン原則 |
| ナレッジベース | `docs/specs/tempoai_knowledge_base.md` | 科学的根拠 |
| i18n 設計 | `docs/specs/tempoai_i18n_spec.md` | 多言語対応 |

---

## コーディング規約

### 詳細規約ドキュメント

- `.claude/react-native-standards.md` - React Native/Expo 開発規約
- `.claude/typescript-hono-standards.md` - バックエンド開発規約
- `.claude/ux-concepts.md` - UX デザイン原則

### 必須ルール

#### TypeScript

```typescript
// ✅ Good - Arrow function with explicit return type
export const calculateSleepScore = (sleep: SleepMetrics): Score => {
  // ...
};

// ❌ Bad - function declaration, implicit return, any type
function calculateSleepScore(sleep: any) {
  // ...
}
```

- **NEVER use `any`** → `unknown` を使用
- **Arrow functions** → function 宣言は禁止
- **Explicit return types** → 戻り値型を明示
- **Strict mode** → tsconfig.json で有効

#### React Native

```typescript
// ✅ Good - FC with typed props, StyleSheet
interface ScoreCardProps {
  score: Score;
  onPress?: () => void;
}

export const ScoreCard: React.FC<ScoreCardProps> = ({ score, onPress }) => {
  return (
    <View style={styles.container}>
      <Text style={styles.value}>{score.value}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { padding: Spacing.md },
  value: { ...Typography.heading2 },
});
```

#### Zustand セレクター

```typescript
// ✅ Good - 必要なプロパティのみ選択
const sleepScore = useHealthStore((state) => state.sleepScore);

// ❌ Bad - ストア全体を選択（不要な再レンダリング）
const store = useHealthStore();
```

---

## よく使うコマンド

### アプリ開発

```bash
cd app
npm start              # Expo 開発サーバー起動
npm run ios            # iOS シミュレーター起動
npm run typecheck      # TypeScript 型チェック
npm run lint           # ESLint 実行
npm test               # Jest テスト実行
```

### バックエンド開発

```bash
cd backend
pnpm dev               # ローカル開発サーバー (wrangler)
pnpm typecheck         # TypeScript 型チェック
pnpm check             # Biome lint + format チェック
pnpm check:fix         # Biome 自動修正
pnpm test              # Vitest テスト実行
pnpm deploy            # Cloudflare Workers デプロイ
```

### 全体

```bash
# リント・型チェック（両方）
cd app && npm run typecheck && npm run lint
cd backend && pnpm typecheck && pnpm check
```

---

## アーキテクチャ原則

### ドメイン駆動設計

```
Presentation (app/) → Application (stores/) → Domain (domain/) → Infrastructure (api/)
                                                    ↓
                                            ビジネスロジック集約
                                            （スコア計算、リズム分析）
```

### 設計方針

| 原則 | 説明 |
|------|------|
| データベースレス | ヘルスデータはデバイス内のみ。サーバーに DB なし |
| プライバシーファースト | 個人データはサーバーに保存しない |
| オフラインファースト | 基本機能はオフラインでも動作 |
| ローカル優先計算 | スコア・Baseline 計算はローカルで実行 |

---

## 4 つのコアスコア

| スコア | 説明 | 算出根拠 |
|--------|------|---------|
| **Recovery** | 身体の回復度 (0-100%) | HRV + RHR + 睡眠の質 |
| **Sleep** | 睡眠パフォーマンス (0-100%) | Duration + Quality + Timing |
| **Rhythm** | リズムの安定性 (0-100%) | 就寝/起床時刻の一貫性 |
| **Energy** | 今日のエネルギー予測 (0-100%) | Recovery + Sleep + 天気 |

詳細は `docs/specs/tempoai_metrics_spec.md` を参照。

---

## 重要な設計判断

### AI アドバイス生成

- **1日1回のみ生成**（Calm Technology）
- **Claude API 使用**（system prompt キャッシュ有効）
- **トークン予算**: ~5,000/request → ~$0.03/request
- プロンプト詳細: `docs/specs/tempoai_ai_prompt_spec.md`

### データソース切り替え

```typescript
// app/src/config/dataSource.ts
export const DATA_SOURCE: DataSourceType = 'mock'; // 'mock' | 'healthkit'
```

開発中は `mock`、実機テストでは `healthkit` に切り替え。

---

## 禁止事項

- `any` 型の使用（`unknown` を使う）
- function 宣言（arrow function を使う）
- `--no-verify` でのコミット
- コメントアウトされたコードの放置
- テストをスキップして修正
- 3 回試行しても解決しない問題への固執（STOP して再評価）

---

## コミット規約

```bash
# 形式
<type>: <description>

# type
feat:     新機能
fix:      バグ修正
refactor: リファクタリング
docs:     ドキュメント
test:     テスト
chore:    ビルド・設定変更
```

---

## 問題解決フロー

1. **3回試行ルール**: 同じ問題に3回失敗したら STOP
2. 仕様書を再確認
3. 既存コードのパターンを調査
4. アプローチを変更して再試行
