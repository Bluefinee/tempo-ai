# Phase 5: ナビゲーション更新

## 目的

- 3タブ → 5タブ構成への変更
- expo-router v6のTabsを使用
- Breatheタブの中央配置・特別デザイン

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | TypeScript規約、コメントポリシー |
| React Native規約 | `/.claude/react-native-standards.md` | ファイル命名、コンポーネント設計 |
| UI/UX仕様 | `/docs/specs/ui_ux_design.md` | タブバー設計、Breathe特別デザイン |
| Phase 1-4完了 | `/docs/cursor/01-04` | 依存する前提実装 |

---

## Task 5.1: 新規画面ファイル作成

### `app/app/(main)/rhythm.tsx`

```typescript
import { View, Text, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Colors, Spacing, Typography } from '@/theme';
import { t } from '@/i18n';

export default function RhythmScreen(): React.ReactElement {
  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>{t('screen.rhythm.title')}</Text>
        <Text style={styles.subtitle}>{t('screen.rhythm.subtitle')}</Text>
      </View>
      {/* Phase 6で実装 */}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.offWhite,
  },
  header: {
    paddingHorizontal: Spacing.xl,
    paddingTop: Spacing.lg,
  },
  title: {
    ...Typography.heading1,
    color: Colors.stone[900],
  },
  subtitle: {
    ...Typography.caption,
    color: Colors.stone[500],
    marginTop: Spacing.xs,
  },
});
```

### `app/app/(main)/breathe.tsx`

```typescript
import { View, Text, StyleSheet, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Colors, Spacing, Typography } from '@/theme';
import { t } from '@/i18n';

export default function BreatheScreen(): React.ReactElement {
  return (
    <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
      <View style={styles.content}>
        <Text style={styles.title}>{t('screen.breathe.title')}</Text>
        <View style={styles.circleContainer}>
          {/* Phase 6でBreathingCircle実装 */}
          <View style={styles.placeholderCircle} />
        </View>
        <Text style={styles.instruction}>{t('screen.breathe.tapToStart')}</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.deepNavy,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: Spacing.xl,
  },
  title: {
    ...Typography.heading2,
    color: Colors.white,
    marginBottom: Spacing.xxl,
  },
  circleContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  placeholderCircle: {
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: Colors.indigo[500],
    opacity: 0.3,
  },
  instruction: {
    ...Typography.body,
    color: Colors.stone[400],
    marginTop: Spacing.xxl,
  },
});
```

### `app/app/(main)/insights.tsx`

```typescript
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Colors, Spacing, Typography } from '@/theme';
import { t } from '@/i18n';

export default function InsightsScreen(): React.ReactElement {
  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={styles.title}>{t('screen.insights.title')}</Text>
          <Text style={styles.subtitle}>{t('screen.insights.subtitle')}</Text>
        </View>
        {/* Phase 6で実装 */}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.offWhite,
  },
  scrollContent: {
    paddingBottom: Spacing.xxl,
  },
  header: {
    paddingHorizontal: Spacing.xl,
    paddingTop: Spacing.lg,
  },
  title: {
    ...Typography.heading1,
    color: Colors.stone[900],
  },
  subtitle: {
    ...Typography.caption,
    color: Colors.stone[500],
    marginTop: Spacing.xs,
  },
});
```

---

## Task 5.2: タブレイアウト更新

### `app/app/(main)/_layout.tsx`

