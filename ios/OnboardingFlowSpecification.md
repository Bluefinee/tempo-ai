# オンボーディングフロー完全仕様書

## 1. 基本フロー（正常系）

### 1.1 初回起動パターン
```
【前提条件】
- アプリ初回インストール
- UserDefaults.onboardingCompleted = false (or nil)
- UserDefaults.selectedLanguage = nil

【フロー】
アプリ起動 → TempoAIApp判定 → OnboardingFlowView表示 → 言語選択画面(Page 0) → 言語選択 → ウェルカム画面(Page 1) → データソース説明(Page 2) → AI分析説明(Page 3) → 日次プラン説明(Page 4) → HealthKit権限(Page 5) → Location権限+完了(Page 6) → オンボーディング完了 → ホーム画面遷移

【各ページでの動作詳細】
Page 0: 言語選択
- 表示要素: 🌍アイコン、二言語タイトル、日本語ボタン🇯🇵、英語ボタン🇺🇸
- 🇯🇵日本語ボタンタップ → viewModel.setLanguage(.japanese) → UserDefaults保存 → LocalizationManager即座更新 → withAnimation → viewModel.nextPage() → Page 1へ遷移
- 🇺🇸英語ボタンタップ → viewModel.setLanguage(.english) → UserDefaults保存 → LocalizationManager即座更新 → withAnimation → viewModel.nextPage() → Page 1へ遷移
- TabView animation: easeInOut(duration: 0.5)
- 戻る操作: 不可（最初のページ）

Page 1: ウェルカム
- 表示要素: 選択言語でのタイトル・説明文、「次へ」ボタン
- 言語反映確認: LocalizationManagerの設定が画面テキストに反映
- 「次へ」ボタンタップ → viewModel.nextPage() → Page 2へ遷移
- 戻るスワイプ/ジェスチャー → viewModel.currentPage = 0 → Page 0へ戻る
- TabViewのページインジケーター表示

Page 2: データソース説明
- 表示要素: データ収集の説明、アイコン、「次へ」ボタン
- 「次へ」ボタンタップ → viewModel.nextPage() → Page 3へ遷移
- 戻る → viewModel.previousPage() → Page 1へ

Page 3: AI分析説明
- 表示要素: AI分析機能の説明、「次へ」ボタン
- 「次へ」ボタンタップ → viewModel.nextPage() → Page 4へ遷移
- 戻る → viewModel.previousPage() → Page 2へ

Page 4: 日次プラン説明
- 表示要素: アプリ機能の説明、「次へ」ボタン
- 「次へ」ボタンタップ → viewModel.nextPage() → Page 5へ遷移
- 戻る → viewModel.previousPage() → Page 3へ

Page 5: HealthKit権限
- 表示要素: ヘルスケアデータ説明、「ヘルスケアへのアクセスを許可」ボタン、機能説明リスト
- 「ヘルスケアへのアクセスを許可」ボタンタップ → viewModel.requestHealthKitPermission() → iOS システム権限ダイアログ表示
- 権限許可完了 → ボタンテキスト「✓ ヘルスケア許可済み」 → healthKitStatus = .granted → 「次へ」ボタン表示・活性化
- 権限拒否完了 → ボタンテキスト「スキップして続行」 → healthKitStatus = .denied → 「次へ」ボタン表示・活性化
- 戻る → viewModel.previousPage() → Page 4へ（権限状態維持）

Page 6: Location権限 + 完了
- 表示要素: 位置情報説明、「位置情報へのアクセスを許可」ボタン
- 「位置情報へのアクセスを許可」ボタンタップ → viewModel.requestLocationPermission() → iOS システム権限ダイアログ表示
- 権限許可完了 → ボタンテキスト「TempoAIを使う」 → locationStatus = .granted
- 権限拒否完了 → ボタンテキスト「位置情報なしで続行」 → locationStatus = .denied
- 「TempoAIを使う」または「位置情報なしで続行」タップ → viewModel.completeOnboarding() → UserDefaults.onboardingCompleted = true → isOnboardingCompleted = true → TempoAIApp再評価 → ContentView()表示
- 戻る → viewModel.previousPage() → Page 5へ（権限状態維持）
```

