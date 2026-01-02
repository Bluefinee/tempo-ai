//
//  PeriodSelector.swift
//  TempoAI
//
//  期間選択セグメントコントロール
//

import SwiftUI

// MARK: - PeriodSelector

/// Analytics画面の期間選択コンポーネント
struct PeriodSelector: View {

    // MARK: - Properties

    @Binding var selectedPeriod: TimePeriod

    // MARK: - Body

    var body: some View {
        Picker("期間", selection: $selectedPeriod) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Text(period.displayName)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("期間選択")
        .accessibilityHint("週間または月間を選択できます")
    }
}

// MARK: - Preview

#Preview("Period Selector") {
    VStack(spacing: TempoSpacing.lg) {
        PeriodSelector(selectedPeriod: .constant(.weekly))
        PeriodSelector(selectedPeriod: .constant(.monthly))
    }
    .padding()
    .background(TempoColors.background)
}
