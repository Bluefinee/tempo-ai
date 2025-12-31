# Phase 12.5: サーカディアンリズム画面リニューアル 実装計画

**作成日**: 2025 年 12 月 31 日
**ブランチ名**: `feature/phase-12.5-circadian-renewal`

---

## 概要

Phase 12 で実装したサーカディアンリズム画面を新デザインにリニューアルします。

### 主な変更点

| 変更前（Phase 12）            | 変更後（Phase 12.5）       |
| ----------------------------- | -------------------------- |
| 三角形構成（HRV・睡眠・歩数） | フラットな指標リスト       |
| 24h サークル + ゾーン色分け   | 24h サークル（Solar Sync） |
| リズム安定度セクション        | 削除                       |
| 3 指標                        | 5 指標（+日光浴、+体温）   |
| ロジック分散                  | ドメインモデルに凝集       |

---

## 完了条件

### UI

- [ ] 24h サークル（Solar Sync）が正しく描画される
- [ ] 外周に太陽の動き（日の出・日の入り）を表示
- [ ] 内周に体内時計（体温リズム）を表示
- [ ] 現在地マーカーが毎分更新される
- [ ] ズレ警告が該当時に表示される
- [ ] 5 つの指標がフラットリストで表示される
- [ ] 各指標に 5 段階ゲージ + コメント
- [ ] insight が表示される

### データ取得

- [ ] 日光浴データ（timeInDaylight）を取得できる
- [ ] 体温データ（appleSleepingWristTemperature）を取得できる（対応機種のみ）
- [ ] 非対応機種で体温が非表示になる

### アーキテクチャ

- [ ] スコア算出ロジックがドメインモデルに凝集されている
- [ ] View 層にスコア算出ロジックがない
- [ ] Service 層はデータ取得のみ

### 削除

- [ ] 三角形構成のコードが削除されている
- [ ] 集中/休憩ゾーンのコードが削除されている
- [ ] リズム安定度セクションのコードが削除されている

---

## Stage 1: ドメインモデルの作成

### 新規ファイル

| ファイル                                | 内容             |
| --------------------------------------- | ---------------- |
| `Domain/Models/HRVMetric.swift`         | HRV スコア算出   |
| `Domain/Models/SleepMetric.swift`       | 睡眠スコア算出   |
| `Domain/Models/StepsMetric.swift`       | 歩数スコア算出   |
| `Domain/Models/DaylightMetric.swift`    | 日光浴スコア算出 |
| `Domain/Models/TemperatureMetric.swift` | 体温位相判定     |
| `Domain/Models/RhythmMetrics.swift`     | 統合モデル       |

### 実装内容

[metrics-spec.md](../specs/metrics-spec.md)のセクション 3-8 に記載されたロジックをそのまま実装。

---

## Stage 2: HealthKitManager 拡張

### 追加メソッド

```swift
// 日光浴時間の取得
func fetchTimeInDaylight(for date: Date) async throws -> (total: Int, morning: Int)

// 手首皮膚温の取得（対応機種のみ）
func fetchWristTemperature() async throws -> TemperatureMetric?

// 機種が皮膚温に対応しているか確認
func isWristTemperatureAvailable() -> Bool

// 全指標を一括取得
func fetchRhythmMetrics(for date: Date) async throws -> RhythmMetrics
```

---

## Stage 3: 既存コードの削除

### 削除対象

| ファイル/コンポーネント         | 理由                 |
| ------------------------------- | -------------------- |
| 三角形ビュー関連                | 新デザインで不要     |
| 集中/休憩ゾーン描画             | 新デザインで不要     |
| リズム安定度セクション          | 新デザインで不要     |
| 旧スコア算出ロジック（View 内） | ドメインモデルに移行 |

---

## Stage 4: 24h サークル（Solar Sync）の実装

### 新規ファイル

| ファイル                                                   | 内容             |
| ---------------------------------------------------------- | ---------------- |
| `Features/CircadianRhythm/Views/SolarSyncCircleView.swift` | 24h サークル本体 |

### 仕様

- 外周リング: 太陽の動き
  - 日の出時刻〜日の入り時刻: Primary 色 0.3 透明度
  - それ以外: Gray 0.2 透明度
