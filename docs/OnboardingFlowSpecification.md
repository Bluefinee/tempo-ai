# オンボーディングフロー完全仕様書

## 1. 基本フロー（正常系）

### 1.1 初回起動パターン
```
【前提条件】
- アプリ初回インストール
- UserDefaultsにオンボーディング完了フラグなし

【フロー】
アプリ起動 → 言語選択画面(Page 0) → 言語選択 → ウェルカム画面(Page 1) → ... → 完了 → ホーム画面

【各ページでの動作】
Page 0: 言語選択
- 🇯🇵日本語ボタンタップ → 日本語設定 + Page 1へ遷移
- 🇺🇸英語ボタンタップ → 英語設定 + Page 1へ遷移
- 選択した言語でLocalizationManager即座更新
- TabView animation: easeInOut(0.5秒)

Page 1: ウェルカム
- 選択言語でテキスト表示確認
- 「次へ」ボタン → Page 2へ遷移
- 戻るジェスチャー → Page 0へ戻る

Page 2: データソース説明
- 「次へ」ボタン → Page 3へ遷移
- 戻る → Page 1へ

Page 3: AI分析説明
- 「次へ」ボタン → Page 4へ遷移
- 戻る → Page 2へ

Page 4: 日次プラン説明
- 「次へ」ボタン → Page 5へ遷移
- 戻る → Page 3へ

Page 5: HealthKit権限
- 「ヘルスケアへのアクセスを許可」ボタン → システム権限ダイアログ表示
- 権限許可 → ボタン「✓ 許可済み」表示 + 「次へ」活性化
- 権限拒否 → 「スキップして続行」ボタン表示
- 「次へ」ボタン → Page 6へ遷移

Page 6: Location権限 + 完了
- 「位置情報へのアクセスを許可」ボタン → システム権限ダイアログ表示
- 権限許可後 → 「TempoAIを使う」ボタン表示
- 「TempoAIを使う」タップ → オンボーディング完了 + ホーム画面遷移
```

### 1.2 言語切り替えパターン
```
【言語選択時の動作】
1. viewModel.setLanguage()実行
2. UserDefaultsに言語保存
3. LocalizationManager.shared.setLanguage()即座実行
4. 以降の画面で選択言語のテキスト表示
5. アプリ再起動後も言語設定保持
```

## 2. 完了後の動作パターン

### 2.1 オンボーディング完了済みユーザー
```
【前提条件】
- UserDefaults.onboardingCompleted = true

【動作】
アプリ起動 → TempoAIApp.swiftでチェック → 即座にContentView()表示
- OnboardingFlowView()は表示されない
- 言語設定は保存済み設定で表示
```

### 2.2 オンボーディングリセットパターン
```
【リセット操作時】
1. resetOnboarding()実行
2. UserDefaults.onboardingCompleted削除
3. UserDefaults.onboardingStartTime削除  
4. currentPage = 0に設定
5. isOnboardingCompleted = falseに設定

【期待動作】
- 次回アプリ起動時 → OnboardingFlowView表示
- Page 0(言語選択)から開始
- 言語選択画面に留まり、即座に閉じない
```

## 3. 権限関連フロー

### 3.1 HealthKit権限パターン
```
【権限許可の場合】
1. 「ヘルスケアへのアクセスを許可」タップ
2. システム権限ダイアログ表示
3. ユーザーが「許可」選択
4. ボタン表示「✓ ヘルスケア許可済み」
5. healthKitStatus = .granted
6. 「次へ」ボタン活性化

【権限拒否の場合】
1. 「ヘルスケアへのアクセスを許可」タップ
2. システム権限ダイアログ表示
3. ユーザーが「許可しない」選択
4. ボタン表示「スキップして続行」
5. healthKitStatus = .denied
6. 「次へ」ボタン活性化（スキップ可能）

【部分許可の場合】
1. 一部のHealthKitデータのみ許可
2. healthKitStatus = .granted（データアクセス可能のため）
3. 「✓ ヘルスケア許可済み」表示
```

### 3.2 Location権限パターン
```
【権限許可の場合】
1. 「位置情報へのアクセスを許可」タップ
2. システム権限ダイアログ表示
3. ユーザーが「App使用中は許可」選択
4. locationStatus = .granted
5. ボタン表示「TempoAIを使う」
6. 最終完了ボタンとして機能

【権限拒否の場合】
1. ユーザーが「許可しない」選択
2. locationStatus = .denied
3. ボタン表示「位置情報なしで続行」
4. 機能制限ありで継続可能
```

## 4. エラー・例外パターン

