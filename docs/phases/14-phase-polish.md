# Phase 14: ポリッシュ設計書

**フェーズ**: 14 / 14  
**Part**: D（仕上げ）  
**前提フェーズ**: Phase 10〜13（結合・エラーハンドリング完了後）

---

## このフェーズで実現すること

1. **ローディング表示**（Doherty Threshold: 0.4秒ルール適用）
2. **タップフィードバック**（視覚的反応）
3. **画面遷移アニメーション**の調整
4. **マイクロインタラクション**の追加
5. **最終調整**（余白、カラー、フォント）

---

## 完了条件

- [ ] 0.4秒以内の応答ではローディングが表示されない
- [ ] 0.4秒を超える処理ではローディングが表示される
- [ ] 全てのボタン・カードにタップフィードバックがある
- [ ] 画面遷移がスムーズにアニメーションする
- [ ] 追加アドバイスが柔らかくフェードイン/アウトする
- [ ] UI仕様書のチェックリストを全てパスする

---

## ローディング表示

### Doherty Thresholdの適用

**原則**: 0.4秒（400ms）以内に応答があればローディングは表示しない。

```swift
struct DelayedLoadingView<Content: View>: View {
    let isLoading: Bool
    let delay: TimeInterval = 0.4
    let content: () -> Content
    
    @State private var showLoading = false
    
    var body: some View {
        ZStack {
            content()
            
            if showLoading {
                LoadingOverlay()
                    .transition(.opacity)
            }
        }
        .onChange(of: isLoading) { _, newValue in
            if newValue {
                // 0.4秒後にローディング表示
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if isLoading {
                        withAnimation(.easeIn(duration: 0.2)) {
                            showLoading = true
                        }
                    }
                }
            } else {
                // 即座に非表示
                withAnimation(.easeOut(duration: 0.15)) {
                    showLoading = false
                }
            }
        }
    }
}
```

### ローディング表示のデザイン

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│           [スピナー]                │
│        （回転アニメーション）        │
│                                     │
│      アドバイスを生成中...          │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

**スタイル**:
- スピナー: Primary Color
- メッセージ: Secondary Text、小さめの文字
- 背景: 半透明のオーバーレイ（既存コンテンツを薄暗く）

### 適用箇所

| 画面/処理 | ローディング表示 |
|----------|-----------------|
| アドバイス生成 | 「アドバイスを生成中...」 |
| オンボーディング画面7 | 「データを準備中...」（Labor Illusion適用） |
| 設定保存 | 表示なし（即座に完了する想定） |
| 詳細画面遷移 | 表示なし（ローカルデータなので即座） |

---

## タップフィードバック

### ボタンのフィードバック

**視覚的変化**:
- タップダウン時: 少し縮む（scale: 0.96）+ 色が少し濃くなる
- タップアップ時: 元に戻る

```swift
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// 使用例
Button("次へ") {
    // action
}
.buttonStyle(ScaleButtonStyle())
```

### カードのフィードバック

**視覚的変化**:
- タップダウン時: 少し縮む（scale: 0.98）+ 背景色が少し暗くなる
- タップアップ時: 元に戻る

```swift
struct TappableCard<Content: View>: View {
    let action: () -> Void
    let content: () -> Content
    
    @State private var isPressed = false
    
    var body: some View {
        content()
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .brightness(isPressed ? -0.03 : 0)
            )
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}
```

### 適用箇所

| 要素 | フィードバック |
|------|---------------|
| プライマリボタン（「次へ」「保存」等） | scale + opacity |
| セカンダリボタン（「スキップ」等） | opacity のみ |
| アドバイスサマリーカード | scale + brightness |
| メトリクスカード | scale + brightness |
| 今日のトライカード | scale + brightness |
| 今週のトライカード | scale + brightness |
| 設定項目の行 | 背景色変化 |
| 関心ごとタグ | scale + border強調 |

---

## 画面遷移アニメーション

### Push遷移（詳細画面へ）

**アニメーション**: 右からスライドイン

```swift
.navigationTransition(.slide)

// または カスタム実装
struct SlideTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isActive ? 0 : UIScreen.main.bounds.width)
            .animation(.easeOut(duration: 0.3), value: isActive)
    }
}
```

**タイミング**:
- Duration: 0.3秒
- Easing: easeOut

### Pop遷移（戻る）

**アニメーション**: 左へスライドアウト

**タイミング**:
- Duration: 0.25秒
- Easing: easeIn

### タブ切り替え

**アニメーション**: クロスフェード（フワッと切り替わる）

```swift
TabView(selection: $selectedTab) {
    HomeView()
        .tag(Tab.home)
    SettingsView()
        .tag(Tab.settings)
}
.animation(.easeInOut(duration: 0.2), value: selectedTab)
```

---

## マイクロインタラクション

### 追加アドバイスのポップアップ

**表示アニメーション**:
- 下からスライドイン + フェードイン
- Duration: 0.35秒
- Easing: spring（軽いバウンス）

```swift
struct AdditionalAdvicePopup: View {
    @Binding var isVisible: Bool
    let advice: AdditionalAdvice
    let onDismiss: () -> Void
    
    var body: some View {
        VStack { /* content */ }
            .offset(y: isVisible ? 0 : 100)
            .opacity(isVisible ? 1 : 0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.8),
                value: isVisible
            )
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height < -50 {
                            // 上スワイプで閉じる
                            withAnimation {
                                isVisible = false
                            }
                            onDismiss()
                        }
                    }
            )
    }
}
```

