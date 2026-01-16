/**
 * OnboardingContainer - オンボーディング画面の共通レイアウト
 * 背景装飾、プログレスインジケーター、SafeAreaを提供
 */

import type { ReactElement, ReactNode } from "react";
import React from "react";
import { Dimensions, StyleSheet, View } from "react-native";
import Animated, {
	Easing,
	useAnimatedStyle,
	useSharedValue,
	withRepeat,
	withTiming,
} from "react-native-reanimated";
import { SafeAreaView } from "react-native-safe-area-context";
import { Colors } from "../../theme";
import { ProgressIndicator } from "./ProgressIndicator";

const { width: SCREEN_WIDTH } = Dimensions.get("window");

interface OnboardingContainerProps {
	children: ReactNode;
	step: 1 | 2 | 3 | 4;
	showProgress?: boolean;
	blobVariant?: "default" | "warm" | "calm";
}

export const OnboardingContainer = ({
	children,
	step,
	showProgress = true,
	blobVariant = "default",
}: OnboardingContainerProps): ReactElement => {
	return (
		<SafeAreaView style={styles.container} edges={["top", "bottom"]}>
			{/* 背景の装飾的なBlob */}
			<BackgroundBlobs variant={blobVariant} />

			{/* プログレスインジケーター */}
			{showProgress && (
				<View style={styles.progressContainer}>
					<ProgressIndicator currentStep={step} />
				</View>
			)}

			{/* メインコンテンツ */}
			<View style={styles.content}>{children}</View>
		</SafeAreaView>
	);
};

interface BackgroundBlobsProps {
	variant: "default" | "warm" | "calm";
}

const BackgroundBlobs = ({ variant }: BackgroundBlobsProps): ReactElement => {
	const rotation = useSharedValue(0);

	React.useEffect(() => {
		rotation.value = withRepeat(
			withTiming(360, { duration: 60000, easing: Easing.linear }),
			-1,
			false,
		);
	}, [rotation]);

	const animatedStyle1 = useAnimatedStyle(() => ({
		transform: [{ rotate: `${rotation.value}deg` }],
	}));

	const animatedStyle2 = useAnimatedStyle(() => ({
		transform: [{ rotate: `${-rotation.value * 0.5}deg` }],
	}));

	const getBlobColors = () => {
		switch (variant) {
			case "warm":
				return {
					blob1: Colors.amber[100],
					blob2: Colors.rose[100],
				};
			case "calm":
				return {
					blob1: Colors.indigo[100],
					blob2: Colors.purple[100],
				};
			default:
				return {
					blob1: Colors.indigo[100],
					blob2: Colors.amber[100],
				};
		}
	};

	const colors = getBlobColors();

	return (
		<View style={styles.blobContainer} pointerEvents="none">
			<Animated.View
				style={[
					styles.blob,
					styles.blob1,
					{ backgroundColor: colors.blob1 },
					animatedStyle1,
				]}
			/>
			<Animated.View
				style={[
					styles.blob,
					styles.blob2,
					{ backgroundColor: colors.blob2 },
					animatedStyle2,
				]}
			/>
		</View>
	);
};

const BLOB_SIZE = SCREEN_WIDTH * 0.8;

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: Colors.stone[50],
	},
	progressContainer: {
		paddingTop: 8,
	},
	content: {
		flex: 1,
		paddingHorizontal: 24,
	},
	blobContainer: {
		...StyleSheet.absoluteFillObject,
		overflow: "hidden",
	},
	blob: {
		position: "absolute",
		width: BLOB_SIZE,
		height: BLOB_SIZE,
		borderRadius: BLOB_SIZE / 2,
		opacity: 0.4,
	},
	blob1: {
		top: -BLOB_SIZE * 0.3,
		right: -BLOB_SIZE * 0.3,
	},
	blob2: {
		bottom: -BLOB_SIZE * 0.4,
		left: -BLOB_SIZE * 0.3,
	},
});
