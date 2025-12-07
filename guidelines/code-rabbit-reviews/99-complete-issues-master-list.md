# Code Rabbit Review Issues - Complete Master List (99 Issues)

## 📊 Summary Statistics
- 🟠 **Major**: 27件
- 🟡 **Minor**: 19件
- 🔵 **Trivial**: 45件
- ❔ **Unknown**: 8件
- **Total**: 99件

## 🟠 Major Issues (27件) - Critical Priority

### Xcode Project Issues
1. **project.pbxproj:251** - 開発チームIDハードコード問題
2. **project.pbxproj:295** - 開発チームIDハードコード問題（重複箇所）

### File Length Violations
3. **EnhancedAdviceCard.swift:421** - ファイル長400行制限超過
4. **PersonalizationPage.swift:651** - ファイル長400行制限超過（最大）
5. **ValuePropositionPage.swift** - ファイル長制限問題

### Health Data & Models
6. **HealthStatus.swift:346** - 健康データ合成ロジックの重大問題
7. **HealthKitManager.swift** - アーキテクチャ問題
8. **Models.swift** - モデル層設計問題

### UI/UX Critical Issues
9. **ValuePropositionPage.swift:181** - Auto-scroll一時停止ロジックバグ
10. **Typography.swift:94** - ライン間隔計算の不正確な実装

### Test Infrastructure
11-27. **UIテストファイル群** - テスト設計とアサーション改善要

## 🟡 Minor Issues (19件) - Architecture Priority

### API & Backend
1. **APIClient.swift:15** - コメントと実装の不一致
2. **APIClient.swift** - 本番/ローカルバックエンド切り替え

### State Management
3. **ContentView.swift:83** - OnboardingViewModel重複管理
4. **TempoAIApp.swift** - 依存性注入問題

### Permission Handling
5. **HealthKitManager.swift:10** - PermissionStatus.unavailable不正確マッピング
6. **PermissionsView.swift** - パーミッション状態管理

### Design System
7. **Buttons.swift** - cornerRadius適用順序問題
8. **Cards.swift** - カードコンポーネント設計
9. **HealthStatus.swift:239** - HRVカテゴリ色選択問題

### Localization
10. **Localizable.strings** - 文字列リソース問題

### View Architecture
11-19. **各種Viewファイル** - MVVM準拠とアーキテクチャ改善

## 🔵 Trivial Issues (45件) - Code Quality Priority

### Performance Optimizations
1. **Microinteractions.swift:39** - HapticFeedback毎回インスタンス作成
2. **Microinteractions.swift:281** - onChange(of:)非推奨API使用
3. **ColorPalette.swift:132** - Hex初期化子変数シャドーイング

### Code Style & Consistency
4. **Buttons.swift:12** - ButtonStyle enum未使用
5. **Buttons.swift:317** - FloatingActionButtonにisDisabled状態なし
6. **Typography.swift** - フォントサイズマッピング問題

### Model Validation
7. **HealthStatus.swift:205** - HealthMetric初期化時検証不足
8. **Models.swift:2** - モデル層UI依存（SwiftUI import）
9. **Models.swift:335** - DailyAdvice.detailsプレゼンテーション処理

### Test Quality
10-45. **各種テストファイル** - テストカバレッジ、命名規則、アサーション改善

## 🚀 Recommended Fix Order

### Phase 1: Critical Blockers (Major Issues 1-10)
```
Priority: Immediate - Required for basic functionality
Time Estimate: 2-3 days
```

### Phase 2: Architecture Improvements (Minor Issues 1-19)
```
Priority: High - Required for maintainability  
Time Estimate: 1-2 days
```

### Phase 3: Code Quality (Trivial Issues 1-45)
```
Priority: Medium - Code polish and optimization
Time Estimate: 2-3 days
```

### Phase 4: Test Enhancement (Test-related issues)
```
Priority: Low - Can be done incrementally
Time Estimate: 1-2 days
```

## 📝 Individual Issue Files Created

すべての指摘事項の詳細は以下の個別ファイルに記載:

### Major Issues
- `major-xcode-01-development-team-hardcoded.md`
- `major-models-01-health-data-synthesis-logic.md`
- `major-ui-01-file-length-400-line-limit.md`
- `major-ui-02-auto-scroll-interaction-bug.md`

### Minor & Trivial Issues
- 追加のファイルはon-demandで作成可能

## ✅ Success Criteria

- [ ] 全99件の指摘事項が解決済み
- [ ] プロジェクトビルド成功
- [ ] 全テスト通過
- [ ] SwiftLintエラーなし
- [ ] Code Rabbit再レビューで承認

---

*Generated: 2025-12-07*  
*Source: PR #9 Code Rabbit Review*  
*Status: Analysis Complete - Ready for Implementation*