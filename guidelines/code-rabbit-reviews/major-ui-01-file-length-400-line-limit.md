# Major Issue: File Length Exceeds 400 Line Limit

## 📍 Location
- **Files**: 
  - `ios/TempoAI/TempoAI/Views/Home/EnhancedAdviceCard.swift` (~420 lines)
  - `ios/TempoAI/TempoAI/Views/Onboarding/PersonalizationPage.swift` (~651 lines)
- **Priority**: 🟠 Major

## ❗ Problem Description

**ファイル長が400行制限を超過**

`.claude/swift-coding-standards.md`の規定により、ファイルは400行以下に制限されています。

> **ファイル長制限**: 400行以下、超過時はコンポーネント抽出要求

## 🔧 Recommended Solutions

### EnhancedAdviceCard.swift (~420 lines)
Preview セクションと大きなサンプルデータが行数の大半を占めているため：

```
- EnhancedAdviceCard.swift：本番コードのみ（400行未満に）
- EnhancedAdviceCard+Preview.swift：#if DEBUG の Preview と sampleAdvice 定義を移動
```

### PersonalizationPage.swift (~651 lines)
以下の分割を推奨：

1. **Models/PersonalizationModels.swift** (~120行)
   - `HealthGoal` enum
   - `ActivityLevel` enum  
   - `HealthInterest` enum

2. **Components/PersonalizationComponents.swift** (~200行)
   - `SectionTitle`
   - `GoalCard`
   - `ActivityLevelCard`
   - `InterestChip`
   - `NotificationTimeCard`
   - `NotificationToggleCard`

3. **PersonalizationPage.swift** (~200行)
   - メインビューのみ

## 🚀 Implementation Steps

### For EnhancedAdviceCard.swift:
1. `EnhancedAdviceCard+Preview.swift`ファイル作成
2. `#if DEBUG` ブロック全体を移動
3. `sampleAdvice`定義を移動
4. インポート文の調整

### For PersonalizationPage.swift:
1. `Models/PersonalizationModels.swift`作成
2. `Components/PersonalizationComponents.swift`作成
3. 各enumとstructを適切に分離
4. インポート文とアクセスレベルの調整

## 🎯 Success Criteria

- [ ] 全てのファイルが400行以下
- [ ] 機能が適切に分離されている
- [ ] ビルドエラーなし
- [ ] Previewが正常動作
- [ ] `.claude/swift-coding-standards.md`に準拠

---

**Code Rabbit Comment ID**: Found in PR #9 review  
**Related Standards**: `.claude/swift-coding-standards.md` - ファイル長制限  
**Effort**: Medium (refactoring and file organization)