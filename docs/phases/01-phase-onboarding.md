# Phase 1: オンボーディング設計書

**フェーズ**: 1 / 14  
**Part**: A（iOS UI）  
**前提フェーズ**: なし（独立）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料

- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI 設計指針
- **[UI Specification](../ui-spec.md)** - UI 設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書

### 📱 Swift/iOS 専用資料

- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX 設計原則
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift 開発標準

### ✅ 実装完了後の必須作業

実装完了後は必ず以下を実行してください：

```bash
# リント・フォーマット確認
swiftlint
swift-format --lint --recursive ios/

# テスト実行
swift test
```

---

## このフェーズで実現すること

1. **オンボーディング全 7 画面**の実装と画面遷移
2. **HealthKit 権限リクエスト**と実際のデータ取得
3. **位置情報権限リクエスト**と位置取得
4. **ユーザープロフィール**の UserDefaults 保存
5. **テストデータ生成**（シミュレータ用、DEBUG 時のみ）

---

## 完了条件

- [ ] 全 7 画面が実装され、順番に遷移できる
- [ ] 進捗表示（1/7〜5/7）が画面 2〜6 に正しく表示される（画面 7 は進捗表示なし）
- [ ] ニックネーム、基本情報、関心ごとタグが UserDefaults に保存される
- [ ] HealthKit 権限ダイアログが表示され、許可後にデータ取得できる
- [ ] 位置情報権限ダイアログが表示され、許可後に位置取得できる
- [ ] 権限が拒否された場合もオンボーディングが完了する
- [ ] シミュレータでテストデータを使った動作確認ができる
- [ ] オンボーディング完了後、ホーム画面（Mock でよい）へ遷移する

---

## 画面一覧

| 画面 | 名称             | 必須入力 | 進捗表示 | 主な要素                                           |
| ---- | ---------------- | -------- | -------- | -------------------------------------------------- |
| 1    | ウェルカム       | -        | なし     | ビジュアル、キャッチコピー、「始める」ボタン       |
| 2    | ニックネーム入力 | ✓        | 1/7      | テキスト入力                                       |
| 3    | 基本情報入力     | ✓        | 2/7      | 年齢、性別、体重、身長                             |
| 4    | 職業・生活習慣   | -        | 3/7      | 職業、生活リズム、運動習慣、飲酒習慣（スキップ可） |
| 5    | 関心ごとタグ選択 | ✓        | 4/7      | 6 つのタグから 1〜3 個選択                         |
| 6    | 権限リクエスト   | ✓        | 5/7      | HealthKit、位置情報の説明と許可ボタン              |
| 7    | データ取得中     | -        | なし     | ローディング表示、完了後自動遷移                   |

---

## 画面詳細

### 画面 1: ウェルカム

**目的**: Tempo AI のコンセプトを伝え、期待感を持ってもらう

**レイアウト**:

```
┌─────────────────────────────────┐
│                                 │
│        [大きなビジュアル]        │
│     （ヘルスケアのイメージ）      │
│        画面の上半分を占める      │
│                                 │
├─────────────────────────────────┤
│                                 │
│    あなたのテンポで、            │
│    健やかな毎日を                │
│   （キャッチコピー、大きく太く）  │
│                                 │
│ ✓ AIがあなた専用のアドバイス    │
│ ✓ HealthKitデータを活用         │
│ ✓ 気象・環境も考慮              │
│                                 │
│        [始める]ボタン            │
│      （Accent Color）           │
│                                 │
└─────────────────────────────────┘
```

**構成要素**:

- 上半分: ビジュアル画像（健康、自然、穏やかさをイメージ）
- キャッチコピー: 「あなたのテンポで、健やかな毎日を」
- 3 つの特徴（チェックマーク付き）- Miller's Law に従い 3 項目に限定
- 「始める」ボタン（Accent Color: Soft Coral）

**インタラクション**:

- 「始める」タップ時: scale 0.96 → 元に戻る（0.1 秒）
- 遷移アニメーション: 右へスライドアウト、画面 2 が右からスライドイン

**遷移**: 「始める」タップ → 画面 2 へ

---

### 画面 2: ニックネーム入力

**目的**: ユーザーの呼び名を取得（Mere Exposure Effect で親しみを持たせる）

**レイアウト**:

