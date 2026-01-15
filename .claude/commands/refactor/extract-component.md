---
description: 画面からコンポーネントを抽出してリファクタリング
allowed-tools: Read, Write, Edit, Glob, Grep
---

# コンポーネント抽出リファクタリング

対象: $ARGUMENTS

## 手順

### 1. 対象コードの分析

1. 指定されたファイルを読み込む
2. 抽出可能な部分を特定:
   - 繰り返し使用されているUI
   - 独立した責務を持つ部分
   - 複雑なロジックを含む部分

### 2. コンポーネント設計

```typescript
// 新しいコンポーネントの設計
interface NewComponentProps {
  // 必要な props を特定
  data: DataType;
  onAction?: () => void;
  style?: StyleProp<ViewStyle>;
}
```

### 3. コンポーネント作成

ファイル: `app/src/components/[ComponentName].tsx`

```typescript
import React from 'react';
import { View, Text, StyleSheet, StyleProp, ViewStyle } from 'react-native';
import { Colors, Spacing, Typography } from '@/theme';

interface [ComponentName]Props {
  // props定義
}

export const [ComponentName]: React.FC<[ComponentName]Props> = ({
  // destructure props
}) => {
  return (
    <View style={styles.container}>
      {/* JSX */}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    // styles
  },
});
```

### 4. 元のファイルを更新

1. 新しいコンポーネントをインポート
2. 抽出した部分を新しいコンポーネントに置き換え
3. 必要な props を渡す

### 5. エクスポートの追加

`app/src/components/index.ts` に追加:
```typescript
export { [ComponentName] } from './[ComponentName]';
```

### 6. 検証

- [ ] 型エラーがないこと
- [ ] 元の画面が正常に動作すること
- [ ] 新しいコンポーネントが再利用可能であること

## 命名規則

| 種類 | 命名例 |
|------|--------|
| 表示のみ | `ScoreDisplay`, `MetricCard` |
| インタラクティブ | `ScoreSelector`, `DatePicker` |
| コンテナ | `ScoreContainer`, `MetricList` |
| レイアウト | `GridLayout`, `CardStack` |
