import Combine
import Foundation

// MARK: - Progressive Disclosure Types

/// Represents the user's comfort level with data sharing
enum ProgressiveDisclosureLevel: String, CaseIterable, Codable {
    case minimal = "minimal"
    case selective = "selective"
    case comprehensive = "comprehensive"

    var displayName: String {
        switch self {
        case .minimal:
            return "最小限"
        case .selective:
            return "選択的"
        case .comprehensive:
            return "包括的"
        }
    }

    var description: String {
        switch self {
        case .minimal:
            return "基本的な健康指標のみを共有"
        case .selective:
            return "特定のデータカテゴリを選択して共有"
        case .comprehensive:
            return "詳細な分析のためにすべてのデータを共有"
        }
    }
}

/// Health data categories for progressive disclosure
enum HealthDataCategory: String, CaseIterable, Codable {
    case vitals = "vitals"
    case activity = "activity"
    case sleep = "sleep"
    case nutrition = "nutrition"
    case mentalHealth = "mentalHealth"
    case environmental = "environmental"

    var displayName: String {
        switch self {
        case .vitals:
            return "バイタルサイン"
        case .activity:
            return "身体活動"
        case .sleep:
            return "睡眠"
        case .nutrition:
            return "栄養"
        case .mentalHealth:
            return "メンタルヘルス"
        case .environmental:
            return "環境データ"
        }
    }
}

/// User's privacy concerns
enum PrivacyConcern: String, CaseIterable, Codable {
    case dataSharing = "dataSharing"
    case thirdPartyAccess = "thirdPartyAccess"
    case dataRetention = "dataRetention"
    case anonymity = "anonymity"

    var displayName: String {
        switch self {
        case .dataSharing:
            return "データ共有"
        case .thirdPartyAccess:
            return "第三者アクセス"
        case .dataRetention:
            return "データ保持"
        case .anonymity:
            return "匿名性"
        }
    }
}

/// Progressive disclosure stages in onboarding
enum DisclosureStage: String, CaseIterable, Codable {
    case introduction = "introduction"
    case basicPermissions = "basicPermissions"
    case dataCategories = "dataCategories"
    case privacySettings = "privacySettings"
    case detailedConsent = "detailedConsent"
    case completion = "completion"

    func nextStage() -> DisclosureStage {
        switch self {
        case .introduction:
            return .basicPermissions
        case .basicPermissions:
            return .dataCategories
        case .dataCategories:
            return .privacySettings
        case .privacySettings:
            return .detailedConsent
        case .detailedConsent:
            return .completion
        case .completion:
            return .completion
        }
    }

    var displayName: String {
        switch self {
        case .introduction:
            return "アプリ紹介"
        case .basicPermissions:
            return "基本権限"
        case .dataCategories:
            return "データカテゴリ"
        case .privacySettings:
            return "プライバシー設定"
        case .detailedConsent:
            return "詳細な同意"
        case .completion:
            return "完了"
        }
    }
}

/// Permission types with related data categories
enum PermissionType: String, CaseIterable, Codable {
    case healthKit = "healthKit"
    case location = "location"
    case notifications = "notifications"

    var relatedDataCategory: HealthDataCategory {
        switch self {
        case .healthKit:
            return .vitals
        case .location:
            return .environmental
        case .notifications:
            return .mentalHealth
        }
    }
}

/// Data sharing levels
enum DataSharingLevel: String, CaseIterable, Codable {
    case essential = "essential"
    case standard = "standard"
    case careful = "careful"
    case full = "full"

    var displayName: String {
        switch self {
        case .essential:
            return "必須のみ"
        case .standard:
            return "標準"
        case .careful:
            return "慎重"
        case .full:
            return "完全"
        }
    }
}

/// Data explanation structure
struct DataExplanation: Codable {
    let title: String
    let shortDescription: String
    let detailedDescription: String?
    let benefits: [String]
    let risks: [String]
    let dataTypes: [String]
    let retentionPeriod: String
    let canOptOut: Bool

    init(
        title: String,
        shortDescription: String,
        detailedDescription: String? = nil,
        benefits: [String] = [],
        risks: [String] = [],
        dataTypes: [String] = [],
        retentionPeriod: String = "1年間",
        canOptOut: Bool = true
    ) {
        self.title = title
        self.shortDescription = shortDescription
        self.detailedDescription = detailedDescription
        self.benefits = benefits
        self.risks = risks
        self.dataTypes = dataTypes
        self.retentionPeriod = retentionPeriod
        self.canOptOut = canOptOut
    }
}