```
┌─────────────────────────────────┐
│ [← 戻る]            1/7         │
├─────────────────────────────────┤
│                                 │
│    あなたのお名前を              │
│    教えてください                │
│   （見出し、大きめ）             │
│                                 │
│    毎朝、あなたの名前で          │
│    ご挨拶します                  │
│   （説明、中くらい）             │
│                                 │
│  ┌─────────────────────────┐  │
│  │ マサ                      │  │ ← プレースホルダー例
│  └─────────────────────────┘  │
│                                 │
│        [次へ]ボタン              │
│     （入力後に有効化）           │
│                                 │
└─────────────────────────────────┘
```

**構成要素**:

- 戻るボタン（左上）、進捗表示（右上: 1/7）
- タイトル: 「あなたのお名前を教えてください」
- 説明: 「毎朝、あなたの名前でご挨拶します」
- テキスト入力フィールド（プレースホルダー: 「マサ」「あやか」など）
- 「次へ」ボタン

**バリデーション**:

- 1 文字以上の入力で「次へ」が活性化
- 最大 20 文字
- 空欄時: ボタンはグレーアウト、非活性

**インタラクション**:

- 入力フィールドフォーカス時: Primary Color の枠線
- リアルタイムバリデーション（Immediate Feedback）
- キーボード表示時: 画面がスクロールしてボタンが見える位置に

**遷移**: 「次へ」タップ → 画面 3 へ

---

### 画面 3: 基本情報入力

**目的**: パーソナライズに必要な基本情報を取得

**レイアウト**:

```
┌─────────────────────────────────┐
│ [← 戻る]            2/7         │
├─────────────────────────────────┤
│                                 │
│    基本情報を教えてください      │
│                                 │
│    より精度の高いアドバイスを    │
│    お届けするために使用します    │
│                                 │
│  年齢                           │
│  ┌─────────────────────────┐  │
│  │ [数値入力]          歳      │  │
│  └─────────────────────────┘  │
│                                 │
│  性別                           │
│  ┌──┐ ┌──┐ ┌──┐ ┌────┐    │
│  │男性│ │女性│ │その他│ │回答しない│    │
│  └──┘ └──┘ └──┘ └────┘    │
│                                 │
│  体重                           │
│  ┌─────────────────────────┐  │
│  │ [数値入力]          kg      │  │
│  └─────────────────────────┘  │
│                                 │
│  身長                           │
│  ┌─────────────────────────┐  │
│  │ [数値入力]          cm      │  │
│  └─────────────────────────┘  │
│                                 │
│        [次へ]ボタン              │
│                                 │
└─────────────────────────────────┘
```

**構成要素**:

- 戻るボタン、進捗表示（2/7）
- タイトル: 「基本情報を教えてください」
- 説明: 「より精度の高いアドバイスをお届けするために使用します」
- 入力項目:
  - 年齢（数値入力、単位「歳」を右側に固定表示）
  - 性別（選択式ボタン: 男性/女性/その他/回答しない）
  - 体重（数値入力、単位「kg」）
  - 身長（数値入力、単位「cm」）

**バリデーション**:

- 年齢: 18〜100（範囲外はエラー表示）
- 体重: 30〜200 kg
- 身長: 100〜250 cm
- 性別: いずれか 1 つ選択必須
- 全項目入力で「次へ」が活性化

**エラー表示**:

- 入力フィールドの下に赤字でメッセージ
- 例: 「18 歳以上 100 歳以下で入力してください」

**遷移**: 「次へ」タップ → 画面 4 へ

---

### 画面 4: 職業・生活習慣入力

**目的**: より詳細なパーソナライズ情報を取得（任意）

**レイアウト**:

```
┌─────────────────────────────────┐
│ [← 戻る]            3/7         │
├─────────────────────────────────┤
│                                 │
│    もう少し教えてください        │
│                                 │
│    あなたの生活スタイルに        │
│    合わせたアドバイスができます  │
│    （任意）                     │
│                                 │
│  職業カテゴリー                  │
│  ┌─────────────────────────┐  │
│  │ 選択してください        ▼  │  │
│  └─────────────────────────┘  │
│                                 │
│  生活リズム                      │
│  ┌──┐ ┌──┐ ┌──┐          │
│  │朝型│ │夜型│ │不規則│          │
│  └──┘ └──┘ └──┘          │
│                                 │
│  運動習慣                        │
│  ┌────┐ ┌────┐ ...        │
│  │ほぼ毎日│ │週3-4回│            │
│  └────┘ └────┘            │
│                                 │
│  飲酒習慣                        │
│  ┌────┐ ┌────┐ ...        │
│  │飲まない│ │月数回│              │
│  └────┘ └────┘            │
│                                 │
│   [スキップ]      [次へ]        │
│                                 │
└─────────────────────────────────┘
```

**構成要素**:

- 戻るボタン、進捗表示（3/7）
- タイトル: 「もう少し教えてください」
- 説明: 「あなたの生活スタイルに合わせたアドバイスができます（任意）」- 任意であることを明記
- 入力項目（すべて選択式）:
  - 職業カテゴリー（ドロップダウン）
  - 生活リズム（朝型/夜型/不規則）
  - 運動習慣（ほぼ毎日/週 3-4 回/週 1-2 回/ほとんどしない）
  - 飲酒習慣（飲まない/月数回/週 1-2 回/週 3 回以上）
- 「スキップ」リンク（左下、テキストリンク形式）
- 「次へ」ボタン（右下、常に活性）

**インタラクション**:

- 「スキップ」タップ: 未入力のまま画面 5 へ
- 「次へ」タップ: 入力内容を保存して画面 5 へ
- 選択ボタン: タップで選択状態をトグル（選択中は Primary Color 背景）

**遷移**:

- 「次へ」タップ → 画面 5 へ
- 「スキップ」タップ → 画面 5 へ（未入力のまま）

---

### 画面 5: 関心ごとタグ選択

**目的**: アドバイスのパーソナライズ方向を決定

**レイアウト**:

```
┌─────────────────────────────────┐
│ [← 戻る]            4/7         │
├─────────────────────────────────┤
│                                 │
│    あなたの関心ごとを            │
│    教えてください                │
│                                 │
│    1〜3個選んでください          │
│                                 │
│  ┌───────────┐ ┌───────────┐ │
│  │   ⚡       │ │   🍎       │ │
│  │ エネルギー  │ │   栄養     │ │
│  │パフォーマンス│ │   食事     │ │
│  └───────────┘ └───────────┘ │
│                                 │
│  ┌───────────┐ ┌───────────┐ │
│  │   💪       │ │   🧘       │ │
│  │   運動     │ │  メンタル   │ │
│  │フィットネス │ │ ストレス    │ │
│  └───────────┘ └───────────┘ │
│                                 │
│  ┌───────────┐ ┌───────────┐ │
│  │   💄       │ │   😴       │ │
│  │   美容     │ │   睡眠     │ │
│  │スキンケア   │ │           │ │
│  └───────────┘ └───────────┘ │
│                                 │
│        [次へ]ボタン              │
│     （1個以上で有効化）          │
│                                 │
└─────────────────────────────────┘
```

**構成要素**:

- 戻るボタン、進捗表示（4/7）
- タイトル: 「あなたの関心ごとを教えてください」
- 説明: 「1〜3 個選んでください」
- 6 つのタグ（カード形式、2 列 ×3 行）:
  - ⚡ エネルギー・パフォーマンス
  - 🍎 栄養・食事
  - 💪 運動・フィットネス
  - 🧘 メンタル・ストレス
  - 💄 美容・スキンケア
  - 😴 睡眠
- 「次へ」ボタン

**インタラクション**:

- タップで選択状態をトグル
- 未選択: 白背景、薄い枠線
- 選択中: Primary Color 背景、白文字（Von Restorff Effect）
- タップ時: scale 0.95 → 元に戻る（Microinteraction）
- 4 個目をタップ: 選択されない + トースト表示「最大 3 個まで選択できます」

**バリデーション**:

- 選択数が 1〜3 の範囲で「次へ」が活性化
- 0 個: ボタン非活性

**遷移**: 「次へ」タップ → 画面 6 へ

---

### 画面 6: 権限リクエスト ⭐ 詳細設計

**目的**: HealthKit と位置情報の権限を取得（Privacy-First Design）

**レイアウト**:

```
┌─────────────────────────────────┐
│ [← 戻る]            5/7         │
├─────────────────────────────────┤
│                                 │
│    Tempo AIに必要な権限          │
│   （見出し）                    │
│                                 │
│  ┌─────────────────────────┐  │
│  │  🩺                         │  │
│  │  ヘルスケアデータ            │  │
│  │                             │  │
│  │  睡眠や心拍数などのデータを  │  │
│  │  分析して、あなた専用の      │  │
│  │  アドバイスを生成します      │  │
│  └─────────────────────────┘  │
│                                 │
│  ┌─────────────────────────┐  │
│  │  📍                         │  │
│  │  位置情報                    │  │
│  │                             │  │
│  │  天気や大気汚染の情報を      │  │
│  │  取得します（都市レベルのみ）│  │
│  └─────────────────────────┘  │
│                                 │
│    [許可して始める]ボタン        │
│     （Accent Color、大きめ）    │
│                                 │
└─────────────────────────────────┘
```