- 内周リング: 体内時計（体温データがある場合のみ）
- 現在地マーカー: SF Symbol、Timer 使用で毎分更新
- 中央: 状態メッセージ
- ズレ警告: 1 時間以上のズレがある場合に下部に表示

---

## Stage 5: 指標リストの実装

### 新規ファイル

| ファイル                                                   | 内容         |
| ---------------------------------------------------------- | ------------ |
| `Features/CircadianRhythm/Views/RhythmMetricRowView.swift` | 各指標の行   |
| `Shared/Components/FiveStageGaugeView.swift`               | 5 段階ゲージ |

### RhythmMetricRowView の仕様

```swift
struct RhythmMetricRowView: View {
    let icon: String            // SF Symbol名
    let title: String           // "HRV", "睡眠" など
    let value: String           // "72ms", "7.2h" など
    let subValue: String?       // "▲+9%" など（オプション）
    let gaugeLevel: Int         // 1-5
    let comment: String         // コメント
    let showWarning: Bool       // 警告アイコン表示
}
```

---

## Stage 6: CircadianRhythmView の更新

### 変更内容

既存の CircadianRhythmView を更新:

1. 三角形セクションを削除
2. SolarSyncCircleView を配置
3. RhythmMetricRowView で指標リストを表示
4. insight セクションを維持
5. ViewModel で RhythmMetrics を保持

---

## Stage 7: テスト

### ユニットテスト

| テスト                 | 内容                       |
| ---------------------- | -------------------------- |
| HRVMetricTests         | スコア算出、コメント生成   |
| SleepMetricTests       | スコア算出、フォールバック |
| StepsMetricTests       | スコア算出                 |
| DaylightMetricTests    | スコア算出、警告判定       |
| TemperatureMetricTests | 位相判定、表示条件         |

### 動作確認

- [ ] シミュレーターで全指標が表示される
- [ ] 皮膚温非対応機種で体温が非表示になる
- [ ] 日光浴データがない場合の表示
- [ ] 現在地マーカーの更新確認
- [ ] 各スコアが正しく算出される

---

## 依存関係

```
Stage 1 (ドメインモデル)
    ↓
Stage 2 (HealthKit拡張)
    ↓
Stage 3 (既存コード削除)
    ↓
Stage 4 (サークル実装)
    ↓
Stage 5 (指標リスト実装)
    ↓
Stage 6 (画面統合)
    ↓
Stage 7 (テスト)
```

---

## 主要ファイルパス

### 新規作成

- `/ios/TempoAI/TempoAI/Domain/Models/RhythmMetrics.swift`
- `/ios/TempoAI/TempoAI/Domain/Models/HRVMetric.swift`
- `/ios/TempoAI/TempoAI/Domain/Models/SleepMetric.swift`
- `/ios/TempoAI/TempoAI/Domain/Models/StepsMetric.swift`
- `/ios/TempoAI/TempoAI/Domain/Models/DaylightMetric.swift`
- `/ios/TempoAI/TempoAI/Domain/Models/TemperatureMetric.swift`
- `/ios/TempoAI/TempoAI/Features/CircadianRhythm/Views/SolarSyncCircleView.swift`
- `/ios/TempoAI/TempoAI/Features/CircadianRhythm/Views/RhythmMetricRowView.swift`
- `/ios/TempoAI/TempoAI/Shared/Components/FiveStageGaugeView.swift`

### 更新

- `/ios/TempoAI/TempoAI/Features/CircadianRhythm/Views/CircadianRhythmView.swift`
- `/ios/TempoAI/TempoAI/Services/HealthKitManager.swift`

### 削除対象（Stage 3 で確認）

- 三角形関連の View ファイル
- ゾーン色分け関連のコード
- リズム安定度関連のコード

---

## 関連ドキュメント

| ドキュメント                                | 内容            |
| ------------------------------------------- | --------------- |
| [ui-spec.md](../specs/ui-spec.md)           | UI デザイン仕様 |
| [product-spec.md](../specs/product-spec.md) | プロダクト仕様  |
| [metrics-spec.md](../specs/metrics-spec.md) | スコア算出仕様  |
