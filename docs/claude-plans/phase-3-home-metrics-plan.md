# Phase 3: ホーム画面UI（メトリクス・トライ）実装計画

**ブランチ**: `feature/phase-3-home-metrics`
**参照ドキュメント**: `docs/phases/03-phase-home-metrics.md`
**作成日**: 2025-12-11

---

## 概要

Phase 2で実装されたホーム画面基本構造を拡張し、以下のコンポーネントを追加する：
1. メトリクスカード4つ（回復・睡眠・エネルギー・ストレス）- 2×2グリッド
2. 今日のトライカード
3. 今週のトライカード（月曜日は目立つ表示、他の曜日はコンパクト）
4. 追加アドバイス（フローティング吹き出し）

---

## 完了条件

- [ ] メトリクスカード4つが2×2グリッドで表示される
- [ ] 各メトリクスカードに数値とプログレスバーが表示される
- [ ] 今日のトライカードにタイトルとサマリーが表示される
- [ ] 今週のトライカードが表示される（月曜とそれ以外で表示が異なる）
- [ ] 追加アドバイスの吹き出しが表示・非表示できる
- [ ] 全要素がMockデータで正しく表示される
- [ ] swiftlint / swift-format でエラーなし
- [ ] テストカバレッジ70-80%以上

---

## 実装ステージ

### Stage 1: MetricDataモデルの作成（テスト駆動）

**Goal**: メトリクスカード用のデータモデルを定義

**ファイル**:
- `ios/TempoAI/TempoAITests/MetricDataModelTests.swift` (新規 - テスト先行)
- `ios/TempoAI/TempoAI/Shared/Models/MetricData.swift` (新規)
- `ios/TempoAI/TempoAI/Shared/Models/MockData.swift` (修正)

**テストケース**:
1. MetricDataのCodableエンコード/デコード
2. MetricTypeの各ケースのプロパティ（icon, label）
3. スコアに基づくstatus計算
4. スコアに基づくprogressBarColor計算
5. Mockデータの整合性

**実装内容**:
```swift
struct MetricData: Codable, Identifiable {
    let id: UUID
    let type: MetricType
    let score: Int           // 0-100
    let displayValue: String // "78" or "7.0h" or "低"
}

enum MetricType: String, Codable, CaseIterable {
    case recovery, sleep, energy, stress

    var icon: String { ... }      // "💚", "😴", "⚡", "🧘"
    var label: String { ... }     // "回復", "睡眠", "エネルギー", "ストレス"
}

extension MetricData {
    var status: String { ... }           // スコアベース: "最高", "良好", "普通", "やや低め", "注意"
    var progressBarColor: Color { ... }  // スコアベース色分け
}
```

---

### Stage 2: MetricCardとMetricsGridViewの実装（テスト駆動）

**Goal**: 個別メトリクスカードと2×2グリッドコンテナを作成

**ファイル**:
- `ios/TempoAI/TempoAITests/HomeComponentsTests.swift` (修正 - テスト追加)
- `ios/TempoAI/TempoAI/Features/Home/Views/MetricCard.swift` (新規)
- `ios/TempoAI/TempoAI/Features/Home/Views/MetricsGridView.swift` (新規)

**テストケース**:
1. MetricCardの生成テスト
2. MetricsGridViewの生成テスト
3. 4つのメトリクスが正しく渡されるか

**MetricCard構成**:
```
┌─────────────────┐
│ 💚 回復         │ ← アイコン + ラベル
│ 良好            │ ← 状態テキスト
│ ████████░░ 78%  │ ← プログレスバー + 数値
└─────────────────┘
```

**デザイン仕様**:
- 背景: `Color.white`
- 角丸: `16pt`
- シャドウ: `color: black.opacity(0.08), radius: 8, x: 0, y: 2`
- パディング: `16pt`
- プログレスバー背景: `tempoLightGray.opacity(0.3)`
- プログレスバー色（スコア別）:
  - 80-100%: `tempoSuccess` (緑)
  - 60-79%: `tempoSageGreen` (セージグリーン)
  - 40-59%: `tempoWarning` (黄色/オレンジ)
  - 0-39%: `tempoSoftCoral` (コーラル)

---

### Stage 3: DailyTryCardの実装（テスト駆動）

**Goal**: 今日のトライカードを作成

**ファイル**:
- `ios/TempoAI/TempoAITests/HomeComponentsTests.swift` (修正 - テスト追加)
- `ios/TempoAI/TempoAI/Features/Home/Views/DailyTryCard.swift` (新規)

**テストケース**:
1. DailyTryCardの生成テスト
2. TryContentデータが正しく表示されるか

**カード構成**:
```
┌─────────────────────────────────────┐
│ 🎯 今日のトライ                     │
│ ドロップセット法に挑戦              │ ← タイトル
│ トレーニングの最後に...             │ ← サマリー
│                    [詳しく見る →]   │
└─────────────────────────────────────┘
```

