import SwiftUI

// MARK: - Progressive Disclosure Onboarding View

/// Interactive view that guides users through progressive data disclosure
/// Adapts complexity and detail based on user preferences and concerns
struct ProgressiveDisclosureView: View {

    @EnvironmentObject private var viewModel: OnboardingViewModel
    @State private var selectedLevel: ProgressiveDisclosureLevel = .minimal
    @State private var showingDetailedExplanation: Bool = false
    @State private var currentExplanationCategory: HealthDataCategory = .vitals

    var body: some View {
        VStack(spacing: 24) {

            // Header
            VStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                    .accessibilityHidden(true)

                Text("データ共有レベルの選択")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("あなたのプライバシーを尊重しながら、最適な健康アドバイスを提供するため、データ共有レベルをお選びください。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // Disclosure Level Selection
            VStack(spacing: 16) {
                ForEach(ProgressiveDisclosureLevel.allCases, id: \.self) { level in
                    DisclosureLevelCard(
                        level: level,
                        isSelected: selectedLevel == level,
                        onTap: {
                            selectedLevel = level
                            viewModel.updateDisclosureLevel(level)
                        },
                        onDetailTap: {
                            showDetailedExplanation(for: level)
                        }
                    )
                }
            }
            .padding(.horizontal)

            Spacer()

            // Privacy Concerns Section
            if selectedLevel != .minimal {
                PrivacyConcernsSection(
                    selectedLevel: selectedLevel,
                    onConcernSelected: { concern in
                        viewModel.recordPrivacyConcern(concern)
                    }
                )
                .transition(.slide)
            }

            Spacer()

            // Continue Button
            Button(action: {
                viewModel.advanceDisclosureStage()
                viewModel.nextPage()
            }) {
                Text("続行")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

        }
        .sheet(isPresented: $showingDetailedExplanation) {
            DetailedDataExplanationView(
                category: currentExplanationCategory,
                disclosureLevel: selectedLevel
            )
            .environmentObject(viewModel)
        }
        .onAppear {
            selectedLevel = viewModel.disclosureLevel
        }
    }

    private func showDetailedExplanation(for level: ProgressiveDisclosureLevel) {
        viewModel.setDetailedExplanationPreference(true)
        showingDetailedExplanation = true
    }
}

// MARK: - Disclosure Level Card

struct DisclosureLevelCard: View {
    let level: ProgressiveDisclosureLevel
    let isSelected: Bool
    let onTap: () -> Void
    let onDetailTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(level.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onDetailTap) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }

            // Benefits and considerations
            VStack(alignment: .leading, spacing: 8) {
                benefitsView
                considerationsView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture {
            onTap()
        }
    }

    @ViewBuilder
    private var benefitsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("メリット:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.green)

            ForEach(benefitsForLevel, id: \.self) { benefit in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(benefit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private var considerationsView: some View {
        if !considerationsForLevel.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("考慮事項:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)

                ForEach(considerationsForLevel, id: \.self) { consideration in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(consideration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }

    private var benefitsForLevel: [String] {
        switch level {
        case .minimal:
            return ["プライバシー保護", "基本的な健康追跡", "シンプルな操作"]
        case .selective:
            return ["カスタマイズ可能", "バランスの取れた分析", "必要に応じた詳細"]
        case .comprehensive:
            return ["詳細な分析", "包括的な健康管理", "パーソナライズされたアドバイス"]
        }
    }

    private var considerationsForLevel: [String] {
        switch level {
        case .minimal:
            return ["限定的な分析"]
        case .selective:
            return ["設定が必要"]
        case .comprehensive:
            return ["より多くのデータ共有", "詳細な許可設定"]
        }
    }
}

// MARK: - Privacy Concerns Section

struct PrivacyConcernsSection: View {
    let selectedLevel: ProgressiveDisclosureLevel
    let onConcernSelected: (PrivacyConcern) -> Void

    @State private var selectedConcerns: Set<PrivacyConcern> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("プライバシーに関する懸念事項（該当するものを選択）")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 12
            ) {
                ForEach(PrivacyConcern.allCases, id: \.self) { concern in
                    PrivacyConcernCard(
                        concern: concern,
                        isSelected: selectedConcerns.contains(concern),
                        onTap: {
                            if selectedConcerns.contains(concern) {
                                selectedConcerns.remove(concern)
                            } else {
                                selectedConcerns.insert(concern)
                                onConcernSelected(concern)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Privacy Concern Card

struct PrivacyConcernCard: View {
    let concern: PrivacyConcern
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack {
            Image(systemName: iconForConcern)
                .font(.title2)
                .foregroundColor(isSelected ? .white : .orange)

            Text(concern.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.orange : Color(.systemGray6))
        )
        .onTapGesture {
            onTap()
        }
    }

    private var iconForConcern: String {
        switch concern {
        case .dataSharing:
            return "square.and.arrow.up"
        case .thirdPartyAccess:
            return "person.3"
        case .dataRetention:
            return "clock.arrow.circlepath"
        case .anonymity:
            return "eye.slash"
        }
    }
}

// MARK: - Detailed Data Explanation View

struct DetailedDataExplanationView: View {
    let category: HealthDataCategory
    let disclosureLevel: ProgressiveDisclosureLevel

    @EnvironmentObject private var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss

    private var explanation: DataExplanation {
        viewModel.getPersonalizedExplanation(for: category)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Title and description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(explanation.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(explanation.shortDescription)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        if let detailedDescription = explanation.detailedDescription {
                            Text(detailedDescription)
                                .font(.body)
                                .padding(.top, 8)
                        }
                    }

                    // Benefits section
                    if !explanation.benefits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("メリット")
                                .font(.headline)
                                .foregroundColor(.green)

                            ForEach(explanation.benefits, id: \.self) { benefit in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(benefit)
                                    Spacer()
                                }
                            }
                        }
                    }

                    // Risks section
                    if !explanation.risks.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("リスク・考慮事項")
                                .font(.headline)
                                .foregroundColor(.orange)

                            ForEach(explanation.risks, id: \.self) { risk in
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text(risk)
                                    Spacer()
                                }
                            }
                        }
                    }

                    // Data types section
                    if !explanation.dataTypes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("収集するデータの種類")
                                .font(.headline)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                ], spacing: 8
                            ) {
                                ForEach(explanation.dataTypes, id: \.self) { dataType in
                                    Text(dataType)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }

                    // Retention and opt-out
                    VStack(alignment: .leading, spacing: 8) {
                        Text("データ管理")
                            .font(.headline)

                        HStack {
                            Image(systemName: "clock")
                            Text("保持期間: \(explanation.retentionPeriod)")
                        }

                        if explanation.canOptOut {
                            HStack {
                                Image(systemName: "hand.raised")
                                Text("いつでも設定を変更できます")
                            }
                        }
                    }

                }
                .padding()
            }
            .navigationTitle("詳細説明")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        viewModel.markDataCategoryExplained(category)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct ProgressiveDisclosureView_Previews: PreviewProvider {
        static var previews: some View {
            ProgressiveDisclosureView()
                .environmentObject(OnboardingViewModel())
        }
    }
#endif