### 1.2 言語切り替え動作
```
【言語選択時の詳細動作】
1. viewModel.setLanguage(selectedLanguage)実行
2. UserDefaults.selectedLanguage = language.rawValue保存
3. LocalizationManager.shared.setLanguage(language.localizationLanguage)即座実行
4. 以降の画面遷移で選択言語のテキスト表示
5. アプリ再起動後も言語設定保持・自動適用

【言語設定の永続化】
- 保存場所: UserDefaults.standard
- キー: "SelectedLanguage"
- 値: "ja" または "en"
- 読み込みタイミング: OnboardingViewModel.init() → loadOnboardingState()
```

## 2. 完了後・再起動時の動作パターン

### 2.1 オンボーディング完了済みユーザー
```
【前提条件】
- UserDefaults.onboardingCompleted = true

【動作フロー】
1. アプリ起動
2. TempoAIApp.body評価
3. OnboardingViewModel初期化 → loadOnboardingState()
4. isOnboardingCompleted = true確認
5. 即座にContentView()表示（OnboardingFlowViewスキップ）
6. 言語設定は保存済み設定で自動適用
```

### 2.2 オンボーディング中断・再起動
```
【前提条件】
- UserDefaults.onboardingCompleted = false (or nil)
- UserDefaults.selectedLanguage = "ja"など（途中まで進行）

【動作フロー】
1. アプリ起動
2. OnboardingFlowView表示
3. currentPage = 0（常に言語選択から再開）
4. 言語設定のみ復元・適用
5. ユーザーは最初から進行（ページ位置は保存しない仕様）
```

### 2.3 オンボーディングリセットパターン
```
【リセット操作の詳細動作】
1. viewModel.resetOnboarding()実行
2. UserDefaults.removeObject(forKey: "OnboardingCompleted")
3. UserDefaults.removeObject(forKey: "OnboardingStartTime")
4. currentPage = 0設定
5. isOnboardingCompleted = false設定
6. healthKitStatus = permissionManager.healthKitPermissionStatus（現在の実際の権限状態）
7. locationStatus = permissionManager.locationPermissionStatus（現在の実際の権限状態）

【リセット後の期待動作】
- 次回アプリ起動時 → TempoAIApp判定 → OnboardingFlowView表示
- Page 0(言語選択)表示
- 言語選択画面に安定して留まる（即座に閉じない）
- 言語設定は保持（resetOnboardingで削除しない）
```

## 3. 権限関連フロー

### 3.1 HealthKit権限フロー詳細
```
【権限許可パターン】
1. 「ヘルスケアへのアクセスを許可」ボタンタップ
2. viewModel.requestHealthKitPermission() async実行
3. HealthKitManager.shared.requestAuthorization() async実行
4. iOS システム権限ダイアログ表示
5. ユーザー「許可」選択（全て・一部問わず）
6. HealthKitManager.shared.authorizationStatus更新
7. viewModel.healthKitStatus = .granted
8. ボタンテキスト更新「✓ ヘルスケア許可済み」
9. ボタンスタイル更新（成功状態）
10. 「次へ」ボタン表示・活性化

【権限拒否パターン】
1. 「ヘルスケアへのアクセスを許可」ボタンタップ
2. ユーザー「許可しない」選択
3. viewModel.healthKitStatus = .denied
4. ボタンテキスト更新「スキップして続行」
5. ボタンスタイル更新（スキップ状態）
6. 「次へ」ボタン表示・活性化（アプリは制限機能で継続可能）

【部分許可パターン】
1. ユーザーがHealthKitダイアログで一部データのみ許可
2. HealthKitManager内でデータアクセステスト実行
3. 読み取り可能データがある場合 → viewModel.healthKitStatus = .granted
4. 「✓ ヘルスケア許可済み」表示（部分データでもアプリ機能提供可能）

【HealthKit利用不可端末】
1. HKHealthStore.isHealthDataAvailable() = false
2. ボタン表示「この端末では利用できません」
3. ボタン非活性化
4. 自動的にスキップ扱いでフロー継続
```

