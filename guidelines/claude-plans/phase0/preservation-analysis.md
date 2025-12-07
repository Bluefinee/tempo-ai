# Phase 0 保持・削除分析レポート

## 📊 既存コードベース分析結果

### ✅ 保持すべき価値ある要素

#### **1. アセット・リソース（絶対保持）**
- `Assets.xcassets/` - アプリアイコン、カラー定義
- `Resources/ja.lproj/`, `Resources/en.lproj/` - 国際化文字列
- `TempoAI.entitlements` - HealthKit等権限設定

#### **2. デザインシステム基盤（部分保持）**
- `DesignSystem/ColorPalette.swift` - カラーパレット定義（価値大）
- `DesignSystem/Typography.swift` - タイポグラフィ設定（価値大）
- `DesignSystem/Spacing.swift` - 間隔設定（価値中）

#### **3. 国際化基盤（保持）**
- `Shared/Localization/LocalizationManager.swift` - 言語切り替え機能

### ❌ 削除対象（技術債務・混乱の原因）

#### **1. Services層（33ファイル - 完全削除）**
技術債務の温床となった複雑なサービス群：
- AI分析関連（13ファイル）: 過度に複雑化
- Health分析関連（15ファイル）: データモデル混乱
- 通知関連（5ファイル）: 未完成統合

#### **2. Models層（9ファイル - 完全削除）**  
重複・不整合の原因：
- `ComprehensiveHealthData.swift` vs `Models.swift` - データ重複
- AI分析モデル群 - 過度に複雑

#### **3. ViewModels層（4ファイル - 完全削除）**
壊れた統合層：
- OnboardingViewModel群 - 200+エラーの原因
- HomeViewModel - 複雑な依存関係

#### **4. Views層（複雑化したUI - 完全削除）**
Phase 2で複雑化したUI群：
- Home/層（5ファイル）- 過度に複雑化
- Onboarding/層（10ファイル）- 統合不良

### 📋 削除実行プラン

#### **段階的削除手順**
1. **Swiftソースファイル群削除** - Services, Models, ViewModels, Views
2. **Core Dataモデル削除** - HealthDataModel.xcdatamodeld  
3. **複雑なコンポーネント削除** - Components/層
4. **基本構造保持** - 必要最小限のSwiftUIアプリ構造

#### **新基盤準備**
1. **基本App.swift作成** - SwiftUIアプリエントリーポイント
2. **ContentView.swift作成** - メインビュー（最小限）
3. **基本Models/作成** - 新仕様に基づくクリーンなモデル設計準備
4. **TDD基盤準備** - テストターゲット準備

## 🎯 Phase 0完了状態

### **クリーンな出発点**
- ✅ 技術債務完全削除
- ✅ 基本的なSwiftUIアプリ動作（Hello World状態）
- ✅ 必要なアセット・リソース保持
- ✅ CI pipeline基本動作
- ✅ 新仕様実装の準備完了

### **Phase 1実装準備**
- 明確な仕様書に基づく実装開始可能
- TDDで安全な開発進行可能
- UX concepts.md原則適用準備完了
- Human Batteryコンセプト実装基盤確立

---

**Status**: Ready for execution  
**Next**: Phase 1 Digital Cockpit基盤実装  
**Philosophy**: 増やすより減らす - Clean start for clean future