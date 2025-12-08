/**
 * @fileoverview Hybrid Analysis Engine
 *
 * 静的計算とAI分析を統合する中核エンジン。
 * UXの「Progressive Disclosure」原則に従い、即座の静的分析に
 * 段階的なAI拡張を組み合わせ、最適な応答時間と分析精度を実現します。
 */

import Combine
import Foundation
import SwiftUI
import os.log

/// ハイブリッド分析エンジン
/// 静的分析（0.5秒以内）とAI拡張分析（2秒以内）を調整
@MainActor
class HybridAnalysisEngine: ObservableObject {
    // MARK: - Published Properties

    /// 現在の分析結果
    @Published var currentAnalysis: AnalysisResult?
    /// 分析実行中フラグ
    @Published var isAnalyzing: Bool = false
    /// AI拡張中フラグ
    @Published var isEnhancingWithAI: Bool = false
    /// エラー状態
    @Published var analysisError: AnalysisError?

    // MARK: - Dependencies

    private let batteryEngine: BatteryEngine
    private let weatherService: WeatherServiceProtocol
    private let aiAnalysisService: AIAnalysisServiceProtocol
    private let cacheManager: AnalysisCacheManagerProtocol
    private let staticAnalysisEngine: StaticAnalysisEngine

    // MARK: - Private Properties

    private var lastAnalysisTime: Date?
    private var lastEnergyLevel: Double?

    // MARK: - Initialization

    init(
        batteryEngine: BatteryEngine,
        weatherService: WeatherServiceProtocol,
        aiAnalysisService: AIAnalysisServiceProtocol,
        cacheManager: AnalysisCacheManagerProtocol
    ) {
        self.batteryEngine = batteryEngine
        self.weatherService = weatherService
        self.aiAnalysisService = aiAnalysisService
        self.cacheManager = cacheManager
        self.staticAnalysisEngine = StaticAnalysisEngine()
    }

    // MARK: - Public Methods

    /**
     * 包括的な分析を実行
     * プログレッシブディスクロージャー: 静的 → AI拡張
     */
    func generateAnalysis() async {
        guard !isAnalyzing else { return }

        await setAnalysisState(analyzing: true, enhancing: false, error: nil)

        do {
            // Stage 1: 静的分析（即座に表示）
            let staticResult = await generateStaticAnalysis()
            await updateAnalysisResult(staticResult)

            // Stage 2: AI拡張分析（段階的に追加）
            await enhanceWithAI()
            
            await setAnalysisState(analyzing: false, enhancing: false, error: nil)
        } catch {
            os_log("Analysis failed: %{public}@", log: .default, type: .error, error.localizedDescription)
            await setAnalysisError(AnalysisError.analysisGenerationFailed(error))
            await setAnalysisState(analyzing: false, enhancing: false, error: analysisError)
        }
    }

    /**
     * 静的分析のみを実行（AI無効時やオフライン時）
     */
    func generateStaticAnalysisOnly() async -> AnalysisResult {
        return await generateStaticAnalysis()
    }

    /**
     * 分析の強制更新（プルリフレッシュ時）
     */
    func refreshAnalysis() async {
        await cacheManager.clearCache()
        await generateAnalysis()
    }

    // MARK: - Private Methods - Analysis Flow

    /**
     * 静的分析を実行
     */
    private func generateStaticAnalysis() async -> AnalysisResult {
        let startTime = Date()

        do {
            // HealthKitデータ取得
            let healthData = try await batteryEngine.getLatestHealthData()

            // 気象データ取得
            let weatherData = await weatherService.getCurrentWeather()

            // 静的分析実行
            let staticAnalysis = staticAnalysisEngine.analyze(
                healthData: healthData,
                weatherData: weatherData
            )

            lastEnergyLevel = staticAnalysis.energyLevel

            let result = AnalysisResult(
                staticAnalysis: staticAnalysis,
                aiAnalysis: nil,
                source: .staticOnly,
                lastUpdated: Date()
            )

            let elapsed = Date().timeIntervalSince(startTime)
            os_log("Static analysis completed in %{public}.3f seconds", log: .default, type: .info, elapsed)

            return result
        } catch {
            // エラー時のフォールバック
            os_log("Static analysis failed: %{public}@", log: .default, type: .error, error.localizedDescription)

            return AnalysisResult(
                staticAnalysis: StaticAnalysis.fallback(),
                aiAnalysis: nil,
                source: .fallback,
                lastUpdated: Date()
            )
        }
    }