### 3.2 Location権限フロー詳細
```
【権限許可パターン】
1. 「位置情報へのアクセスを許可」ボタンタップ
2. viewModel.requestLocationPermission() async実行
3. iOS システム位置情報権限ダイアログ表示
4. ユーザー「App使用中は許可」選択
5. viewModel.locationStatus = .granted
6. ボタンテキスト更新「TempoAIを使う」
7. 最終完了ボタンとして機能
8. タップでオンボーディング完了処理

【権限拒否パターン】
1. ユーザー「許可しない」選択
2. viewModel.locationStatus = .denied
3. ボタンテキスト更新「位置情報なしで続行」
4. 機能制限説明表示
5. タップでオンボーディング完了処理（位置情報なし機能で継続）

【既に権限設定済み】
1. 端末設定で既に権限が許可/拒否済み
2. ダイアログ表示されず即座に結果反映
3. 該当状態のボタン表示に即座更新
```

## 4. エラー・例外パターン

### 4.1 アプリライフサイクル中断
```
【オンボーディング途中でアプリ完全終了】
- アプリプロセス終了（強制終了・再起動・メモリクリア等）
- 保存データ: 選択済み言語、完了フラグ(false)
- 失われるデータ: currentPage位置、権限リクエスト中間状態
- 次回起動動作: Page 0(言語選択)から再開、言語設定のみ復元

【オンボーディング途中でバックグラウンド移行】
- アプリがバックグラウンドに移行、フォアグラウンド復帰
- メモリ上の状態保持: currentPage、権限リクエスト状態、ViewModel状態
- 復帰時動作: 同じページで継続、進行中の権限ダイアログがあれば適切に復帰
- 長時間バックグラウンド後メモリクリア: 上記「完全終了」と同じ動作

【権限ダイアログ表示中のアプリ中断】
- HealthKit/Location権限ダイアログ表示中にアプリ中断
- 復帰時: ダイアログ結果を適切に処理、ボタン状態正常更新
- タイムアウト: iOS側でダイアログ自動キャンセル→拒否扱い
```

### 4.2 権限関連エラー・制限
```
【HealthKit利用不可デバイス（Apple Watch等）】
- HKHealthStore.isHealthDataAvailable() = false
- ボタン表示「この端末では利用できません」
- ボタン非活性・グレーアウト
- 自動的にスキップ扱いでフロー継続可能

【システム設定で事前拒否済み】
- iOS設定でアプリのHealthKit/Location権限が拒否設定済み
- 権限リクエスト時にダイアログ表示されない
- 即座に拒否結果として処理
- スキップオプション提供・フロー継続

【権限リクエストシステムエラー】
- ネットワークエラー、システム不具合等
- エラーハンドリング: スキップオプション提供
- ログ出力・ユーザー向けエラーメッセージ表示
- アプリクラッシュ回避・フロー継続保証
```

### 4.3 状態不整合・データ破損パターン
```
【UserDefaults破損・不正データ】
- onboardingCompleted値が不正、selectedLanguageが不正値等
- デフォルト値で初期化: isOnboardingCompleted = false, selectedLanguage = .japanese
- オンボーディング再実行
- エラーログ記録

【ViewModel状態とView表示の不一致】
- @Published propertyの更新遅延、SwiftUIの再描画タイミング問題
- @MainActor適用でUI更新を保証
- onAppear/onDisappearでの状態確認・同期
- 状態監視・不整合検出ログ

【複数権限状態の競合】
- HealthKit一部許可+Location拒否等の組み合わせ
- 各権限独立管理・個別状態表示
- 「利用可能機能」の動的表示・案内
- graceful degradation（段階的機能縮退）
```

## 5. パフォーマンス・UX考慮

