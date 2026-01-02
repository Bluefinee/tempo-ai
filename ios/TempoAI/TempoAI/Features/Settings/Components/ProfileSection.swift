//
//  ProfileSection.swift
//  TempoAI
//
//  Profile editing section for Settings screen
//

import SwiftUI

// MARK: - ProfileSection

/// プロフィール編集セクション
struct ProfileSection: View {

    // MARK: - Properties

    @Binding var nickname: String
    @Binding var weight: Double
    @Binding var height: Double
    @Binding var chronotype: Chronotype
    @Binding var targetBedtime: Date

    let age: Int
    let gender: Gender

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.md) {
            SectionHeader("プロフィール", icon: "person.circle")

            VStack(spacing: TempoSpacing.sm) {
                // ニックネーム（編集可能）
                nicknameRow

                // 年齢（読み取り専用）
                ageRow

                // 性別（読み取り専用）
                genderRow

                // 体重（編集可能）
                weightRow

                // 身長（編集可能）
                heightRow

                // クロノタイプ（編集可能）
                chronotypeRow

                // 目標就寝時刻（編集可能）
                bedtimeRow
            }
        }
    }

    // MARK: - Row Views

    private var nicknameRow: some View {
        CardView {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    Image(systemName: "person")
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 24)
                    Text("ニックネーム")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                TextField("ニックネーム", text: $nickname)
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("ニックネーム")
        .accessibilityValue(nickname)
    }

    private var ageRow: some View {
        FormRowView(label: "年齢", icon: "calendar") {
            Text("\(age)歳")
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)
        }
        .accessibilityLabel("年齢 \(age)歳")
    }

    private var genderRow: some View {
        FormRowView(label: "性別", icon: "person.2") {
            Text(gender.rawValue)
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)
        }
        .accessibilityLabel("性別 \(gender.rawValue)")
    }

    private var weightRow: some View {
        CardView {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    Image(systemName: "scalemass")
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 24)
                    Text("体重")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                HStack(spacing: TempoSpacing.xs) {
                    TextField("", value: $weight, format: .number.precision(.fractionLength(1)))
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 60)
                    Text("kg")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("体重")
        .accessibilityValue("\(String(format: "%.1f", weight))キログラム")
    }

    private var heightRow: some View {
        CardView {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    Image(systemName: "ruler")
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 24)
                    Text("身長")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                HStack(spacing: TempoSpacing.xs) {
                    TextField("", value: $height, format: .number.precision(.fractionLength(1)))
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 60)
                    Text("cm")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("身長")
        .accessibilityValue("\(String(format: "%.1f", height))センチメートル")
    }

    private var chronotypeRow: some View {
        CardView {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    Image(systemName: "clock")
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 24)
                    Text("クロノタイプ")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                Picker("クロノタイプ", selection: $chronotype) {
                    ForEach(Chronotype.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .tint(TempoColors.primary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("クロノタイプ")
        .accessibilityValue(chronotype.rawValue)
    }

    private var bedtimeRow: some View {
        CardView {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    Image(systemName: "moon.zzz")
                        .foregroundStyle(TempoColors.primary)
                        .frame(width: 24)
                    Text("目標就寝時刻")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                DatePicker(
                    "",
                    selection: $targetBedtime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .tint(TempoColors.primary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("目標就寝時刻")
        .accessibilityValue(bedtimeTimeString)
    }

    // MARK: - Private Helpers

    private static let bedtimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var bedtimeTimeString: String {
        Self.bedtimeFormatter.string(from: targetBedtime)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("ProfileSection") {
    ScrollView {
        ProfileSection(
            nickname: .constant("マサ"),
            weight: .constant(65.5),
            height: .constant(170.0),
            chronotype: .constant(.intermediate),
            targetBedtime: .constant(Date()),
            age: 30,
            gender: .male
        )
        .padding(TempoSpacing.screenPadding)
    }
    .background(TempoColors.background)
}
#endif
