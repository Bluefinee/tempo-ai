import { Redirect } from "expo-router";
import type { JSX } from "react";
import { useUserStore } from "../src/stores";

const Index = (): JSX.Element => {
	const isOnboardingComplete = useUserStore(
		(state) => state.isOnboardingComplete,
	);

	// Zustand persist middleware handles hydration automatically
	// During initial hydration, isOnboardingComplete will be false
	// which leads to onboarding, which is the correct default behavior

	if (isOnboardingComplete) {
		return <Redirect href="/(main)" />;
	}

	return <Redirect href="/(onboarding)" />;
};

export default Index;
