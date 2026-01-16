import type { JSX } from "react";
import React from "react";
import { ActivityIndicator, StyleSheet, Text, View } from "react-native";
import { t } from "../i18n";
import { Colors, Spacing, Typography } from "../theme";

interface LoadingViewProps {
	message?: string;
}

export const LoadingView = ({
	message = t("common.loading"),
}: LoadingViewProps): JSX.Element => {
	return (
		<View style={styles.container}>
			<ActivityIndicator size="large" color={Colors.indigo[500]} />
			<Text style={styles.message}>{message}</Text>
		</View>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		justifyContent: "center",
		alignItems: "center",
		backgroundColor: Colors.offWhite,
	},
	message: {
		...Typography.body,
		color: Colors.stone[500],
		marginTop: Spacing.lg,
	},
});