```typescript
import { Tabs } from 'expo-router';
import { View, StyleSheet, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { Colors, Spacing } from '@/theme';
import * as Haptics from 'expo-haptics';

type TabIconName = 'home' | 'analytics' | 'water' | 'bulb' | 'settings';

interface TabIconProps {
  name: TabIconName;
  color: string;
  size: number;
  focused: boolean;
  isBreathe?: boolean;
}

const TabIcon: React.FC<TabIconProps> = ({ name, color, size, focused, isBreathe }) => {
  const iconMap: Record<TabIconName, keyof typeof Ionicons.glyphMap> = {
    home: focused ? 'home' : 'home-outline',
    analytics: focused ? 'analytics' : 'analytics-outline',
    water: focused ? 'water' : 'water-outline',
    bulb: focused ? 'bulb' : 'bulb-outline',
    settings: focused ? 'settings' : 'settings-outline',
  };

  if (isBreathe) {
    return (
      <View style={styles.breatheIconContainer}>
        <View style={[styles.breatheIconBackground, focused && styles.breatheIconBackgroundFocused]}>
          <Ionicons name={iconMap[name]} size={size + 4} color={Colors.white} />
        </View>
      </View>
    );
  }

  return <Ionicons name={iconMap[name]} size={size} color={color} />;
};

const handleTabPress = (): void => {
  if (Platform.OS === 'ios') {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  }
};

export default function MainLayout(): React.ReactElement {
  const insets = useSafeAreaInsets();

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: Colors.indigo[500],
        tabBarInactiveTintColor: Colors.stone[400],
        tabBarStyle: {
          backgroundColor: Colors.white,
          borderTopWidth: 0,
          elevation: 0,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: -2 },
          shadowOpacity: 0.05,
          shadowRadius: 8,
          height: 60 + insets.bottom,
          paddingBottom: insets.bottom,
          paddingTop: Spacing.sm,
        },
        tabBarLabelStyle: {
          fontSize: 10,
          fontWeight: '500',
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Today',
          tabBarIcon: ({ color, size, focused }) => (
            <TabIcon name="home" color={color} size={size} focused={focused} />
          ),
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      <Tabs.Screen
        name="rhythm"
        options={{
          title: 'Rhythm',
          tabBarIcon: ({ color, size, focused }) => (
            <TabIcon name="analytics" color={color} size={size} focused={focused} />
          ),
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      <Tabs.Screen
        name="breathe"
        options={{
          title: 'Breathe',
          tabBarIcon: ({ color, size, focused }) => (
            <TabIcon name="water" color={color} size={size} focused={focused} isBreathe />
          ),
          tabBarLabelStyle: {
            fontSize: 10,
            fontWeight: '600',
            color: Colors.indigo[500],
          },
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      <Tabs.Screen
        name="insights"
        options={{
          title: 'Insights',
          tabBarIcon: ({ color, size, focused }) => (
            <TabIcon name="bulb" color={color} size={size} focused={focused} />
          ),
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      <Tabs.Screen
        name="settings"
        options={{
          title: 'Settings',
          tabBarIcon: ({ color, size, focused }) => (
            <TabIcon name="settings" color={color} size={size} focused={focused} />
          ),
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      {/* 削除: analyticsは別途削除 */}
    </Tabs>
  );
}

const styles = StyleSheet.create({
  breatheIconContainer: {
    position: 'relative',
    top: -10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  breatheIconBackground: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: Colors.indigo[400],
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: Colors.indigo[500],
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  breatheIconBackgroundFocused: {
    backgroundColor: Colors.indigo[500],
  },
});
```

---

## Task 5.3: 不要ファイル削除

### 削除対象

```bash
# app/app/(main)/analytics.tsx を削除
rm app/app/(main)/analytics.tsx
```

**理由**: Insights画面に置き換え

---

## Task 5.4: insight-detail画面の移動（任意）

現在 `app/app/insight-detail.tsx` にある画面は、必要に応じてモーダルまたはスタック画面として維持。

---

## Phase 5 完了時の検証

### 必須コマンド（全てパスすること）

```bash
cd app

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. ビルド確認（iOS）
pnpm ios --no-dev

# 4. ビルド確認（Android）
pnpm android --no-dev
```

### 動作確認

```
# シミュレーター/エミュレーターで確認
1. アプリ起動後、5つのタブが表示される
2. 各タブをタップすると対応する画面に遷移する
3. Breatheタブが中央に配置され、浮き出しデザインになっている
4. タブタップ時にHapticフィードバックがある（iOS）
5. analytics画面へのアクセスがない（削除済み）
```

### 完了チェックリスト

- [ ] `app/app/(main)/rhythm.tsx` が作成されている
- [ ] `app/app/(main)/breathe.tsx` が作成されている
- [ ] `app/app/(main)/insights.tsx` が作成されている
- [ ] `app/app/(main)/_layout.tsx` が5タブ構成に更新されている
- [ ] `app/app/(main)/analytics.tsx` が削除されている
- [ ] Breatheタブが中央に浮き出しデザインで表示される
- [ ] Hapticフィードバックが動作する
- [ ] **`pnpm typecheck` でエラーなし**
- [ ] **`pnpm lint` でエラーなし**
- [ ] **iOS ビルドが成功する**
- [ ] **Android ビルドが成功する**

---

## 次のフェーズ

Phase 5 の全てのチェックが完了したら、`06-phase6-screens.md` に進む。
