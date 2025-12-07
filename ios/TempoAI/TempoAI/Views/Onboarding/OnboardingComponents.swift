//
//  OnboardingComponents.swift
//  TempoAI
//
//  Created by Claude for modular architecture on 2024-12-06.
//  Shared UI components for the onboarding flow
//

import SwiftUI

// MARK: - Supporting Components

struct DataSourceCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}

struct PlanTypeRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct PermissionFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PermissionStatusRow: View {
    let status: PermissionStatus
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status == .granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(status == .granted ? .green : .red)

            Text(message)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(status == .granted ? .green : .red)

            Spacer()
        }
        .padding()
        .background((status == .granted ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(12)
    }
}
