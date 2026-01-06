import { Stack } from 'expo-router';
import type { JSX } from 'react';

export default function OnboardingLayout(): JSX.Element {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        animation: 'slide_from_right',
        gestureEnabled: false, // オンボーディング中は戻るジェスチャーを無効化
      }}
    >
      <Stack.Screen name="index" />
      <Stack.Screen name="healthkit" />
      <Stack.Screen name="nickname" />
      <Stack.Screen name="basic-info" />
      <Stack.Screen name="chronotype" />
      <Stack.Screen name="bedtime" />
      <Stack.Screen name="lifestyle" />
      <Stack.Screen name="location" />
      <Stack.Screen name="complete" />
    </Stack>
  );
}
