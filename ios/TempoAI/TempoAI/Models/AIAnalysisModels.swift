/**
 * @fileoverview AI Analysis Data Models
 *
 * AI分析システム用のデータ構造を定義。
 * ヘルスケアデータ、環境データ、ユーザーコンテキストを統合し、
 * 包括的なヘルスケア分析とパーソナライズされた提案を提供します。
 */

import Foundation

// MARK: - Analysis Request Models

/// AI分析リクエストの包括的データ構造
/// ヘルスケアデータとユーザーコンテキストを統合してパーソナライズ分析を要求
struct AIAnalysisRequest: Codable {
    /// 現在のエネルギーレベル (0-100)
    let batteryLevel: Double
    /// エネルギーの変化傾向
    let batteryTrend: BatteryTrend
    /// 生物学的コンテキスト（HealthKitデータから算出）
    let biologicalContext: BiologicalContext
    /// 環境コンテキスト（気象データ）
    let environmentalContext: EnvironmentalContext
    /// ユーザーコンテキスト（設定・状況）
    let userContext: UserContext
}

/// エネルギーレベルの変化傾向
enum BatteryTrend: String, Codable, CaseIterable {
    case recovering = "recovering"  // 回復中
    case declining = "declining"  // 低下中
    case stable = "stable"  // 安定
}

/// 生物学的コンテキスト
/// HealthKitから取得される処理済み健康指標
struct BiologicalContext: Codable {
    /// HRV状態（基準値からの偏差 ms）
    let hrvStatus: Double
    /// 心拍数状態（基準値からの差分 bpm）
    let rhrStatus: Double
    /// 深い睡眠時間（分）
    let sleepDeep: Int
    /// REM睡眠時間（分）
    let sleepRem: Int
    /// 呼吸数（回/分）
    let respiratoryRate: Double
    /// 歩数
    let steps: Int
    /// 消費カロリー（kcal）
    let activeCalories: Double
}

/// 環境コンテキスト
/// 気象データから健康に影響する要因を抽出
struct EnvironmentalContext: Codable {
    /// 気圧変化（6時間での変動 hPa）
    let pressureTrend: Double
    /// 相対湿度（%）
    let humidity: Double
    /// 体感温度（°C）
    let feelsLike: Double
    /// UVインデックス
    let uvIndex: Double
    /// 天候コード（WMO）
    let weatherCode: Int
}

/// ユーザーコンテキスト
/// パーソナライゼーションに必要なユーザー固有情報
struct UserContext: Codable {
    /// アクティブなフォーカスタグ
    let activeTags: [FocusTag]
    /// 時間帯
    let timeOfDay: TimeOfDay
    /// 言語設定
    let language: Language
    /// ユーザーモード
    let userMode: UserMode
}

/// 時間帯の定義
enum TimeOfDay: String, Codable, CaseIterable {
    case morning = "morning"  // 朝（6-12時）
    case afternoon = "afternoon"  // 午後（12-17時）
    case evening = "evening"  // 夕方（17-21時）
    case night = "night"  // 夜（21-6時）
}

/// 言語設定
enum Language: String, Codable, CaseIterable {
    case japanese = "ja"
    case english = "en"
}

// MARK: - Analysis Response Models

/// AI分析レスポンスの包括的データ構造
/// ヘッドライン、詳細分析、アクション提案を含む総合的な健康アドバイス
struct AIAnalysisResponse: Codable {
    /// ヘッドライン（結論ファースト）
    let headline: HeadlineInsight
    /// エネルギーコメント（バッテリー状態の人間的解釈）
    let energyComment: String
    /// タグ別インサイト（関心分野別の専門的観点）
    let tagInsights: [TagInsight]
    /// AI生成アクション提案
    let aiActionSuggestions: [AIActionSuggestion]
    /// 詳細分析（根拠データ）
    let detailAnalysis: String
    /// データ品質情報
    let dataQuality: DataQuality
    /// 生成日時
    let generatedAt: Date
}

/// ヘッドライン（瞬時に理解できる結論）
struct HeadlineInsight: Codable {
    /// メインタイトル
    let title: String
    /// サブタイトル（補足説明）
    let subtitle: String
    /// 影響レベル（UI色分け用）
    let impactLevel: ImpactLevel
    /// AI信頼度（0-100%）
    let confidence: Double
}

/// 影響レベル（UI表示用カラーコーディング）
enum ImpactLevel: String, Codable, CaseIterable {
    case low = "low"  // 軽微（緑系）
    case medium = "medium"  // 注意（黄系）
    case high = "high"  // 重要（橙系）
    case critical = "critical"  // 緊急（赤系）
}

