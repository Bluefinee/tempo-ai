/**
 * @fileoverview Focus Area Specialists
 *
 * 6つの関心分野（work, beauty, diet, sleep, fitness, chill）ごとの
 * 専門AI分析と「今日のトライ」提案システム。
 * 各分野の専門知識とユーザーの現在状況を組み合わせた
 * パーソナライズされた提案を生成します。
 */

import Foundation
import SwiftUI

/**
 * フォーカスエリア専門分析エンジン
 * 各関心分野の専門的観点からの分析と提案
 */
class FocusAreaSpecialists {
    
    // MARK: - Today's Try Generation
    
    /**
     * 関心分野別の「今日のトライ」を生成
     */
    static func generateTodaysTry(
        for focusAreas: Set<FocusTag>,
        energyLevel: Double,
        environmentalContext: EnvironmentalContext,
        timeOfDay: TimeOfDay,
        userMode: UserMode
    ) -> [TodaysTryAdvice] {
        var tryAdvices: [TodaysTryAdvice] = []
        
        // シングルフォーカス分析
        for focusArea in focusAreas {
            let advice = generateSingleFocusAdvice(
                focusArea: focusArea,
                energyLevel: energyLevel,
                environmentalContext: environmentalContext,
                timeOfDay: timeOfDay,
                userMode: userMode
            )
            tryAdvices.append(advice)
        }
        
        // マルチフォーカスシナジー分析
        if focusAreas.count > 1 {
            let synergyAdvice = generateMultiFocusSynergy(
                focusAreas: focusAreas,
                energyLevel: energyLevel,
                timeOfDay: timeOfDay
            )
            tryAdvices.append(contentsOf: synergyAdvice)
        }
        
        return tryAdvices.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    // MARK: - Single Focus Area Analysis
    
    /**
     * 単一関心分野の専門分析
     */
    private static func generateSingleFocusAdvice(
        focusArea: FocusTag,
        energyLevel: Double,
        environmentalContext: EnvironmentalContext,
        timeOfDay: TimeOfDay,
        userMode: UserMode
    ) -> TodaysTryAdvice {
        switch focusArea {
        case .work:
            return generateWorkAdvice(energyLevel: energyLevel, environmentalContext: environmentalContext, timeOfDay: timeOfDay)
        case .beauty:
            return generateBeautyAdvice(energyLevel: energyLevel, environmentalContext: environmentalContext, timeOfDay: timeOfDay)
        case .diet:
            return generateDietAdvice(energyLevel: energyLevel, environmentalContext: environmentalContext, timeOfDay: timeOfDay)
        case .sleep:
            return generateSleepAdvice(energyLevel: energyLevel, environmentalContext: environmentalContext, timeOfDay: timeOfDay)
        case .fitness:
            return generateFitnessAdvice(energyLevel: energyLevel, environmentalContext: environmentalContext, timeOfDay: timeOfDay, userMode: userMode)
        case .chill:
            return generateChillAdvice(energyLevel: energyLevel, environmentalContext: environmentalContext, timeOfDay: timeOfDay)
        }
    }
    
    // MARK: - Work Specialist
    
    private static func generateWorkAdvice(
        energyLevel: Double,
        environmentalContext: EnvironmentalContext,
        timeOfDay: TimeOfDay
    ) -> TodaysTryAdvice {
        if energyLevel > 70 && timeOfDay == .morning {
            return TodaysTryAdvice(
                focusArea: .work,
                title: "集中力の黄金時間",
                description: "今朝の集中力が優秀です。重要なタスクを今のうちに済ませませんか？",
                actionSuggestion: "25分間のポモドーロテクニックで深い集中を体験してみましょう",
                estimatedTime: "25分",
                difficulty: .easy,
                priority: .high
            )
        } else if environmentalContext.pressureTrend < -3 {
            return TodaysTryAdvice(
                focusArea: .work,
                title: "気圧低下による集中力対策",
                description: "気圧が下がっているため、集中力が下がりやすい状況です",
                actionSuggestion: "複雑な作業は避けて、簡単なタスクの整理から始めませんか？",
                estimatedTime: "10分",
                difficulty: .easy,
                priority: .medium
            )
        } else {
            return TodaysTryAdvice(
                focusArea: .work,
                title: "効率的な作業リズム",
                description: "今日は安定したペースで作業ができそうです",
                actionSuggestion: "50分作業 + 10分休憩のリズムで、持続可能な集中を試してみましょう",
                estimatedTime: "60分",
                difficulty: .medium,
                priority: .medium
            )
        }
    }
    
    // MARK: - Beauty Specialist
    
    private static func generateBeautyAdvice(
        energyLevel: Double,
        environmentalContext: EnvironmentalContext,
        timeOfDay: TimeOfDay
    ) -> TodaysTryAdvice {
        if environmentalContext.humidity < 40 {
            return TodaysTryAdvice(
                focusArea: .beauty,
                title: "乾燥対策の緊急ケア",
                description: "湿度\(Int(environmentalContext.humidity))%と低めです。お肌のために特別ケアを",
                actionSuggestion: "温かいカモミールティーで内側からの水分補給をしませんか？リラックス効果もあります",
                estimatedTime: "5分",
                difficulty: .easy,
                priority: .high
            )
        } else if timeOfDay == .evening && energyLevel > 50 {
            return TodaysTryAdvice(
                focusArea: .beauty,
                title: "夜の美容ゴールデンタイム",
                description: "今夜はスペシャルケアに最適なコンディションです",
                actionSuggestion: "温めたセサミオイルで顔を優しくマッサージして、明日の肌の輝きを準備しませんか？",
                estimatedTime: "10分",
                difficulty: .medium,
                priority: .medium
            )
        } else {
            return TodaysTryAdvice(
                focusArea: .beauty,
                title: "基本ケアの継続",
                description: "お肌の状態を維持しましょう",
                actionSuggestion: "コップ一杯の水で、内側からの美容ケアを続けましょう",
                estimatedTime: "1分",
                difficulty: .easy,
                priority: .low
            )
        }
    }
    
    // MARK: - Diet Specialist
    
    private static func generateDietAdvice(
        energyLevel: Double,
        environmentalContext: EnvironmentalContext,
        timeOfDay: TimeOfDay
    ) -> TodaysTryAdvice {
        if timeOfDay == .afternoon && energyLevel < 60 {
            return TodaysTryAdvice(
                focusArea: .diet,
                title: "午後のエネルギー補給",
                description: "活動量からみて、栄養補給のタイミングです",
                actionSuggestion: "ランチにナッツを小皿一杯追加してみませんか？良質な脂質が脳の機能をサポートします",
                estimatedTime: "3分",
                difficulty: .easy,
                priority: .medium
            )
        } else if timeOfDay == .morning {
            return TodaysTryAdvice(
                focusArea: .diet,
                title: "色彩豊かな朝食",
                description: "新しい一日のスタートにふさわしい朝食を",
                actionSuggestion: "赤（トマト）、緑（ほうれん草）、黄（パプリカ）の野菜を組み合わせて、カラフルな朝食を試してみませんか？",
                estimatedTime: "15分",
                difficulty: .medium,
                priority: .medium
            )
        } else {
            return TodaysTryAdvice(
                focusArea: .diet,
                title: "バランス維持",
                description: "今の食事リズムを継続しましょう",
                actionSuggestion: "次の食事まで水分補給を意識してみてください",
                estimatedTime: "継続",
                difficulty: .easy,
                priority: .low
            )
        }
    }
    
    // MARK: - Sleep Specialist
    
    private static func generateSleepAdvice(
        energyLevel: Double,
        environmentalContext: EnvironmentalContext,
        timeOfDay: TimeOfDay
    ) -> TodaysTryAdvice {
        if timeOfDay == .evening && energyLevel < 40 {
            return TodaysTryAdvice(
                focusArea: .sleep,
                title: "深い眠りの準備",
                description: "疲れが溜まっているようです。今夜は質の高い睡眠で回復を",
                actionSuggestion: "入眠1時間前にカモミールティーを飲んで、自然な眠気を誘ってみませんか？",
                estimatedTime: "5分",
                difficulty: .easy,
                priority: .high
            )
        } else if timeOfDay == .night {
            return TodaysTryAdvice(
                focusArea: .sleep,
                title: "睡眠前リチュアル",
                description: "リラックスした入眠のための準備時間です",
                actionSuggestion: "ラベンダーオイルで手首を優しくマッサージし、好きな本を数ページ読む時間を作ってみませんか？",
                estimatedTime: "15分",
                difficulty: .medium,
                priority: .medium
            )
        } else {
            return TodaysTryAdvice(
                focusArea: .sleep,
                title: "睡眠リズム維持",
                description: "良い睡眠習慣を継続しましょう",
                actionSuggestion: "今日も一定のリズムで過ごして、夜の良い睡眠に備えましょう",
                estimatedTime: "継続",
                difficulty: .easy,
                priority: .low
            )
        }
    }
    
    // MARK: - Fitness Specialist
    
    private static func generateFitnessAdvice(
        energyLevel: Double,
        environmentalContext: EnvironmentalContext,
        timeOfDay: TimeOfDay,
        userMode: UserMode
    ) -> TodaysTryAdvice {
        if energyLevel > 70 && environmentalContext.feelsLike > 15 && environmentalContext.feelsLike < 25 {
            return TodaysTryAdvice(
                focusArea: .fitness,
                title: "理想的運動条件",
                description: "エネルギー豊富、気温\(Int(environmentalContext.feelsLike))℃で運動に最適です",
                actionSuggestion: userMode == .athlete ? 
                    "今日は高強度トレーニングに挑戦する絶好のタイミングです" :
                    "普段より5分長いウォーキングにチャレンジしませんか？体が求めている刺激を与えてあげましょう",
                estimatedTime: userMode == .athlete ? "45分" : "20分",
                difficulty: userMode == .athlete ? .hard : .medium,
                priority: .high
            )
        } else if timeOfDay == .morning {
            return TodaysTryAdvice(
                focusArea: .fitness,
                title: "モーニングストレッチ",
                description: "新しい一日の活性化を始めましょう",
                actionSuggestion: "起床後5分間、太陽の光を浴びながら全身をゆっくりと伸ばしてみませんか？",
                estimatedTime: "5分",
                difficulty: .easy,
                priority: .medium
            )
        } else {
            return TodaysTryAdvice(
                focusArea: .fitness,
                title: "軽い活動維持",
                description: "現在のペースを維持しましょう",
                actionSuggestion: "階段を使う、少し遠回りするなど、日常に小さな運動を取り入れてみてください",
                estimatedTime: "随時",
                difficulty: .easy,
                priority: .low
            )
        }
    }
    
    // MARK: - Chill Specialist
    
    private static func generateChillAdvice(
        energyLevel: Double,
        environmentalContext: EnvironmentalContext,
        timeOfDay: TimeOfDay
    ) -> TodaysTryAdvice {
        if environmentalContext.pressureTrend < -3 {
            return TodaysTryAdvice(
                focusArea: .chill,
                title: "気圧低下への対処",
                description: "気圧が下がっていて、体が重く感じるかもしれません",
                actionSuggestion: "温かいジンジャーティーで体を内側から温めて、気圧変化に負けない体作りをしませんか？",
                estimatedTime: "5分",
                difficulty: .easy,
                priority: .high
            )
        } else if energyLevel < 30 {
            return TodaysTryAdvice(
                focusArea: .chill,
                title: "深いリラクゼーション",
                description: "エネルギーが不足しています。積極的な回復が必要です",
                actionSuggestion: "温めたセサミオイルで足裏を優しくマッサージして、深い眠りへの準備をしませんか？",
                estimatedTime: "10分",
                difficulty: .easy,
                priority: .high
            )
        } else {
            return TodaysTryAdvice(
                focusArea: .chill,
                title: "心の平静維持",
                description: "リラックスした状態を保ちましょう",
                actionSuggestion: "3回の深呼吸で、心をリセットしてみませんか？",
                estimatedTime: "1分",
                difficulty: .easy,
                priority: .medium
            )
        }
    }
    
    // MARK: - Multi-Focus Synergy
    
    /**
     * 複数関心分野の組み合わせシナジー分析
     */
    private static func generateMultiFocusSynergy(
        focusAreas: Set<FocusTag>,
        energyLevel: Double,
        timeOfDay: TimeOfDay
    ) -> [TodaysTryAdvice] {
        var synergyAdvices: [TodaysTryAdvice] = []
        
        // Sleep × Beauty シナジー
        if focusAreas.contains(.sleep) && focusAreas.contains(.beauty) {
            synergyAdvices.append(TodaysTryAdvice(
                focusArea: .beauty,
                title: "美容睡眠の黄金時間",
                description: "睡眠と美容の相乗効果を最大化しましょう",
                actionSuggestion: "22時からのナイトルーチンで、美肌と深い睡眠を同時に手に入れませんか？",
                estimatedTime: "30分",
                difficulty: .medium,
                priority: .high
            ))
        }
        
        // Work × Fitness シナジー
        if focusAreas.contains(.work) && focusAreas.contains(.fitness) {
            synergyAdvices.append(TodaysTryAdvice(
                focusArea: .work,
                title: "アクティブワーク",
                description: "脳と体の両方を活性化する時間です",
                actionSuggestion: "15分の散歩ミーティング（電話会議）で、運動と仕事を同時に効率化しませんか？",
                estimatedTime: "15分",
                difficulty: .medium,
                priority: .medium
            ))
        }
        
        // Diet × Fitness シナジー
        if focusAreas.contains(.diet) && focusAreas.contains(.fitness) {
            synergyAdvices.append(TodaysTryAdvice(
                focusArea: .diet,
                title: "運動前後の栄養戦略",
                description: "食事と運動のタイミングを最適化しましょう",
                actionSuggestion: "運動前にバナナ半分、運動後にプロテインドリンクの組み合わせを試してみませんか？",
                estimatedTime: "5分",
                difficulty: .easy,
                priority: .medium
            ))
        }
        
        return synergyAdvices
    }
}

// MARK: - Supporting Types

/**
 * 今日のトライアドバイス
 */
struct TodaysTryAdvice: Identifiable {
    let id: UUID = UUID()
    let focusArea: FocusTag
    let title: String
    let description: String
    let actionSuggestion: String
    let estimatedTime: String
    let difficulty: Difficulty
    let priority: TryPriority
}

/**
 * トライの優先度
 */
enum TryPriority: Int, CaseIterable {
    case high = 3
    case medium = 2
    case low = 1
    
