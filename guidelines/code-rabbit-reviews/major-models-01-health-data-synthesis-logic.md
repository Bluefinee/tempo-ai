# Major Issue: Health Data Synthesis Logic

## 📍 Location
- **File**: `ios/TempoAI/TempoAI/Models/HealthStatus.swift`
- **Line**: 346
- **Priority**: 🟠 Major

## ❗ Problem Description

**健康データの合成ロジックに重大な問題あり**

正規化されたスコア（0.0-1.0）から実際の健康指標値を「逆算」していますが、これは以下の深刻な問題を引き起こします：

### 問題点:

1. **マジックナンバーの乱用**: `* 50`, `* 10`, `* 10000`, `60 + * 40` など、根拠不明な変換係数
2. **合成データの誤表示リスク**: ユーザーが実データと誤認する可能性
3. **医療情報の信頼性**: 実際のHealthKitデータと乖離した値を表示
4. **ドキュメント欠如**: これらが近似値である旨の説明なし

### 具体例:
```swift
// Line 312: HRV 0-50ms (実際は20-200ms が一般的)
value: String(format: "%.1f ms", hrvScore * 50)

// Line 339: 心拍数 60-100bpm (範囲は妥当だが係数が恣意的)
value: String(format: "%.0f bpm", 60 + heartRateScore * 40)
```

## 🔧 Recommended Solutions

### 1. 実データの使用
可能な限り、HealthKitから取得した実際の値を使用

### 2. 明示的な近似値表示
合成値の場合は「推定値」と明記

### 3. 定数の抽出と文書化
```swift
// Constants for metric value approximation
private enum MetricValueConstants {
    /// Approximate HRV range for display (ms)
    /// Note: These are estimated values for backward compatibility only
    static let hrvMultiplier: Double = 50.0
    static let hrvNote = "Estimated" // Add to display
    
    static let sleepMultiplier: Double = 10.0
    static let activityMultiplier: Double = 10000.0
    static let heartRateBase: Double = 60.0
    static let heartRateRange: Double = 40.0
}
```

### 4. 代替案: パーセンテージ表示
```swift
value: String(format: "%.0f%%", hrvScore * 100)
```

## 🚀 Implementation Steps

1. MetricValueConstants enumを定義
2. マジックナンバーを定数に置換
3. 合成値であることを明示するUI表示追加
4. 実データ取得への移行計画策定

## 🎯 Success Criteria

- [ ] マジックナンバーが全て定数化されている
- [ ] ユーザーが推定値であることを理解できる
- [ ] `.claude/swift-coding-standards.md`に準拠
- [ ] 医療データの適切な取り扱いが実装されている

---

**Code Rabbit Comment ID**: Found in PR #9 review  
**Related Standards**: `.claude/swift-coding-standards.md` - マジックナンバー禁止  
**Effort**: High (health data handling requires careful consideration)