    /**
     * AI拡張分析を実行
     */
    private func enhanceWithAI() async {
        guard let currentResult = currentAnalysis else { return }

        await setAnalysisState(analyzing: true, enhancing: true, error: nil)

        do {
            // 開発環境ではキャッシュをスキップして常に新しいAPIリクエストを送信
            #if DEBUG
            let shouldUseCache = false
            #else
            let shouldUseCache = true
            #endif
            
            // キャッシュチェック (本番環境のみ)
            if shouldUseCache, let cachedAI = await cacheManager.getCachedAIAnalysis(for: currentResult) {
                await enhanceWithCachedAI(cachedAI)
                return
            }

            // フレッシュAI分析 (開発環境では常にこちら)
            let aiAnalysis = try await aiAnalysisService.generateAnalysis(from: currentResult)
            await enhanceWithFreshAI(aiAnalysis)

            // キャッシュ保存 (本番環境のみ)
            if shouldUseCache {
                await cacheManager.cacheAIAnalysis(aiAnalysis, for: currentResult)
            }
        } catch {
            os_log("AI enhancement failed: %{public}@", log: .default, type: .error, error.localizedDescription)

            // エラー状態を記録
            await setAnalysisError(AnalysisError.aiServiceUnavailable)

            // 現在の結果をエラーソースとして更新
            if let currentResult = currentAnalysis {
                let errorResult = AnalysisResult(
                    staticAnalysis: currentResult.staticAnalysis,
                    aiAnalysis: nil,
                    source: .aiError,
                    lastUpdated: Date()
                )
                await updateAnalysisResult(errorResult)
            }
        }
    }

    /**
     * キャッシュされたAIで拡張
     */
    private func enhanceWithCachedAI(_ aiAnalysis: AIAnalysisResponse) async {
        guard let currentResult = currentAnalysis else { return }

        let enhancedResult = AnalysisResult(
            staticAnalysis: currentResult.staticAnalysis,
            aiAnalysis: aiAnalysis,
            source: .cached,
            lastUpdated: Date()
        )

        await updateAnalysisResult(enhancedResult)
    }

    /**
     * フレッシュAIで拡張
     */
    private func enhanceWithFreshAI(_ aiAnalysis: AIAnalysisResponse) async {
        guard let currentResult = currentAnalysis else { return }

        let enhancedResult = AnalysisResult(
            staticAnalysis: currentResult.staticAnalysis,
            aiAnalysis: aiAnalysis,
            source: .hybrid,
            lastUpdated: Date()
        )

        await updateAnalysisResult(enhancedResult)
    }

    // MARK: - Private Methods - State Management

    /**
     * 分析状態を更新
     */
    private func setAnalysisState(analyzing: Bool, enhancing: Bool, error: AnalysisError?) async {
        isAnalyzing = analyzing
        isEnhancingWithAI = enhancing
        analysisError = error
    }

    /**
     * 分析結果を更新
     */
    private func updateAnalysisResult(_ result: AnalysisResult) async {
        os_log(
            "🔍 Analysis result updated - source: %{public}@, hasAI: %{public}@",
            log: .default, type: .info,
            result.source.rawValue,
            String(result.aiAnalysis != nil))

        withAnimation(.easeInOut(duration: 0.3)) {
            currentAnalysis = result
        }
    }

    /**
     * エラー状態を設定
     */
    private func setAnalysisError(_ error: AnalysisError) async {
        analysisError = error
    }
}

// MARK: - Supporting Types

/// 分析エラーの定義
enum AnalysisError: Error, LocalizedError {
    case analysisGenerationFailed(Error)
    case healthDataUnavailable
    case weatherDataUnavailable
    case aiServiceUnavailable
    case cacheError(Error)

    var errorDescription: String? {
        switch self {
        case .analysisGenerationFailed(let error):
            return "分析の生成に失敗しました: \(error.localizedDescription)"
        case .healthDataUnavailable:
            return "HealthKitデータが利用できません"
        case .weatherDataUnavailable:
            return "気象データが利用できません"
        case .aiServiceUnavailable:
            return "AI分析サービスが利用できません"
        case .cacheError(let error):
            return "キャッシュエラー: \(error.localizedDescription)"
        }
    }
}
