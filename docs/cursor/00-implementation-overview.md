# TempoAI UI Migration - Implementation Overview

**目的**: Cursor AI による機械的な実装のための設計ガイド

---

## 必須参照ドキュメント

実装前に必ず確認すること:

| ドキュメント | パス | 用途 |
|-------------|------|------|
| CLAUDE.md | `/CLAUDE.md` | 全体コーディング規約 |
| React Native規約 | `/.claude/react-native-standards.md` | フロントエンド規約 |
| TypeScript+Hono規約 | `/.claude/typescript-hono-standards.md` | バックエンド規約 |
| 製品仕様 | `/docs/specs/product_spec.md` | 機能要件 |
| 技術仕様 | `/docs/specs/technical_spec.md` | API設計 |
| UI/UX仕様 | `/docs/specs/ui_ux_design.md` | デザイン詳細 |
| メトリクス仕様 | `/docs/specs/metrics_spec.md` | スコア算出ロジック |
| AIプロンプト仕様 | `/docs/specs/ai_prompt_spec.md` | AI出力形式 |
| i18n設計 | `/docs/specs/i18n_design.md` | 多言語対応 |
| 新UIプロトタイプ | `/sozai/new/` | 実装リファレンス |

---

## 実装順序

```
Phase 1: 基盤整備
    ↓
Phase 2: ドメインモデル・サービス
    ↓
Phase 3: 共通コンポーネント
    ↓
Phase 4: Store更新
    ↓
Phase 5: ナビゲーション
    ↓
Phase 6: 画面実装
    ↓
Phase 7: バックエンド更新
    ↓
Phase 8: API連携
    ↓
Phase 9: テスト・品質保証
```

---

## 変更対象外（絶対に触らない）

1. **オンボーディングフロー** - `app/app/(onboarding)/` 配下は一切変更しない
2. **インフラ設定** - `wrangler.toml`, `app.json` の基本設定
3. **パッケージ構成** - `package.json` の既存依存関係

---

## コーディングルール（厳守）

### TypeScript

```typescript
// ❌ 禁止: any 型
const data: any = response;

// ✅ 必須: 明示的な型
const data: AdviceResponse = response;

// ❌ 禁止: function 宣言
function calculateScore() {}

// ✅ 必須: Arrow Function
export const calculateScore = (): number => {};

// ❌ 禁止: 型推論に頼る
const getScore = (metrics) => metrics.score;

// ✅ 必須: 明示的な引数型と戻り値型
export const getScore = (metrics: HealthMetrics): number => metrics.score;
```

### React Native コンポーネント

```typescript
// ✅ 必須パターン
interface ComponentProps {
  value: number;
  onPress?: () => void;
}

export const Component: React.FC<ComponentProps> = ({ value, onPress }) => {
  return (
    <View style={styles.container}>
      <Text>{value}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    // テーマトークンを使用
    padding: Spacing.md,
    backgroundColor: Colors.stone[50],
  },
});
```

### i18n（文字列の外部化）

```typescript
// ❌ 禁止: ハードコード文字列
<Text>おはようございます</Text>

// ✅ 必須: 翻訳キー経由
import { t } from '@/i18n';
<Text>{t('screen.today.greeting.morning')}</Text>
```

### デザイントークン

```typescript
// ❌ 禁止: ハードコード値
backgroundColor: '#6366F1',
padding: 16,

// ✅ 必須: テーマ参照
import { Colors, Spacing } from '@/theme';
backgroundColor: Colors.indigo[500],
padding: Spacing.md,
```

---

## ファイル命名規則

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| コンポーネント | PascalCase | `WaveScore.tsx` |
| ページ（expo-router） | kebab-case | `rhythm.tsx` |
| フック | camelCase (use prefix) | `useBreathing.ts` |
| ストア | camelCase (Store suffix) | `breatheStore.ts` |
| サービス | camelCase | `tempoScoreCalculator.ts` |
| 型定義 | camelCase | `rhythm.ts` |

---

## インポートルール

```typescript
// ✅ 必須: エイリアスパス
import { Colors } from '@/theme';
import { useUserStore } from '@/stores';
import { Score } from '@/domain/models';

// ❌ 禁止: 相対パス（3階層以上）
import { Colors } from '../../../theme/colors';
```

---

## 各Phaseの詳細設計書

| Phase | 設計書 |
|-------|--------|
| 1 | `01-phase1-foundation.md` |
| 2 | `02-phase2-domain.md` |
| 3 | `03-phase3-components.md` |
| 4 | `04-phase4-stores.md` |
| 5 | `05-phase5-navigation.md` |
| 6 | `06-phase6-screens.md` |
| 7 | `07-phase7-backend.md` |
| 8 | `08-phase8-api-integration.md` |
| 9 | `09-phase9-testing.md` |

---

## 完了チェックリスト（各タスク完了時）

- [ ] TypeScript strict mode でエラーなし
- [ ] `any` 型を使用していない
- [ ] すべての関数に明示的な戻り値型がある
- [ ] Arrow Function を使用している
- [ ] 文字列がi18nキー経由で表示される
- [ ] デザイントークンを使用している
- [ ] テストが存在し、パスしている
- [ ] `pnpm lint` でエラーなし
- [ ] `pnpm typecheck` でエラーなし