**構成要素**:

- 戻るボタン、進捗表示（5/7）
- タイトル: 「Tempo AI に必要な権限」
- 2 つの権限カード:
  - 🩺 ヘルスケアデータ: 「睡眠や心拍数などのデータを分析して、あなた専用のアドバイスを生成します」
  - 📍 位置情報: 「天気や大気汚染の情報を取得します（都市レベルのみ）」
- 「許可して始める」ボタン（Accent Color、大きめ）

---

#### 権限リクエストの詳細フロー

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ユーザーが「許可して始める」をタップ                            │
│                                                                 │
│      │                                                          │
│      ↓                                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ステップ1: ボタン状態の即時変更（Immediate Feedback）      │  │
│  │                                                           │  │
│  │  変更前: [許可して始める]  （Accent Color、活性）          │  │
│  │  変更後: [⏳ 権限を確認中...]  （グレー、非活性）          │  │
│  │                                                           │  │
│  │  ※ ユーザーに「処理が始まった」ことを即座に伝える          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│      │                                                          │
│      ↓                                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ステップ2: HealthKit権限ステータスの確認                   │  │
│  │                                                           │  │
│  │  HKHealthStore.authorizationStatus() を確認               │  │
│  │                                                           │  │
│  │  ├─ .notDetermined（未決定）                              │  │
│  │  │   └─ → ステップ3へ（ダイアログ表示）                   │  │
│  │  │                                                        │  │
│  │  ├─ .sharingAuthorized（既に許可済み）                    │  │
│  │  │   └─ → ステップ4へ（ダイアログスキップ）               │  │
│  │  │                                                        │  │
│  │  └─ .sharingDenied（既に拒否済み）                        │  │
│  │      └─ → ステップ4へ（ダイアログスキップ）               │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│      │                                                          │
│      ↓                                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ステップ3: HealthKit権限ダイアログ表示（未決定時のみ）     │  │
│  │                                                           │  │
│  │  ┌───────────────────────────────────────────┐          │  │
│  │  │                                             │          │  │
│  │  │  "Tempo AI"がヘルスケアデータへの            │          │  │
│  │  │  アクセスを求めています                      │          │  │
│  │  │                                             │          │  │
│  │  │  ☑ 心拍数                                  │          │  │
│  │  │  ☑ 心拍変動                                │          │  │
│  │  │  ☑ 睡眠                                    │          │  │
│  │  │  ☑ 歩数                                    │          │  │
│  │  │  ...                                       │          │  │
│  │  │                                             │          │  │
│  │  │  [すべてオフにする]  [すべてオンにする]      │          │  │
│  │  │                                             │          │  │
│  │  └───────────────────────────────────────────┘          │  │
│  │                                                           │  │
│  │  ユーザーの選択を待つ（非同期）                            │  │
│  │                                                           │  │
│  │  ├─ 「すべてオンにする」→ healthKitStatus = .authorized   │  │
│  │  ├─ 「すべてオフにする」→ healthKitStatus = .denied       │  │
│  │  └─ 一部のみON → healthKitStatus = .partiallyAuthorized   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│      │                                                          │
│      ↓                                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ステップ4: 位置情報権限ステータスの確認                    │  │
│  │                                                           │  │
│  │  CLLocationManager.authorizationStatus() を確認           │  │
│  │                                                           │  │
│  │  ├─ .notDetermined（未決定）                              │  │
│  │  │   └─ → ステップ5へ（ダイアログ表示）                   │  │
│  │  │                                                        │  │
│  │  ├─ .authorizedWhenInUse / .authorizedAlways（許可済み）  │  │
│  │  │   └─ → ステップ6へ（ダイアログスキップ）               │  │
│  │  │                                                        │  │
│  │  └─ .denied / .restricted（拒否/制限）                    │  │
│  │      └─ → ステップ6へ（ダイアログスキップ）               │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│      │                                                          │
│      ↓                                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ステップ5: 位置情報権限ダイアログ表示（未決定時のみ）      │  │
│  │                                                           │  │
│  │  ┌───────────────────────────────────────────┐          │  │
│  │  │                                             │          │  │
│  │  │  "Tempo AI"があなたの位置情報を              │          │  │
│  │  │  使用することを許可しますか？                │          │  │
│  │  │                                             │          │  │
│  │  │  位置情報は天気や大気汚染の                  │          │  │
│  │  │  情報を取得するために使用されます            │          │  │
│  │  │                                             │          │  │
│  │  │  [許可しない]                               │          │  │
│  │  │  [1度だけ許可]                              │          │  │
│  │  │  [Appの使用中は許可]                        │          │  │
│  │  │                                             │          │  │
│  │  └───────────────────────────────────────────┘          │  │
│  │                                                           │  │
│  │  ユーザーの選択を待つ（非同期）                            │  │
│  │                                                           │  │
│  │  ├─ 「Appの使用中は許可」→ locationStatus = .authorized   │  │
│  │  ├─ 「1度だけ許可」→ locationStatus = .authorizedOnce     │  │
│  │  └─ 「許可しない」→ locationStatus = .denied              │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│      │                                                          │
│      ↓                                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ステップ6: 権限ステータスの保存と画面遷移                  │  │
│  │                                                           │  │
│  │  1. 権限ステータスをUserDefaultsに保存                     │  │
│  │     - healthKitStatus: .authorized / .denied / .partial   │  │
│  │     - locationStatus: .authorized / .denied               │  │
│  │                                                           │  │
│  │  2. 画面7へ遷移（権限の結果に関わらず必ず進む）            │  │
│  │     ※ 拒否された場合のエラーハンドリングはPhase 13で実装   │  │
│  │                                                           │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