/// Provider for data explanations
@MainActor
class DataExplanationProvider: ObservableObject {

    static let shared = DataExplanationProvider()

    private init() {}

    func getExplanation(
        for category: HealthDataCategory,
        level: ProgressiveDisclosureLevel,
        concerns: Set<PrivacyConcern>,
        detailedPreference: Bool,
        language: AppLanguage
    ) -> DataExplanation {

        let baseExplanation = getBaseExplanation(for: category, language: language)

        // Customize based on disclosure level
        switch level {
        case .minimal:
            return DataExplanation(
                title: baseExplanation.title,
                shortDescription: baseExplanation.shortDescription,
                benefits: Array(baseExplanation.benefits.prefix(2)),
                risks: [],
                dataTypes: Array(baseExplanation.dataTypes.prefix(2)),
                canOptOut: true
            )

        case .selective:
            return DataExplanation(
                title: baseExplanation.title,
                shortDescription: baseExplanation.shortDescription,
                detailedDescription: detailedPreference ? baseExplanation.detailedDescription : nil,
                benefits: baseExplanation.benefits,
                risks: concerns.contains(.dataSharing) ? baseExplanation.risks : [],
                dataTypes: baseExplanation.dataTypes,
                canOptOut: true
            )

        case .comprehensive:
            return baseExplanation
        }
    }

