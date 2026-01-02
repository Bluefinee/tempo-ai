//
//  AboutSection.swift
//  TempoAI
//
//  About app section for Settings screen
//

import SwiftUI

// MARK: - AboutSection

/// アプリ情報セクション
struct AboutSection: View {

    // MARK: - Properties

    let versionString: String

    // MARK: - Private Properties

    // TODO: Replace with actual URLs when available
    private let privacyPolicyURL: String = "https://tempoai.app/privacy"
    private let termsOfServiceURL: String = "https://tempoai.app/terms"

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.md) {
            SectionHeader("アプリについて", icon: "info.circle")

            VStack(spacing: TempoSpacing.sm) {
                // バージョン
                versionRow

                // プライバシーポリシー
                privacyPolicyRow

                // 利用規約
                termsOfServiceRow
            }
        }
    }

    // MARK: - Row Views

    private var versionRow: some View {
        FormRowView(label: "バージョン", icon: "number") {
            Text(versionString)
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)
        }
        .accessibilityLabel("バージョン \(versionString)")
    }

    private var privacyPolicyRow: some View {
        CardView(onTap: { openURL(privacyPolicyURL) }) {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    Image(systemName: "hand.raised")
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 24)
                    Text("プライバシーポリシー")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14))
                    .foregroundStyle(TempoColors.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("プライバシーポリシー")
        .accessibilityHint("外部ブラウザで開きます")
        .accessibilityAddTraits(.isLink)
    }

    private var termsOfServiceRow: some View {
        CardView(onTap: { openURL(termsOfServiceURL) }) {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    Image(systemName: "doc.text")
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 24)
                    Text("利用規約")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14))
                    .foregroundStyle(TempoColors.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("利用規約")
        .accessibilityHint("外部ブラウザで開きます")
        .accessibilityAddTraits(.isLink)
    }

    // MARK: - Private Methods

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            assertionFailure("Invalid URL: \(urlString)")
            return
        }
        UIApplication.shared.open(url)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("AboutSection") {
    ScrollView {
        AboutSection(versionString: "Version 1.0.0 (1)")
            .padding(TempoSpacing.screenPadding)
    }
    .background(TempoColors.background)
}
#endif