#### ボタンの状態遷移

| 状態             | テキスト           | 背景色                     | 活性 | 補足                |
| ---------------- | ------------------ | -------------------------- | ---- | ------------------- |
| 初期             | 許可して始める     | Accent Color（Soft Coral） | ○    | タップ可能          |
| 処理中           | ⏳ 権限を確認中... | グレー（#9CA3AF）          | ×    | スピナー表示        |
| ダイアログ表示中 | ⏳ 権限を確認中... | グレー                     | ×    | OS ダイアログが前面 |

---

#### 権限の組み合わせと結果

| HealthKit | 位置情報 | 結果   | 画面 7 での挙動                |
| --------- | -------- | ------ | ------------------------------ |
| 許可      | 許可     | 最良   | 全データ取得                   |
| 許可      | 拒否     | 部分的 | HealthKit のみ取得（天気なし） |
| 拒否      | 許可     | 部分的 | 位置のみ取得（健康データなし） |
| 拒否      | 拒否     | 最小   | データ取得なし（Mock で進む）  |

**重要**: いずれの場合も**オンボーディングは完了**させる（Tesler's Law: 複雑さをユーザーに転嫁しない）

---

### 画面 7: データ取得中

**目的**: HealthKit からデータを取得し、初回アドバイス準備（Labor Illusion で価値を感じさせる）

**レイアウト**:

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│       [アニメーション]           │
│    （ローディングインジケーター）│
│        画面中央、大きめ          │
│                                 │
│    あなた専用のアドバイスを      │
│    準備中...                    │
│   （メッセージ、中央寄せ）       │
│                                 │
│    睡眠データを取得しています    │
│   （進捗メッセージ、小さめ）     │
│                                 │
└─────────────────────────────────┘
```

**構成要素**:

- ローディングインジケーター（円形スピナー、Primary Color）
- メインメッセージ: 「あなた専用のアドバイスを準備中...」
- 進捗メッセージ（動的に切り替わる）

---

#### 進捗メッセージの切り替え（Labor Illusion）

```swift
enum LoadingStep: CaseIterable {
    case checkingPermissions  // 「権限を確認しています...」
    case fetchingSleep        // 「睡眠データを取得しています...」
    case fetchingHeartRate    // 「心拍数データを取得しています...」
    case fetchingActivity     // 「活動データを取得しています...」
    case fetchingLocation     // 「位置情報を取得しています...」
    case preparingAdvice      // 「アドバイスを準備しています...」
    case almostDone           // 「もうすぐ完了です...」
}
```

**切り替えルール**:

- 各ステップ完了時に次のメッセージへ
- 最低表示時間: 0.8 秒（速すぎると読めない）
- フェードイン/アウトで切り替え（0.3 秒）

---

#### 処理フロー

```
画面7表示
    │
    ↓
権限状態を確認
    │
    ├─ HealthKit: authorized
    │   └─ 過去30日のHealthKitデータを取得
    │       ├─ 成功 → データをメモリに保持
    │       └─ 失敗/データなし → healthDataAvailable = false
    │
    └─ HealthKit: denied
        └─ スキップ、healthDataAvailable = false
    │
    ↓
    │
    ├─ Location: authorized
    │   └─ 現在位置を取得 → Reverse Geocodingで都市名取得
    │       ├─ 成功 → 緯度経度・都市名を保持
    │       └─ 失敗 → locationAvailable = false
    │
    └─ Location: denied
        └─ スキップ、locationAvailable = false
    │
    ↓