### 4.1 アプリライフサイクル中断
```
【オンボーディング途中でアプリ終了】
- 現在のページ位置保存なし
- 次回起動時はPage 0から再開
- 言語設定のみ保持

【オンボーディング途中でバックグラウンド】
- メモリ上の状態保持
- フォアグラウンド復帰時に同じページで継続
- 権限ダイアログ表示中の場合は適切に復帰
```

### 4.2 権限ダイアログ関連エラー
```
【HealthKit利用不可デバイス】
- HKHealthStore.isHealthDataAvailable() = false
- ボタン表示「この端末では利用できません」
- 自動的にスキップ扱い

【システム設定で事前拒否済み】
- 権限ダイアログ表示されない
- 即座に拒否状態として処理
- スキップオプション提供
```

### 4.3 状態不整合パターン
```
【UserDefaults破損】
- デフォルト値で初期化
- オンボーディング再実行

【ViewModelとView状態不一致】
- @Published propertyの更新で自動同期
- onAppearでの状態確認
```

## 5. パフォーマンス・UX考慮

### 5.1 アニメーション・遷移
```
【ページ遷移】
- TabView.pageスタイルによるスワイプ遷移
- 各ボタンタップ時のeaseInOut(0.5秒)アニメーション
- ページインジケーター表示

【ボタン状態変化】
- 権限許可後の即座な表示更新
- ローディング表示（位置情報リクエスト中）
- 無効状態の視覚的表現
```

### 5.2 メモリ・リソース管理
```
【メモリ警告時】
- OnboardingViewModelの状態保持
- 現在ページ位置の保持
- 不要なリソース解放

【大容量画像・動画】
- 現在は使用なし
- 将来的には遅延読み込み実装
```

## 6. 国際化・アクセシビリティ

### 6.1 言語対応
```
【サポート言語】
- 日本語（ja）
- 英語（en）

【言語切り替えタイミング】
- 選択即座に適用
- LocalizationManager経由
- 後続画面で選択言語表示
```

### 6.2 アクセシビリティ
```
【VoiceOver対応】
- 各ボタンの適切なラベル
- ページ遷移の音声案内
- 権限状態の読み上げ

【Dynamic Type対応】
- フォントサイズの自動調整
- レイアウトの動的調整
```

## 7. テスト対応表

### 7.1 UIテスト対応
| 仕様項目 | テストメソッド名 |
|---------|--------------|
| 初回起動→言語選択表示 | `testInitialLaunch_ShowsLanguageSelection()` |
| 日本語選択→ウェルカム遷移 | `testJapaneseSelection_TransitionsToWelcome()` |
| 英語選択→ウェルカム遷移 | `testEnglishSelection_TransitionsToWelcome()` |
| 全ページ順次遷移 | `testPageProgression_AllPages()` |
| 戻るナビゲーション | `testBackNavigation_AllPages()` |
| HealthKit許可フロー | `testHealthKitPermission_Granted()` |
| HealthKit拒否フロー | `testHealthKitPermission_Denied()` |
| Location許可フロー | `testLocationPermission_Granted()` |
| Location拒否フロー | `testLocationPermission_Denied()` |
| リセット後言語選択留まる | `testOnboardingReset_ShowsLanguageAndStays()` |
| 完了済み→ホーム直接遷移 | `testCompletedOnboarding_SkipsToHome()` |
| 言語設定永続化 | `testLanguageSelection_PersistsAcrossRestart()` |
| バックグラウンド状態保持 | `testAppBackgrounding_PreservesState()` |
| メモリ警告対応 | `testMemoryWarning_HandleGracefully()` |
| 連続タップ防止 | `testRapidTapping_NoDoubleTransition()` |

### 7.2 Unitテスト対応
| 仕様項目 | テストメソッド名 |
|---------|--------------|
| リセット時初期状態 | `testResetOnboarding_SetsCorrectInitialState()` |
| 言語変更即座反映 | `testLanguageChange_UpdatesImmediately()` |
| 権限状態UI更新 | `testPermissionStatusChange_UpdatesUI()` |
| 完了状態保存 | `testOnboardingCompletion_PersistsToUserDefaults()` |
| 言語設定保存 | `testLanguageSelection_PersistsToUserDefaults()` |
| 設定復元確認 | `testStateRecovery_FromUserDefaults()` |

## 8. 実装上の注意事項

### 8.1 必須実装事項
- リセット後の言語選択画面で即座に閉じない処理
- @Published プロパティの適切な更新順序
- UserDefaults同期化
- メモリリーク防止

### 8.2 禁止事項
- 同期的な権限リクエスト（必ず非同期で実装）
- UserDefaultsの直接操作（必ずViewModel経由）
- 強制アンラップの使用

### 8.3 推奨事項
- エラーハンドリングの充実
- ログ出力による状態追跡
- テスト容易性を考慮した設計