**データソース**: `DailyAdvice.dailyTry: TryContent` (既存モデル使用)

---

### Stage 4: WeeklyTryCardの実装（テスト駆動）

**Goal**: 今週のトライカードを曜日に応じた表示で作成

**ファイル**:
- `ios/TempoAI/TempoAITests/HomeComponentsTests.swift` (修正 - テスト追加)
- `ios/TempoAI/TempoAI/Features/Home/Views/WeeklyTryCard.swift` (新規)

**テストケース**:
1. WeeklyTryCardの生成テスト（月曜日モード）
2. WeeklyTryCardの生成テスト（コンパクトモード）
3. 月曜日判定ロジック

**月曜日の表示**:
```
┌─────────────────────────────────────┐
│ 📅 今週のトライ               NEW!  │
│ セサミオイルで足裏マッサージ        │
│ アーユルヴェーダの知恵で...         │
│                    [詳しく見る →]   │
└─────────────────────────────────────┘
```

**火〜日曜の表示**:
```
┌─────────────────────────────────────┐
│ 📅 今週のトライ: セサミオイルで...  │
└─────────────────────────────────────┘
```

---

### Stage 5: AdditionalAdvicePopupの実装（テスト駆動）

**Goal**: フローティング吹き出しUIを作成

**ファイル**:
- `ios/TempoAI/TempoAITests/HomeComponentsTests.swift` (修正 - テスト追加)
- `ios/TempoAI/TempoAI/Features/Home/Views/AdditionalAdvicePopup.swift` (新規)

**テストケース**:
1. AdditionalAdvicePopupの生成テスト
2. AdditionalAdviceデータが正しく表示されるか

**UI構成**:
```
┌─────────────────────────────────────┐
│ 💬                           [×]   │
│ 午前中の心拍数が普段より10%ほど     │
│ 高めで推移していました...           │
└─────────────────────────────────────┘
```

**インタラクション**:
- ×ボタンで閉じる
- `@Binding var isVisible: Bool` で表示制御

---

### Stage 6: HomeViewの統合

**Goal**: 全コンポーネントをHomeViewに統合

**ファイル**:
- `ios/TempoAI/TempoAI/Features/Home/Views/HomeView.swift` (修正)

**変更内容**:
1. Phase 3プレースホルダーを削除
2. 以下の順序でコンポーネントを配置:
   - AdviceSummaryCard (既存)
   - MetricsGridView (新規)
   - DailyTryCard (新規)
   - WeeklyTryCard (新規)
3. AdditionalAdvicePopupをZStackで最前面に配置
4. Mockデータの状態管理を追加

---

### Stage 7: 品質チェック

**Goal**: コード品質とテストカバレッジの確認

**実行コマンド**:
```bash
# リント
swiftlint

# フォーマット確認
swift-format lint --recursive ios/

# テスト実行
swift test

# ビルド確認
xcodebuild -project ios/TempoAI/TempoAI.xcodeproj \
  -scheme TempoAI \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

---

## 影響ファイル一覧

### 新規作成
| ファイル | 説明 |
|---------|------|
| `ios/TempoAI/TempoAI/Shared/Models/MetricData.swift` | メトリクスデータモデル |
| `ios/TempoAI/TempoAI/Features/Home/Views/MetricCard.swift` | 個別メトリクスカード |
| `ios/TempoAI/TempoAI/Features/Home/Views/MetricsGridView.swift` | 2×2グリッドコンテナ |
| `ios/TempoAI/TempoAI/Features/Home/Views/DailyTryCard.swift` | 今日のトライカード |
| `ios/TempoAI/TempoAI/Features/Home/Views/WeeklyTryCard.swift` | 今週のトライカード |
| `ios/TempoAI/TempoAI/Features/Home/Views/AdditionalAdvicePopup.swift` | 追加アドバイス吹き出し |
| `ios/TempoAI/TempoAITests/MetricDataModelTests.swift` | モデルテスト |

### 修正
| ファイル | 変更内容 |
|---------|---------|
| `ios/TempoAI/TempoAI/Shared/Models/MockData.swift` | Mockメトリクス・追加アドバイス追加 |
| `ios/TempoAI/TempoAI/Features/Home/Views/HomeView.swift` | 新コンポーネント統合 |
| `ios/TempoAI/TempoAITests/HomeComponentsTests.swift` | 新コンポーネントテスト追加 |

---

## 技術的考慮事項

1. **既存モデルの活用**: `TryContent`と`AdditionalAdvice`は`DailyAdvice.swift`に既存
2. **デザインシステム**: `Color+Extensions.swift`の既存カラーを使用
3. **400行制限**: 各Viewファイルは400行以内に収める
4. **明示的型宣言**: Swift coding standardsに従う
5. **Previewサポート**: 各コンポーネントに`#Preview`を追加
6. **テスト駆動**: 各Stageでテストを先に書く