onboardingCompleted = true をUserDefaultsに保存
    │
    ↓
ホーム画面へ遷移（フェードアウト → フェードイン）
```

**所要時間**:

- 通常: 5-10 秒
- 最大: 30 秒（タイムアウト後は強制遷移）

---

## データモデル

### UserProfile

```swift
struct UserProfile: Codable {
    let nickname: String
    let age: Int
    let gender: Gender
    let weightKg: Double
    let heightCm: Double
    let occupation: Occupation?
    let lifestyleRhythm: LifestyleRhythm?
    let exerciseFrequency: ExerciseFrequency?
    let alcoholFrequency: AlcoholFrequency?
    let interests: [Interest]
}
```

### 列挙型

```swift
enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    case notSpecified = "not_specified"

    var displayName: String {
        switch self {
        case .male: return "男性"
        case .female: return "女性"
        case .other: return "その他"
        case .notSpecified: return "回答しない"
        }
    }
}

enum Occupation: String, Codable, CaseIterable {
    case officeWork = "office_work"
    case sales = "sales"
    case serviceIndustry = "service_industry"
    case medical = "medical"
    case education = "education"
    case manufacturing = "manufacturing"
    case transport = "transport"
    case itEngineer = "it_engineer"
    case creative = "creative"
    case homemaker = "homemaker"
    case student = "student"
    case other = "other"

    var displayName: String {
        switch self {
        case .officeWork: return "事務・オフィスワーク"
        case .sales: return "営業・接客"
        case .serviceIndustry: return "サービス業"
        case .medical: return "医療・介護"
        case .education: return "教育・保育"
        case .manufacturing: return "製造・技術"
        case .transport: return "運輸・物流"
        case .itEngineer: return "IT・エンジニア"
        case .creative: return "クリエイティブ"
        case .homemaker: return "主婦・主夫"
        case .student: return "学生"
        case .other: return "その他"
        }
    }
}

enum LifestyleRhythm: String, Codable, CaseIterable {
    case morning = "morning"
    case night = "night"
    case irregular = "irregular"

    var displayName: String {
        switch self {
        case .morning: return "朝型"
        case .night: return "夜型"
        case .irregular: return "不規則"
        }
    }
}

enum ExerciseFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case threeToFour = "three_to_four"
    case oneToTwo = "one_to_two"
    case rarely = "rarely"

    var displayName: String {
        switch self {
        case .daily: return "ほぼ毎日"
        case .threeToFour: return "週3-4回"
        case .oneToTwo: return "週1-2回"
        case .rarely: return "ほとんどしない"
        }
    }
}

enum AlcoholFrequency: String, Codable, CaseIterable {
    case never = "never"
    case monthly = "monthly"
    case oneToTwo = "one_to_two"
    case threeOrMore = "three_or_more"

    var displayName: String {
        switch self {
        case .never: return "飲まない"
        case .monthly: return "月数回"
        case .oneToTwo: return "週1-2回"
        case .threeOrMore: return "週3回以上"
        }
    }
}

enum Interest: String, Codable, CaseIterable {
    case energyPerformance = "energy_performance"
    case nutrition = "nutrition"
    case fitness = "fitness"
    case mentalStress = "mental_stress"
    case beauty = "beauty"
    case sleep = "sleep"

    var displayName: String {
        switch self {
        case .energyPerformance: return "エネルギー・パフォーマンス"
        case .nutrition: return "栄養・食事"
        case .fitness: return "運動・フィットネス"
        case .mentalStress: return "メンタル・ストレス"
        case .beauty: return "美容・スキンケア"
        case .sleep: return "睡眠"
        }
    }

    var emoji: String {
        switch self {
        case .energyPerformance: return "⚡"
        case .nutrition: return "🍎"
        case .fitness: return "💪"
        case .mentalStress: return "🧘"
        case .beauty: return "💄"
        case .sleep: return "😴"
        }
    }
}
```

### 権限ステータス

```swift
enum HealthKitAuthorizationStatus: String, Codable {
    case notDetermined = "not_determined"
    case authorized = "authorized"
    case denied = "denied"
    case partiallyAuthorized = "partially_authorized"
}

