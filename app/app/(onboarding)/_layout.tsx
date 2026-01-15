/**
 * Onboarding Layout
 * 6-screen flow: Language → Welcome → Nickname → Personalize → Connect → Ready
 */

import { Stack } from "expo-router";
import type { ReactElement } from "react";
import { Colors } from "../../src/theme";

const OnboardingLayout = (): ReactElement => {
	return (
		<Stack
			screenOptions={{
				headerShown: false,
				gestureEnabled: false,
				contentStyle: {
					backgroundColor: Colors.stone[50],
				},
				animation: "fade",
				animationDuration: 400,
			}}
		>
			<Stack.Screen
				name="index"
				options={{
					animation: "fade",
				}}
			/>
			<Stack.Screen
				name="welcome"
				options={{
					animation: "fade",
				}}
			/>
			<Stack.Screen
				name="nickname"
				options={{
					animation: "slide_from_right",
				}}
			/>
			<Stack.Screen
				name="personalize"
				options={{
					animation: "slide_from_bottom",
				}}
			/>
			<Stack.Screen
				name="connect"
				options={{
					animation: "slide_from_right",
				}}
			/>
			<Stack.Screen
				name="ready"
				options={{
					animation: "fade_from_bottom",
				}}
			/>
		</Stack>
	);
};

export default OnboardingLayout;
