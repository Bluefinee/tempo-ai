# Phase 3: スコア計算エンジン

## 概要
4つのスコア（Autonomic, Sleep, Rhythm, Activity）の計算エンジンをTDDで実装。

## 参照ドキュメント
- [x] `docs/specs/tempoai_metrics_spec.md` - スコア算出アルゴリズム
- [x] `.claude/swift-coding-standards.md` - Swift開発規約

## ゴール
- [x] Autonomic Score 計算（HRVベースライン比較 + 補正）
- [x] Sleep Score 計算（3要素の重み付け）
- [x] Rhythm Score 計算（4要素 + 機器対応重み再配分）
- [x] Activity Score 計算（歩数 + 運動時間）
- [x] ScoreCalculator ファサード（全スコア統合）

## 成功基準
- [x] 全スコア計算テストパス
- [x] `tempoai_metrics_spec.md` のアルゴリズムと完全一致
- [x] エッジケース（データ不足、異常値）を適切にハンドリング
- [x] Xcode ⌘+U 全テストパス

---

## 実装ファイル

### Domain/Services/（新規作成）

| ファイル | 説明 |
|---------|------|
| `AutonomicScoreCalculator.swift` | HRVベースライン比較 + 睡眠補正 |
| `SleepScoreCalculator.swift` | 睡眠時間45% + 深い睡眠35% + レム睡眠20% |
| `RhythmScoreCalculator.swift` | 時刻一貫性 + 体温 + ステージ移行 |
| `ActivityScoreCalculator.swift` | 歩数60% + 運動時間40% |
| `ScoreCalculator.swift` | 全スコア統合ファサード |

### テストファイル

| ファイル | テスト数 |
|---------|---------|
| `AutonomicScoreCalculatorTests.swift` | 13 |
| `SleepScoreCalculatorTests.swift` | 17 |
| `RhythmScoreCalculatorTests.swift` | 13 |
| `ActivityScoreCalculatorTests.swift` | 17 |
| `ScoreCalculatorTests.swift` | 9 |

---

## アルゴリズム詳細

### Autonomic Score
```
base_score = 70
hrv_ratio = today_hrv / baseline_hrv
deviation = (hrv_ratio - 1.0) * 100
raw_score = base_score + deviation

補正要素:
- 深い睡眠不足（<15%）: -5点
- 睡眠時間不足（<6時間）: -5点
```

### Sleep Score
```
// 入眠効率データがないため重み再配分
sleep_score = duration_score * 0.45 + deep_score * 0.35 + rem_score * 0.2

// レム睡眠データもない場合
sleep_score = duration_score * 0.55 + deep_score * 0.45
```

### Rhythm Score
```
// 手首体温データあり
rhythm_score = bedtime_score * 0.35 + waketime_score * 0.35
             + temperature_score * 0.20 + stage_transition_score * 0.10

// 手首体温データなし
rhythm_score = bedtime_score * 0.45 + waketime_score * 0.45
             + stage_transition_score * 0.10
```

### Activity Score
```
step_score = 歩数に応じた線形補間（目標8000歩）
exercise_score = 運動時間に応じた段階評価（目標30分）
activity_score = step_score * 0.6 + exercise_score * 0.4
```

---

## エッジケース対応

| 状況 | 対応 |
|------|------|
| HRVベースラインなし | 業界平均50ms使用 |
| 睡眠データなし | デフォルトスコア50 |
| 手首体温非対応 | 重み再配分 |
| レム睡眠データなし | 重み再配分 |
| 活動データなし | デフォルトスコア50 |

---

## 完了チェックリスト
- [x] 全ステップ完了
- [x] 全テストパス（69テスト）
- [x] Lint/Formatエラーなし
- [x] PRレビュー対応可能