    var color: Color {
        switch self {
        case .high: return ColorPalette.primaryAccent
        case .medium: return ColorPalette.warmAccent
        case .low: return ColorPalette.secondaryAccent
        }
    }
    
    var badgeText: String {
        switch self {
        case .high: return "今すぐ"
        case .medium: return "おすすめ"
        case .low: return "参考"
        }
    }
}

/**
 * 環境要因ベースの智恵生成器
 */
class EnvironmentalWisdomGenerator {
    
    /**
     * 環境要因と体調の関連性を解説
     */
    static func generateEnvironmentalInsight(
        environmentalContext: EnvironmentalContext,
        energyLevel: Double
    ) -> String? {
        // 気圧と頭痛の関連
        if environmentalContext.pressureTrend < -5 {
            return "頭痛や体のだるさは、気圧が\(abs(Int(environmentalContext.pressureTrend)))hPa下がったことが原因かもしれません。あなたの体調管理が悪いわけではありません。"
        }
        
        // 湿度と肌トラブルの関連
        if environmentalContext.humidity < 30 {
            return "肌の調子が気になりますか？湿度\(Int(environmentalContext.humidity))%と低く、お肌が乾燥しやすい状況です。スキンケアを変える前に、環境要因を考慮してみてください。"
        }
        
        // 高温と疲労感の関連
        if environmentalContext.feelsLike > 28 {
            return "今日疲れやすく感じるのは、体感温度\(Int(environmentalContext.feelsLike))℃の暑さで体が体温調節にエネルギーを使っているからです。"
        }
        
        return nil
    }
}