/// フォーカスタグ別の専門的インサイト
struct TagInsight: Codable {
    /// 対象タグ
    let tag: FocusTag
    /// SFシンボル名
    let icon: String
    /// メッセージ
    let message: String
    /// 緊急度
    let urgency: Urgency
}

/// 緊急度レベル
enum Urgency: String, Codable, CaseIterable {
    case info = "info"  // 情報
    case warning = "warning"  // 警告
    case critical = "critical"  // 重要
}

/// 実行可能な小さなアクション提案
struct AIActionSuggestion: Codable {
    /// 提案タイトル
    let title: String
    /// 詳細説明
    let description: String
    /// アクションタイプ
    let actionType: ActionType
    /// 推定所要時間
    let estimatedTime: String
    /// 難易度
    let difficulty: Difficulty
}

/// アクションタイプ
enum ActionType: String, Codable, CaseIterable {
    case rest = "rest"  // 休息
    case hydrate = "hydrate"  // 水分補給
    case exercise = "exercise"  // 運動
    case focus = "focus"  // 集中
    case social = "social"  // 社交
    case beauty = "beauty"  // 美容ケア
}

/// 難易度レベル
enum Difficulty: String, Codable, CaseIterable {
    case easy = "easy"  // 簡単（1-5分）
    case medium = "medium"  // 普通（5-15分）
    case hard = "hard"  // 難しい（15分以上）
}

/// データ品質と信頼性情報
struct DataQuality: Codable {
    /// HealthKitデータの完全性（0-100%）
    let healthDataCompleteness: Double
    /// 気象データの鮮度（分）
    let weatherDataAge: Int
    /// 分析タイムスタンプ
    let analysisTimestamp: Date
}

// MARK: - Analysis Result Container

/// 分析結果の統合コンテナ
/// 複数の分析手法による結果を統合管理
struct AnalysisResult: Codable {
    /// 静的分析結果（即座に表示）
    let staticAnalysis: StaticAnalysis?
    /// AI分析結果（拡張表示）
    let aiAnalysis: AIAnalysisResponse?
    /// データソース
    let source: AnalysisSource
    /// 最終更新時刻
    let lastUpdated: Date
}

/// 静的分析結果
/// 数値計算による基本的な健康指標
struct StaticAnalysis: Codable {
    /// エネルギーレベル
    let energyLevel: Double
    /// バッテリー状態
    let batteryState: BatteryState
    /// 基本メトリクス
    let basicMetrics: BasicMetrics
    /// 生成時刻
    let generatedAt: Date
}

/// 基本メトリクス
struct BasicMetrics: Codable {
    /// 睡眠スコア
    let sleepScore: Double
    /// 活動スコア
    let activityScore: Double
    /// ストレススコア
    let stressScore: Double
}

/// 分析ソース
enum AnalysisSource: String, Codable, CaseIterable {
    case staticOnly = "static_only"  // 静的のみ
    case hybrid = "hybrid"  // ハイブリッド（真のAI）
    case cached = "cached"  // キャッシュ済みAI
    case fallback = "fallback"  // フォールバック（AI接続失敗）
    case aiError = "ai_error"  // AI接続エラー
}

// MARK: - Extensions for Existing Types

/// 既存FocusTagへの拡張
/// AI分析用のメタデータを追加
extension FocusTag {
    /// AI分析での重要度
    var analysisWeight: Double {
        switch self {
        case .work: return 1.2  // 仕事は認知負荷が高い
        case .beauty: return 0.8  // 美容は環境要因が重要
        case .diet: return 1.0  // 食事はバランス重視
        case .sleep: return 1.3  // 睡眠は最重要
        case .fitness: return 1.1  // フィットネスは負荷管理
        case .chill: return 0.9  // リラックスは心的要素
        }
    }

    /// 関連する環境要因
    var environmentalFactors: [String] {
        switch self {
        case .work:
            return ["気圧", "湿度", "気温"]
        case .beauty:
            return ["湿度", "UV指数", "気温"]
        case .diet:
            return ["気温", "湿度"]
        case .sleep:
            return ["気圧", "気温", "湿度"]
        case .fitness:
            return ["気温", "湿度", "UV指数"]
        case .chill:
            return ["気圧", "湿度"]
        }
    }
}

/// 既存UserModeへの拡張
/// AI分析での解釈調整
extension UserMode {
    /// エネルギー消費の基準値調整
    var energyConsumptionModifier: Double {
        switch self {
        case .standard: return 1.0  // 標準的な消費
        case .athlete: return 1.2  // アスリートは高消費許容
        }
    }

    /// 回復速度の基準値調整
    var recoverySpeedModifier: Double {
        switch self {
        case .standard: return 1.0  // 標準的な回復
        case .athlete: return 1.1  // アスリートは回復力高
        }
    }
}