    private func getBaseExplanation(for category: HealthDataCategory, language: AppLanguage) -> DataExplanation {
        let isJapanese = language == .japanese

        switch category {
        case .vitals:
            return DataExplanation(
                title: isJapanese ? "バイタルサイン" : "Vital Signs",
                shortDescription: isJapanese
                    ? "心拍数、血圧、体温などの基本的な健康指標" : "Basic health metrics like heart rate, blood pressure, and temperature",
                detailedDescription: isJapanese
                    ? "バイタルサインは体の基本的な機能を示す重要な指標です。これらのデータを分析することで、健康状態の変化を早期に発見し、適切なアドバイスを提供できます。"
                    : "Vital signs are important indicators of your body's basic functions. " +
                        "By analyzing this data, we can detect early changes in your health and provide appropriate advice.",
                benefits: isJapanese
                    ? ["健康状態の早期発見", "個別化された健康アドバイス", "トレンド分析"]
                    : ["Early health detection", "Personalized health advice", "Trend analysis"],
                risks: isJapanese
                    ? ["医療データの機密性", "誤診の可能性"] : ["Medical data confidentiality", "Potential for misinterpretation"],
                dataTypes: isJapanese
                    ? ["心拍数", "血圧", "体温", "呼吸数"] : ["Heart rate", "Blood pressure", "Temperature", "Respiratory rate"]
            )

        case .activity:
            return DataExplanation(
                title: isJapanese ? "身体活動" : "Physical Activity",
                shortDescription: isJapanese
                    ? "歩数、運動時間、カロリー消費などの活動データ" : "Activity data like steps, exercise time, and calories burned",
                detailedDescription: isJapanese
                    ? "身体活動データは健康維持に欠かせない要素です。適切な運動レベルを維持することで、生活習慣病の予防や健康増進に役立ちます。"
                    : "Physical activity data is essential for health maintenance. " +
                        "Maintaining appropriate exercise levels helps prevent lifestyle diseases and promotes health.",
                benefits: isJapanese
                    ? ["運動習慣の改善", "カロリー管理", "フィットネス目標達成"]
                    : ["Exercise habit improvement", "Calorie management", "Fitness goal achievement"],
                risks: isJapanese ? ["位置情報の推測", "生活パターンの露呈"] : ["Location inference", "Life pattern exposure"],
                dataTypes: isJapanese
                    ? ["歩数", "運動時間", "カロリー", "距離"] : ["Steps", "Exercise time", "Calories", "Distance"]
            )

        case .sleep:
            return DataExplanation(
                title: isJapanese ? "睡眠" : "Sleep",
                shortDescription: isJapanese ? "睡眠時間、睡眠の質、睡眠パターンのデータ" : "Sleep duration, quality, and pattern data",
                detailedDescription: isJapanese
                    ? "良質な睡眠は健康の基盤です。睡眠データを分析することで、睡眠の質を改善し、日中のパフォーマンス向上につながります。"
                    : "Quality sleep is the foundation of health. " +
                        "By analyzing sleep data, we can improve sleep quality and enhance daytime performance.",
                benefits: isJapanese
                    ? ["睡眠の質改善", "生活リズムの最適化", "疲労回復の促進"]
                    : ["Sleep quality improvement", "Life rhythm optimization", "Recovery enhancement"],
                risks: isJapanese ? ["プライベート時間の監視", "生活習慣の露呈"] : ["Private time monitoring", "Lifestyle exposure"],
                dataTypes: isJapanese
                    ? ["就寝時刻", "起床時刻", "睡眠効率", "中途覚醒"]
                    : ["Bedtime", "Wake time", "Sleep efficiency", "Night awakenings"]
            )

        case .nutrition:
            return DataExplanation(
                title: isJapanese ? "栄養" : "Nutrition",
                shortDescription: isJapanese
                    ? "食事記録、カロリー摂取、栄養バランスのデータ" : "Food logs, calorie intake, and nutritional balance data",
                detailedDescription: isJapanese
                    ? "適切な栄養摂取は健康維持の重要な要素です。食事データを分析することで、栄養バランスを改善し、健康的な食習慣をサポートします。"
                    : "Proper nutrition is a crucial element of health maintenance. " +
                        "By analyzing dietary data, we can improve nutritional balance and support healthy eating habits.",
                benefits: isJapanese
                    ? ["栄養バランスの改善", "体重管理", "食習慣の最適化"]
                    : ["Nutritional balance improvement", "Weight management", "Eating habit optimization"],
                risks: isJapanese
                    ? ["食事習慣の監視", "個人的嗜好の露呈"] : ["Dietary habit monitoring", "Personal preference exposure"],
                dataTypes: isJapanese
                    ? ["カロリー", "タンパク質", "炭水化物", "脂質", "ビタミン"]
                    : ["Calories", "Protein", "Carbohydrates", "Fats", "Vitamins"]
            )

        case .mentalHealth:
            return DataExplanation(
                title: isJapanese ? "メンタルヘルス" : "Mental Health",
                shortDescription: isJapanese
                    ? "ストレスレベル、気分、精神的な健康状態のデータ" : "Stress levels, mood, and mental wellness data",
                detailedDescription: isJapanese
                    ? "メンタルヘルスは全体的な健康に大きく影響します。気分やストレスレベルを追跡することで、精神的な健康をサポートし、生活の質を向上させます。"
                    : "Mental health significantly impacts overall wellness. " +
                        "By tracking mood and stress levels, we can support mental wellness and improve quality of life.",
                benefits: isJapanese
                    ? ["ストレス管理", "気分の改善", "メンタルヘルスケア"]
                    : ["Stress management", "Mood improvement", "Mental healthcare"],
                risks: isJapanese ? ["精神状態の記録", "プライバシーへの懸念"] : ["Mental state recording", "Privacy concerns"],
                dataTypes: isJapanese
                    ? ["ストレス指標", "気分評価", "リラクゼーション時間"] : ["Stress indicators", "Mood ratings", "Relaxation time"]
            )

        case .environmental:
            return DataExplanation(
                title: isJapanese ? "環境データ" : "Environmental Data",
                shortDescription: isJapanese
                    ? "位置情報、天気、空気質などの環境要因" : "Location, weather, air quality and other environmental factors",
                detailedDescription: isJapanese
                    ? "環境要因は健康に大きな影響を与えます。位置情報や環境データを活用することで、環境に応じた健康アドバイスを提供できます。"
                    : "Environmental factors significantly impact health. " +
                        "By utilizing location and environmental data, we can provide health advice adapted to your environment.",
                benefits: isJapanese
                    ? ["環境に応じたアドバイス", "健康リスクの予防", "最適な活動提案"]
                    : ["Environment-based advice", "Health risk prevention", "Optimal activity suggestions"],
                risks: isJapanese ? ["位置情報の追跡", "行動パターンの推測"] : ["Location tracking", "Behavioral pattern inference"],
                dataTypes: isJapanese
                    ? ["GPS位置", "天気情報", "空気質指数", "紫外線レベル"]
                    : ["GPS location", "Weather data", "Air quality index", "UV levels"]
            )
        }
    }
}