enum LocationAuthorizationStatus: String, Codable {
    case notDetermined = "not_determined"
    case authorized = "authorized"
    case authorizedOnce = "authorized_once"
    case denied = "denied"
    case restricted = "restricted"
}
```

---

## 実装コンポーネント

### ディレクトリ構造

```
ios/TempoAI/
├── Features/
│   └── Onboarding/
│       ├── Views/
│       │   ├── OnboardingContainerView.swift
│       │   ├── WelcomeView.swift
│       │   ├── NicknameInputView.swift
│       │   ├── BasicInfoView.swift
│       │   ├── LifestyleView.swift
│       │   ├── InterestsView.swift
│       │   ├── PermissionsView.swift
│       │   └── DataLoadingView.swift
│       ├── ViewModels/
│       │   └── OnboardingViewModel.swift
│       └── Models/
│           └── OnboardingState.swift
├── Services/
│   ├── HealthKitManager.swift
│   ├── LocationManager.swift
│   └── CacheManager.swift
└── Shared/
    ├── Models/
    │   ├── UserProfile.swift
    │   └── Enums/
    │       ├── Gender.swift
    │       ├── Occupation.swift
    │       ├── LifestyleRhythm.swift
    │       ├── ExerciseFrequency.swift
    │       ├── AlcoholFrequency.swift
    │       └── Interest.swift
    └── Components/
        ├── PrimaryButton.swift
        ├── SecondaryButton.swift
        ├── SelectionButton.swift
        ├── TagCard.swift
        └── ProgressIndicator.swift
```

---

## HealthKitManager

### 権限リクエスト対象

**必須データ**:

```swift
private let requiredTypes: Set<HKObjectType> = [
    HKQuantityType(.heartRate),
    HKQuantityType(.heartRateVariabilitySDNN),
    HKCategoryType(.sleepAnalysis),
    HKQuantityType(.stepCount),
    HKQuantityType(.activeEnergyBurned)
]
```

**オプションデータ**:

```swift
private let optionalTypes: Set<HKObjectType> = [
    HKQuantityType(.restingHeartRate),
    HKQuantityType(.oxygenSaturation),
    HKQuantityType(.bodyTemperature)
]
```

### 主要メソッド

```swift
@MainActor
final class HealthKitManager: ObservableObject {
    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined

    /// 権限をリクエスト
    func requestAuthorization() async throws {
        // 1. HealthKitが利用可能か確認
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        // 2. 権限リクエスト
        try await healthStore.requestAuthorization(
            toShare: [],
            read: requiredTypes.union(optionalTypes)
        )

        // 3. ステータス更新
        await updateAuthorizationStatus()
    }

    /// 過去30日分のデータを取得
    func fetchInitialData() async throws -> HealthData {
        // 実装
    }
}
```

---

## LocationManager

### 権限レベル

- `When In Use`（使用中のみ）で十分

### 主要メソッド

```swift
@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var currentCity: String?
    @Published var coordinates: CLLocationCoordinate2D?

    /// 権限をリクエスト
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// 現在位置を取得
    func requestCurrentLocation() async throws -> CLLocation {
        // 実装
    }

    /// 都市名を取得（Reverse Geocoding）
    func fetchCityName(for location: CLLocation) async throws -> String {
        // 実装
    }
}
```

---

## テストデータ生成（DEBUG 用）

シミュレータでの動作確認用に、DEBUG 時のみテストデータを生成する仕組みを用意する。

### MockHealthDataGenerator

```swift
#if DEBUG
final class MockHealthDataGenerator {
    /// 過去30日分のテストデータを生成
    static func generateMockData() -> HealthData {
        // 睡眠: 6-8時間の範囲でランダム
        // HRV: 40-80msの範囲でランダム
        // 心拍数: 55-75bpmの範囲でランダム
        // 歩数: 5000-12000の範囲でランダム
    }
}
#endif
```

### 使用方法

- DEBUG 時のみ有効
- 開発者が明示的に呼び出す（自動実行ではない）
- HealthKit 権限が拒否された場合のフォールバックとして使用

---

## 状態管理

### OnboardingState

```swift
@Observable
final class OnboardingState {
    var currentStep: Int = 1

    // 入力データ
    var nickname: String = ""
    var age: Int?
    var gender: Gender?
    var weightKg: Double?
    var heightCm: Double?
    var occupation: Occupation?
    var lifestyleRhythm: LifestyleRhythm?
    var exerciseFrequency: ExerciseFrequency?
    var alcoholFrequency: AlcoholFrequency?
    var selectedInterests: Set<Interest> = []

    // 権限ステータス
    var healthKitStatus: HealthKitAuthorizationStatus = .notDetermined
    var locationStatus: LocationAuthorizationStatus = .notDetermined

    // 完了フラグ
    var isCompleted: Bool = false

    // バリデーション
    var canProceedToStep3: Bool {
        !nickname.isEmpty
    }

