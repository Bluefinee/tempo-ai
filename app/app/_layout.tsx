import "../global.css";
import {
	PlusJakartaSans_400Regular,
	PlusJakartaSans_500Medium,
	PlusJakartaSans_600SemiBold,
	PlusJakartaSans_700Bold,
} from "@expo-google-fonts/plus-jakarta-sans";
import { useFonts } from "expo-font";
import { Stack } from "expo-router";
import * as SplashScreen from "expo-splash-screen";
import { StatusBar } from "expo-status-bar";
import type { JSX } from "react";
import { useCallback, useEffect } from "react";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { setLocale } from "../src/i18n";
import { useOnboardingStore } from "../src/stores/onboardingStore";

// Prevent splash screen from auto-hiding
SplashScreen.preventAutoHideAsync();

const RootLayout = (): JSX.Element | null => {
	const [fontsLoaded, fontError] = useFonts({
		PlusJakartaSans_400Regular,
		PlusJakartaSans_500Medium,
		PlusJakartaSans_600SemiBold,
		PlusJakartaSans_700Bold,
	});
	const savedLanguage = useOnboardingStore((state) => state.language);

	const onLayoutRootView = useCallback(async () => {
		if (fontsLoaded || fontError) {
			await SplashScreen.hideAsync();
		}
	}, [fontsLoaded, fontError]);

	useEffect(() => {
		onLayoutRootView();
	}, [onLayoutRootView]);

	// Restore saved language setting
	useEffect(() => {
		if (savedLanguage) {
			setLocale(savedLanguage);
		}
	}, [savedLanguage]);

	if (!fontsLoaded && !fontError) {
		return null;
	}

	return (
		<SafeAreaProvider>
			<StatusBar style="dark" />
			<Stack
				screenOptions={{
					headerShown: false,
					animation: "slide_from_right",
				}}
			>
				<Stack.Screen name="(onboarding)" />
				<Stack.Screen name="(main)" />
			</Stack>
		</SafeAreaProvider>
	);
};

export default RootLayout;