**非表示アニメーション**:
- 上へスライドアウト + フェードアウト（上スワイプ時）
- または フェードアウトのみ（×ボタン時）

### メトリクスカードの数値変化

数値が更新された際に、数値がカウントアップするようなアニメーション（将来的な拡張）:

```swift
// v1.1以降で検討
struct AnimatedNumber: View {
    let value: Int
    
    @State private var displayedValue: Int = 0
    
    var body: some View {
        Text("\(displayedValue)%")
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    displayedValue = value
                }
            }
    }
}
```

### プログレスバーのアニメーション

メトリクスカードのプログレスバーが滑らかに伸びる:

```swift
struct AnimatedProgressBar: View {
    let progress: Double // 0.0 - 1.0
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                
                // 進捗
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primaryColor)
                    .frame(width: geometry.size.width * animatedProgress)
            }
        }
        .frame(height: 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animatedProgress = progress
            }
        }
    }
}
```

### オンボーディング進捗表示

進捗インジケーター（1/7 → 2/7）のドットが滑らかに移動:

```swift
struct OnboardingProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.primaryColor : Color.gray.opacity(0.3))
                    .frame(width: step == currentStep ? 10 : 8, height: step == currentStep ? 10 : 8)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }
}
```

---

## 最終調整

### 余白の確認

| 要素 | 確認ポイント |
|------|-------------|
| 画面端のパディング | 左右に十分な余白（16-20pt程度） |
| カード間のスペース | 適度な間隔（12-16pt程度） |
| カード内のパディング | 内容が窮屈でないか（16pt程度） |
| セクション間のスペース | 区切りが明確か（24-32pt程度） |
| ボタンの内部余白 | タップしやすいサイズか |

### カラーの確認

| 確認項目 | 詳細 |
|---------|------|
| Primary Color一貫性 | 全画面でSoft Sage Greenが使われているか |
| テキストカラー階層 | Primary/Secondary/Tertiaryが適切に使い分けられているか |
| 背景色の統一 | Primary Background / Card Backgroundの使い分け |
| アクセントカラー | CTAボタンにSoft Coralが使われているか |
| コントラスト | 読みやすいコントラストが確保されているか |

### フォントの確認

| 確認項目 | 詳細 |
|---------|------|
| 階層の明確さ | 見出し(大) > 見出し(中) > 見出し(小) > 本文 > キャプション |
| 太さの使い分け | 見出しは太字、本文はレギュラー |
| 行間 | 本文は読みやすい行間（1.4〜1.6倍程度） |
| 日本語フォント | システムフォント（ヒラギノ）で問題ないか |

---

## UI仕様書チェックリストの確認

Phase 14完了時に、以下のチェックリストを全てパスすること:

### 全般

- [ ] カラーは統一されているか
- [ ] 余白は十分にあるか
- [ ] 文字サイズの階層は明確か

### ホーム画面

- [ ] 時間帯別の挨拶が正しく表示されるか
- [ ] 追加アドバイスが13:00/18:00以降に正しく表示されるか
- [ ] メトリクスカードが4つ表示されるか
- [ ] 今週のトライが月曜のみ目立つ表示になっているか

### 詳細画面

- [ ] 戻るボタンが左上にあるか
- [ ] スクロール可能か
- [ ] ナビゲーションバーは固定されているか

### オンボーディング

- [ ] 進捗表示が正しく表示されるか
- [ ] 入力検証が動作するか
- [ ] 権限リクエストが正しく動作するか

### インタラクション

- [ ] ボタンのタップ時に視覚的フィードバックがあるか
- [ ] 画面遷移のアニメーションはスムーズか
- [ ] ローディングは0.4秒後に表示されるか

### トーン

- [ ] ニックネームで呼びかけているか
- [ ] 語尾は優しいトーンか
- [ ] データに言及しているか

### エラーハンドリング

- [ ] HealthKitデータ不足時のエラー画面が表示されるか
- [ ] オフライン時のフォールバック動作が正しいか
- [ ] 位置情報取得失敗時に手動選択ができるか

---

## パフォーマンス確認

### アニメーションのパフォーマンス

- [ ] 60fpsで滑らかに動作するか
- [ ] 古いデバイス（iPhone SE等）でもカクつかないか
- [ ] メモリリークがないか

### 起動時間

- [ ] コールドスタート: 2秒以内に初期画面表示
- [ ] ウォームスタート: 0.5秒以内に復帰

### バッテリー消費

- [ ] アニメーションが過度にバッテリーを消費していないか
- [ ] バックグラウンドで不要な処理が動いていないか

---

## 最終確認項目

### デバイス別確認

| デバイス | 確認ポイント |
|---------|-------------|
| iPhone SE（小画面） | レイアウト崩れがないか |
| iPhone 15 Pro（標準） | 基準動作の確認 |
| iPhone 15 Pro Max（大画面） | 余白が適切か |

### ダークモード対応（将来）

MVP段階ではライトモードのみ。v1.1以降でダークモード対応を検討。

### アクセシビリティ（将来）

- VoiceOver対応
- Dynamic Type対応
- コントラスト調整

---

## 成果物

Phase 14完了時の成果物:

1. **MVP品質のアプリ** - 全機能が動作し、UIがポリッシュされた状態
2. **チェックリスト結果** - UI仕様書のチェックリストの確認結果
3. **既知の課題リスト** - v1.1以降で対応する項目のリスト

---

## 関連ドキュメント

- `ui-spec.md` - 全セクション（特にセクション10, 11）
- `product-spec.md` - 付録B「チェックリスト」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