    var canProceedToStep4: Bool {
        age != nil && gender != nil && weightKg != nil && heightCm != nil
    }

    var canProceedToStep6: Bool {
        selectedInterests.count >= 1 && selectedInterests.count <= 3
    }
}
```

### 永続化（UserDefaults）

```swift
// 保存するキー
enum UserDefaultsKeys {
    static let onboardingCompleted = "onboardingCompleted"
    static let userProfile = "userProfile"
    static let healthKitStatus = "healthKitStatus"
    static let locationStatus = "locationStatus"
}
```

---

## 画面遷移フロー

```
アプリ起動
    │
    ├─ onboardingCompleted == true → ホーム画面
    │
    └─ onboardingCompleted == false
        │
        ↓
    画面1: ウェルカム
        │ [始める]
        ↓
    画面2: ニックネーム
        │ [次へ]
        ↓
    画面3: 基本情報
        │ [次へ]
        ↓
    画面4: 職業・生活習慣
        │ [次へ] or [スキップ]
        ↓
    画面5: 関心ごとタグ
        │ [次へ]
        ↓
    画面6: 権限リクエスト
        │ [許可して始める]
        │ → HealthKit権限ダイアログ（未決定時のみ）
        │ → 位置情報権限ダイアログ（未決定時のみ）
        ↓
    画面7: データ取得中
        │ (自動)
        ↓
    ホーム画面
```

---

## UI/UX ポイント

### 適用する UX 原則

| 原則                 | 適用箇所                                              |
| -------------------- | ----------------------------------------------------- |
| Miller's Law         | 画面 1 の特徴を 3 つに限定、関心ごとタグを 6 つに限定 |
| Fitts's Law          | ボタンは十分な大きさ（最低 44x44pt）、画面下部に配置  |
| Hick's Law           | 各画面の選択肢を最小限に                              |
| Immediate Feedback   | タップ時の即座の視覚変化                              |
| Peak-End Rule        | 画面 7→ ホーム画面で達成感を演出                      |
| Privacy-First Design | 権限リクエスト前に理由を説明                          |
| Labor Illusion       | 画面 7 で進捗メッセージを表示                         |
| Von Restorff Effect  | 選択中のタグを目立たせる                              |
| Tesler's Law         | 権限拒否でもフローを継続                              |

### 進捗表示

- 画面 2〜6 で「1/7」〜「5/7」を表示
- ウェルカム画面とローディング画面では非表示
- 右上に小さく表示、Secondary Text カラー

### 戻る操作

- 画面 2 以降で左上に戻るボタン
- スワイプで戻ることも可能（iOS 標準動作）
- 画面 7 では戻るボタンなし（自動遷移のため）

### 入力バリデーション

- リアルタイムでバリデーション（Immediate Feedback）
- エラー時は入力フィールドの下に赤字でメッセージ
- 「次へ」ボタンはバリデーション通過まで非活性

### カラーパレット

| 用途           | カラー          | Hex     |
| -------------- | --------------- | ------- |
| Primary        | Soft Sage Green | #8FBC8F |
| Secondary      | Warm Beige      | #F5F5DC |
| Accent         | Soft Coral      | #FF7F7F |
| Primary Text   | Dark Gray       | #333333 |
| Secondary Text | Medium Gray     | #666666 |
| Error          | Red             | #DC3545 |
| Disabled       | Light Gray      | #9CA3AF |

### アニメーション

| 要素                   | アニメーション                | Duration |
| ---------------------- | ----------------------------- | -------- |
| 画面遷移               | 右からスライドイン            | 0.3 秒   |
| ボタンタップ           | scale 0.96 → 1.0              | 0.1 秒   |
| タグ選択               | scale 0.95 → 1.0              | 0.1 秒   |
| 進捗メッセージ切り替え | フェードイン/アウト           | 0.3 秒   |
| 画面 7→ ホーム遷移     | フェードアウト → フェードイン | 0.5 秒   |

---

## 関連ドキュメント

- `product-spec.md` - セクション 5「オンボーディングフロー」
- `ui-spec.md` - セクション 5「オンボーディング」
- `technical-spec.md` - セクション 2.2〜2.3「主要クラス設計」「データモデル」
- `ux_concepts.md` - UX 設計原則

---

## 改訂履歴

| バージョン | 日付       | 変更内容                                                |
| ---------- | ---------- | ------------------------------------------------------- |
| 1.0        | 2025-12-10 | 初版作成                                                |
| 1.1        | 2025-12-10 | 権限リクエストの詳細フロー追加、UX 原則の適用箇所を明記 |
