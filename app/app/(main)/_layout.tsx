/**
 * Main Layout - タブナビゲーション
 * sozai/new/components/Navigation.tsx を React Native で完全再現
 */

import React from "react";
import { Tabs } from "expo-router";
import { View, StyleSheet, Platform } from "react-native";
import { BlurView } from "expo-blur";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Home, Activity, Wind, Settings, BarChart3 } from "lucide-react-native";
import { Colors, FontFamily } from "../../src/theme";
import * as Haptics from "expo-haptics";

// タブバーの基本高さ（SafeArea除く）
const TAB_BAR_BASE_HEIGHT = 60;

const handleTabPress = (): void => {
  if (Platform.OS === "ios") {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  }
};

const MainLayout = (): React.ReactElement => {
  const insets = useSafeAreaInsets();
  const tabBarHeight = TAB_BAR_BASE_HEIGHT + insets.bottom;

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: Colors.indigo[500],
        tabBarInactiveTintColor: Colors.stone[400],
        tabBarBackground: () => (
          <BlurView
            intensity={80}
            tint="light"
            style={StyleSheet.absoluteFill}
          />
        ),
        tabBarStyle: {
          position: "absolute",
          backgroundColor: "rgba(255, 255, 255, 0.8)",
          borderTopWidth: 1,
          borderTopColor: Colors.stone[200],
          height: tabBarHeight,
          paddingBottom: insets.bottom,
          paddingTop: 6,
        },
        tabBarLabelStyle: {
          fontFamily: FontFamily.medium,
          fontSize: 10,
          fontWeight: "500",
          marginTop: -2,
        },
        tabBarIconStyle: {
          marginBottom: -2,
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "Today",
          tabBarIcon: ({ color, focused }) => (
            <Home size={22} color={color} strokeWidth={focused ? 2.5 : 2} />
          ),
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      <Tabs.Screen
        name="rhythm"
        options={{
          title: "Rhythm",
          tabBarIcon: ({ color, focused }) => (
            <Activity size={22} color={color} strokeWidth={focused ? 2.5 : 2} />
          ),
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      <Tabs.Screen
        name="breathe"
        options={{
          title: "",
          tabBarIcon: ({ focused }) => (
            <View style={styles.breatheContainer}>
              <View
                style={[
                  styles.breatheButton,
                  focused && styles.breatheButtonActive,
                ]}
              >
                <Wind size={22} color={Colors.white} strokeWidth={2.5} />
              </View>
            </View>
          ),
          tabBarLabel: () => null,
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      <Tabs.Screen
        name="insights"
        options={{
          title: "Insights",
          tabBarIcon: ({ color, focused }) => (
            <BarChart3
              size={22}
              color={color}
              strokeWidth={focused ? 2.5 : 2}
            />
          ),
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      <Tabs.Screen
        name="settings"
        options={{
          title: "Settings",
          tabBarIcon: ({ color, focused }) => (
            <Settings size={22} color={color} strokeWidth={focused ? 2.5 : 2} />
          ),
        }}
        listeners={{
          tabPress: handleTabPress,
        }}
      />
      {/* Hidden detail screens */}
      <Tabs.Screen
        name="insight-detail"
        options={{
          href: null,
        }}
      />
      <Tabs.Screen
        name="action-detail"
        options={{
          href: null,
        }}
      />
      <Tabs.Screen
        name="health-detail"
        options={{
          href: null,
        }}
      />
      <Tabs.Screen
        name="recovery-detail"
        options={{
          href: null,
        }}
      />
      <Tabs.Screen
        name="sleep-detail"
        options={{
          href: null,
        }}
      />
      <Tabs.Screen
        name="rhythm-detail"
        options={{
          href: null,
        }}
      />
      <Tabs.Screen
        name="energy-detail"
        options={{
          href: null,
        }}
      />
    </Tabs>
  );
};

const styles = StyleSheet.create({
  breatheContainer: {
    position: "relative",
    top: -16,
    alignItems: "center",
    justifyContent: "center",
  },
  breatheButton: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: Colors.indigo[900],
    alignItems: "center",
    justifyContent: "center",
    shadowColor: Colors.indigo[900],
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 8,
  },
  breatheButtonActive: {
    backgroundColor: Colors.indigo[800],
  },
});

// Export tab bar height for use in other screens
export const TAB_BAR_HEIGHT = TAB_BAR_BASE_HEIGHT;

export default MainLayout;
