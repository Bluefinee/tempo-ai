# React Native コンポーネントテンプレート

## 基本コンポーネント

```typescript
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  StyleProp,
  ViewStyle,
  TouchableOpacity,
} from 'react-native';
import { Colors, Spacing, Typography } from '@/theme';

// ============================================
// Types
// ============================================

interface ComponentNameProps {
  /** 主要なデータ */
  data: DataType;
  /** スタイルのオーバーライド */
  style?: StyleProp<ViewStyle>;
  /** タップ時のコールバック */
  onPress?: () => void;
  /** 子要素 */
  children?: React.ReactNode;
}

// ============================================
// Component
// ============================================

/**
 * ComponentName - コンポーネントの説明
 *
 * @example
 * <ComponentName data={data} onPress={() => console.log('pressed')} />
 */
export const ComponentName: React.FC<ComponentNameProps> = ({
  data,
  style,
  onPress,
  children,
}) => {
  // ============================================
  // Hooks
  // ============================================

  // ============================================
  // Handlers
  // ============================================

  const handlePress = (): void => {
    onPress?.();
  };

  // ============================================
  // Render
  // ============================================

  const Container = onPress ? TouchableOpacity : View;

  return (
    <Container
      style={[styles.container, style]}
      onPress={onPress ? handlePress : undefined}
      activeOpacity={0.8}
    >
      <Text style={styles.title}>{data.title}</Text>
      {children}
    </Container>
  );
};

// ============================================
// Styles
// ============================================

const styles = StyleSheet.create({
  container: {
    padding: Spacing.md,
    backgroundColor: Colors.white,
    borderRadius: 12,
    // 浮遊感シャドウ（TempoAIスタイル）
    shadowColor: Colors.gray[900],
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  title: {
    ...Typography.heading3,
    color: Colors.gray[900],
  },
});
```

---

## スコア表示コンポーネント

```typescript
import React, { useMemo } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, Typography } from '@/theme';
import type { Score, ScoreStatus } from '@/domain/models';

interface ScoreDisplayProps {
  score: Score;
  label: string;
  showTrend?: boolean;
}

const statusColors: Record<ScoreStatus, string> = {
  excellent: Colors.green[500],
  good: Colors.blue[500],
  moderate: Colors.yellow[500],
  needs_attention: Colors.orange[500],
};

export const ScoreDisplay: React.FC<ScoreDisplayProps> = ({
  score,
  label,
  showTrend = false,
}) => {
  const statusColor = useMemo(
    () => statusColors[score.status],
    [score.status]
  );

  return (
    <View style={styles.container}>
      <Text style={styles.label}>{label}</Text>
      <Text style={[styles.value, { color: statusColor }]}>
        {score.value}
      </Text>
      {showTrend && score.trend && (
        <Text style={styles.trend}>
          {score.trend > 0 ? '↑' : '↓'} {Math.abs(score.trend)}%
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    padding: Spacing.sm,
  },
  label: {
    ...Typography.caption,
    color: Colors.gray[500],
    marginBottom: Spacing.xs,
  },
  value: {
    ...Typography.heading1,
  },
  trend: {
    ...Typography.caption,
    marginTop: Spacing.xs,
  },
});
```

---

## アニメーション付きコンポーネント

```typescript
import React, { useEffect } from 'react';
import { View, StyleSheet } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  Easing,
} from 'react-native-reanimated';

interface AnimatedCardProps {
  children: React.ReactNode;
  delay?: number;
}

export const AnimatedCard: React.FC<AnimatedCardProps> = ({
  children,
  delay = 0,
}) => {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(20);

  useEffect(() => {
    const timeout = setTimeout(() => {
      opacity.value = withTiming(1, {
        duration: 400,
        easing: Easing.out(Easing.cubic),
      });
      translateY.value = withTiming(0, {
        duration: 400,
        easing: Easing.out(Easing.cubic),
      });
    }, delay);

    return () => clearTimeout(timeout);
  }, [delay, opacity, translateY]);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));

  return (
    <Animated.View style={[styles.container, animatedStyle]}>
      {children}
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    // base styles
  },
});
```

---

## チェックリスト

- [ ] Props に interface を定義
- [ ] JSDoc コメントを追加
- [ ] StyleSheet.create を使用
- [ ] デザイントークン（Colors, Spacing, Typography）を使用
- [ ] 適切な accessibilityLabel を設定
- [ ] onPress がある場合は TouchableOpacity を使用
