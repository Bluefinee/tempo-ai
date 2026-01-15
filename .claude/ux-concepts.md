# UX デザイン原則 - TempoAI

> 詳細なUXコンセプトは `docs/specs/tempoai_ux_concepts.md` を参照

---

## TempoAI の 3 つのデザイン原則

### 1. Calm Technology

**「押し付けない、追い立てない」**

- 1日1回の穏やかなアドバイス
- 通知は最小限（リマインダーのみ）
- ユーザーのペースを尊重

```typescript
// ✅ Good - 穏やかなトーン
"今日のリズムは安定しています。いつも通りの1日を過ごしましょう。"

// ❌ Bad - 煽るトーン
"今すぐ行動しないと健康が危険です！"
```

### 2. Data as Poetry

**「数値を詩的ビジュアルで表現」**

- スコアは「波」「リズム」のようなメタファーで表現
- グラフは美しく、情報過多にしない
- 色彩は落ち着いたパレット

```typescript
// スコアの表現
"excellent" → "とても良い調子" or "波に乗っています"
"needs_attention" → "少し休息が必要かも"
```

### 3. Personal Rhythm

**「他人との比較なし、過去の自分との対話」**

- ランキングや競争要素なし
- Baseline は自分の過去30日平均
- 「あなたの普通」を基準にフィードバック

---

## 実装で意識すべき UX パターン

### Peak-End Rule（ピークエンドの法則）

体験の「ピーク」と「終わり」が全体評価を決める。

```typescript
// オンボーディング完了時
<View style={styles.celebration}>
  <LottieAnimation source={confetti} />
  <Text>素晴らしい！準備が整いました</Text>
</View>
```

### Labor Illusion（労働の幻想）

処理中であることを明示すると、価値を感じやすい。

```typescript
// AI分析中の表示
"あなたの健康データを分析しています..."
"サーカディアンリズムを計算中..."
"パーソナライズされたアドバイスを生成中..."
```

### Doherty Threshold（ドハティの閾値）

0.4秒以内のレスポンスなら、ユーザーは待ちを感じない。

```typescript
// Optimistic UI - 即座に反映
const handleComplete = () => {
  setCompleted(true); // 即座にUI更新
  api.markCompleted().catch(() => setCompleted(false)); // バックグラウンドで送信
};
```

---

## スコア表示のガイドライン

### ステータスと色

| Status | 範囲 | 色 | トーン |
|--------|------|-----|-------|
| excellent | 80-100% | Green | 肯定的・称賛 |
| good | 60-79% | Blue | 穏やか・維持 |
| moderate | 40-59% | Yellow | 中立・観察 |
| needs_attention | 0-39% | Orange | 優しい注意・ケア |

### テンプレート文のトーン

```typescript
// ✅ Good - 温かく、判断を押し付けない
"昨夜の睡眠は少し短めでした。今日は無理せず過ごしましょう。"

// ❌ Bad - 冷たい、判断的
"睡眠時間が不足しています。改善が必要です。"
```

---

## アクセシビリティ

### 必須対応

- 最小タップ領域: 44x44px
- コントラスト比: 4.5:1 以上（テキスト）
- VoiceOver対応（accessibilityLabel）
- 色だけに依存しない情報伝達

```tsx
// ✅ Good
<TouchableOpacity
  style={styles.button}
  accessibilityLabel="今日のアドバイスを見る"
  accessibilityRole="button"
>
  <Text>Today's Insight</Text>
</TouchableOpacity>
```

---

## 関連ドキュメント

- `docs/specs/tempoai_ux_concepts.md` - 詳細なUX心理学原則
- `docs/specs/tempoai_ui_spec.md` - UI/UXデザイン仕様
- `docs/specs/tempoai_product_spec.md` - プロダクト仕様
