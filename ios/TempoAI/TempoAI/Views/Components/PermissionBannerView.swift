import SwiftUI

/// Banner view to encourage users to enable permissions for better app experience
struct PermissionBannerView: View {
    let type: PermissionBannerType
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: type.icon)
                .font(.title2)
                .foregroundColor(type.iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(type.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            // Action Button
            Button(action: action) {
                Text(NSLocalizedString("permission_banner_enable", comment: "Enable in Settings"))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(type.buttonColor)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(type.backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.borderColor, lineWidth: 1)
        )
    }
}

/// Types of permission banners that can be displayed
enum PermissionBannerType {
    case healthKit
    case location
    case both

    var icon: String {
        switch self {
        case .healthKit:
            return "heart.text.square"
        case .location:
            return "location.circle"
        case .both:
            return "exclamationmark.triangle"
        }
    }

    var iconColor: Color {
        switch self {
        case .healthKit:
            return .red
        case .location:
            return .blue
        case .both:
            return .orange
        }
    }

    var title: String {
        switch self {
        case .healthKit:
            return NSLocalizedString("permission_banner_healthkit_title", comment: "Enable HealthKit integration")
        case .location:
            return NSLocalizedString("permission_banner_location_title", comment: "Enable location access")
        case .both:
            return NSLocalizedString("permission_banner_both_title", comment: "Complete setup for better experience")
        }
    }

    var description: String {
        switch self {
        case .healthKit:
            return NSLocalizedString(
                "permission_banner_healthkit_description", comment: "Get personalized health insights")
        case .location:
            return NSLocalizedString("permission_banner_location_description", comment: "Receive weather-based advice")
        case .both:
            return NSLocalizedString(
                "permission_banner_both_description", comment: "Enable permissions for full functionality")
        }
    }

    var buttonColor: Color {
        switch self {
        case .healthKit:
            return .red
        case .location:
            return .blue
        case .both:
            return .orange
        }
    }

    var backgroundColor: Color {
        switch self {
        case .healthKit:
            return .red.opacity(0.05)
        case .location:
            return .blue.opacity(0.05)
        case .both:
            return .orange.opacity(0.05)
        }
    }

    var borderColor: Color {
        switch self {
        case .healthKit:
            return .red.opacity(0.2)
        case .location:
            return .blue.opacity(0.2)
        case .both:
            return .orange.opacity(0.2)
        }
    }
}

#Preview("HealthKit Banner") {
    VStack(spacing: 16) {
        PermissionBannerView(type: .healthKit) {
            // Preview action
        }

        PermissionBannerView(type: .location) {
            // Preview action
        }

        PermissionBannerView(type: .both) {
            // Preview action
        }
    }
    .padding()
}