### 5.1 アニメーション・遷移詳細
```
【ページ遷移アニメーション】
- TabView.pageStyle使用
- SwiftUIネイティブのスワイプ遷移
- 各ボタンタップ時: withAnimation(.easeInOut(duration: 0.5))
- ページインジケーター常時表示
- 遷移中の操作ブロック（重複タップ防止）

【ボタン状態変化アニメーション】
- 権限許可後のボタンテキスト・色変更
- withAnimation(.easeInOut)適用
- ローディング表示: 権限リクエスト中のスピナー
- 無効状態: グレーアウト・透明度調整

【言語切り替え時のUI更新】
- LocalizationManager更新後の即座テキスト反映
- 遷移アニメーション中の言語適用タイミング
- レイアウト崩れ防止（文字数変化対応）
```

### 5.2 メモリ・リソース管理
```
【メモリ効率化】
- OnboardingViewModelの適切な@StateObject管理
- 不要なView階層の削除
- 画像・アイコンリソースの最適化
- NotificationCenter observerの適切な解除

【メモリ警告時の動作】
- 重要な状態（currentPage、権限状態、言語設定）の保持
- 一時的なUI状態の破棄・再構築
- メモリプレッシャー検出・ログ記録
- graceful degradation継続

【バックグラウンド・フォアグラウンド対応】
- 状態保存タイミングの最適化
- 重要データの即座永続化
- アプリライフサイクル通知の監視
- 復帰時の状態復元・整合性チェック
```

## 6. 国際化・アクセシビリティ

### 6.1 多言語対応詳細
```
【サポート言語】
- 日本語（ja）: デフォルト言語
- 英語（en）: 国際対応

【言語切り替え実装】
- 選択タイミング: Page 0での言語選択ボタンタップ時
- 適用タイミング: 即座（次ページ遷移時から反映）
- 永続化: UserDefaults.selectedLanguage
- LocalizationManager経由でのシステム統合

【ローカライゼーションファイル】
- ja.lproj/Localizable.strings: 日本語文言
- en.lproj/Localizable.strings: 英語文言
- 画面タイトル、ボタンテキスト、説明文の完全対応
```

### 6.2 アクセシビリティ対応
```
【VoiceOver対応】
- 各ページの適切な見出し設定
- ボタン・操作要素の説明ラベル
- ページ遷移時の音声案内
- 権限状態変化の読み上げ通知

【Dynamic Type対応】
- フォントサイズ自動調整対応
- レイアウト動的調整
- 大きいフォント時の画面崩れ防止

【色・コントラスト対応】
- 高コントラスト設定対応
- 色覚障害対応（色情報に依存しない設計）
- ダークモード対応（将来実装予定）
```

## 7. テスト観点・検証項目

### 7.1 機能テスト観点
```
【基本フロー】
- 初回起動→言語選択→全ページ遷移→完了の一連動作
- 各言語選択でのテキスト表示・LocalizationManager連携
- 権限許可/拒否での分岐動作・ボタン状態変化
- 戻るナビゲーション・ページジャンプ動作

【状態管理】
- オンボーディング完了後の再起動動作
- リセット機能の状態クリア・初期状態復帰
- 権限状態変化のリアルタイム反映
- UserDefaults永続化・復元の正常性

【エラーハンドリング】
- 権限拒否時のgraceful handling
- システム不具合時の継続動作
- 不正データ時の初期化・回復動作
```

### 7.2 非機能テスト観点
```
【パフォーマンス】
- ページ遷移速度・アニメーション滑らかさ
- メモリ使用量・リーク検証
- バックグラウンド・フォアグラウンド遷移時の応答性

【ユーザビリティ】
- 操作の直感性・分かりやすさ
- エラーメッセージの適切性
- アクセシビリティ対応の完全性

【信頼性】
- 長時間使用でのメモリ安定性
- 権限状態変化への適応性
- アプリクラッシュ耐性・回復性
```

---

この仕様書に基づいて、各項目を1対1でテストコードに落とし込み、実装の正確性を保証します。