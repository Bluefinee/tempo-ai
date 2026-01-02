//
//  SettingsView.swift
//  TempoAI
//
//  Settings main screen
//

import CoreLocation
import SwiftUI

// MARK: - SettingsView

/// 設定画面メインビュー
struct SettingsView: View {

    // MARK: - Properties

    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    @StateObject private var healthKitManager: HealthKitManager = HealthKitManager()
    @State private var locationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager: CLLocationManager = CLLocationManager()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                TempoColors.background
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                } else {
                    settingsContent
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .alert(item: $viewModel.error) { error in
                Alert(
                    title: Text("エラー"),
                    message: Text(error.errorDescription ?? "不明なエラー"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.loadProfile()
                updateLocationStatus()
            }
        }
    }

    // MARK: - Settings Content

    private var settingsContent: some View {
        ScrollView {
            VStack(spacing: TempoSpacing.xl) {
                // Profile Section
                ProfileSection(
                    nickname: $viewModel.nickname,
                    weight: $viewModel.weight,
                    height: $viewModel.height,
                    chronotype: $viewModel.chronotype,
                    targetBedtime: $viewModel.targetBedtime,
                    age: viewModel.age,
                    gender: viewModel.gender
                )

                // Data Section
                DataSection(
                    healthKitStatus: healthKitManager.authorizationStatus,
                    locationStatus: locationStatus
                )

                // About Section
                AboutSection(versionString: viewModel.versionDisplayString)

                // Save Button (if changes exist)
                if viewModel.hasChanges {
                    saveButton
                }

                // Success Message
                if viewModel.showSaveSuccess {
                    successMessage
                }
            }
            .padding(.horizontal, TempoSpacing.screenPadding)
            .padding(.vertical, TempoSpacing.md)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.hasChanges {
                Button("リセット") {
                    viewModel.resetToOriginal()
                }
                .foregroundStyle(TempoColors.textSecondary)
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        PrimaryButton("保存") {
            Task {
                await viewModel.saveProfile()
            }
        }
        .disabled(viewModel.isSaving)
        .overlay {
            if viewModel.isSaving {
                ProgressView()
                    .tint(.white)
            }
        }
    }

    // MARK: - Success Message

    private var successMessage: some View {
        HStack(spacing: TempoSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(TempoColors.primary)
            Text("保存しました")
                .font(TempoTypography.callout)
                .foregroundStyle(TempoColors.primary)
        }
        .padding(TempoSpacing.md)
        .background(TempoColors.primary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.buttonCornerRadius))
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut, value: viewModel.showSaveSuccess)
    }

    // MARK: - Private Methods

    private func updateLocationStatus() {
        locationStatus = locationManager.authorizationStatus
    }
}

// MARK: - Preview

#if DEBUG
#Preview("SettingsView") {
    SettingsView()
}
#endif
