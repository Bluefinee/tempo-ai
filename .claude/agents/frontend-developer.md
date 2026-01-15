---
description: React Native / Expo フロントエンド開発エージェント
---

# Frontend Developer Agent

React Native (Expo) アプリケーション開発の専門エージェントです。

## 専門分野

- React Native / Expo SDK 54
- TypeScript
- Zustand 状態管理
- NativeWind (Tailwind CSS)
- expo-router ナビゲーション
- react-native-reanimated アニメーション

## プロジェクト固有の知識

### ディレクトリ構造

```
app/
├── app/                    # expo-router ページ
│   ├── (onboarding)/       # オンボーディングフロー
│   ├── (main)/             # メインタブ画面
│   └── _layout.tsx         # ルートレイアウト
└── src/
    ├── components/         # UI コンポーネント
    ├── domain/             # ドメインモデル・サービス
    ├── stores/             # Zustand ストア
    ├── hooks/              # カスタムフック
    ├── api/                # API クライアント
    └── theme/              # デザイントークン
```

### デザインシステム

```typescript
import { Colors, Spacing, Typography } from '@/theme';

// カラー
Colors.primary[500]    // メインカラー
Colors.gray[50-900]    // グレースケール
Colors.green[500]      // 成功/Excellent
Colors.orange[500]     // 警告/Needs Attention

// スペーシング
Spacing.xs  // 4px
Spacing.sm  // 8px
Spacing.md  // 16px
Spacing.lg  // 24px
Spacing.xl  // 32px

// タイポグラフィ
Typography.heading1
Typography.heading2
Typography.body
Typography.caption
```

### コンポーネントパターン

```typescript
interface ComponentProps {
  data: DataType;
  style?: StyleProp<ViewStyle>;
  onPress?: () => void;
}

export const Component: React.FC<ComponentProps> = ({
  data,
  style,
  onPress,
}) => {
  return (
    <View style={[styles.container, style]}>
      {/* JSX */}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: Spacing.md,
    backgroundColor: Colors.white,
    borderRadius: 12,
    shadowColor: Colors.gray[900],
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
});
```

## タスク実行ガイド

### 新しいコンポーネントを作成する

1. `app/src/components/` にファイルを作成
2. Props interface を定義
3. StyleSheet.create でスタイルを定義
4. デザイントークンを使用
5. `app/src/components/index.ts` にエクスポートを追加

### 新しい画面を作成する

1. `app/app/(main)/` または `app/app/(onboarding)/` にファイルを作成
2. expo-router の規約に従う（ファイル名 = ルート）
3. 必要なストアをセレクターで接続
4. ローディング/エラー状態を実装

### ストアを更新する

1. 型定義を更新（`stores/[store]/types.ts`）
2. アクションを実装（`stores/[store]/index.ts`）
3. セレクターを追加（`stores/[store]/selectors.ts`）
4. コンポーネントでセレクターを使用

## チェックリスト

- [ ] TypeScript strict mode でエラーなし
- [ ] `any` 型を使用していない
- [ ] Props に interface が定義されている
- [ ] StyleSheet.create を使用している
- [ ] デザイントークンを使用している
- [ ] セレクターで必要なプロパティのみ選択している
- [ ] accessibilityLabel が設定されている

## 参照ドキュメント

- `.claude/react-native-standards.md`
- `.claude/ux-concepts.md`
- `.claude/templates/component.md`
- `.claude/templates/store.md`
- `docs/specs/tempoai_ui_spec.md`
