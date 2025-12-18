# Phase 15: エラー処理・ポリッシュ設計書

**フェーズ**: 15 / 15  
**Part**: F（仕上げ）  
**前提フェーズ**: Phase 14（UI結合・キャッシュ）

---

## ⚠️ 実装前必読ドキュメント

### 📋 必須参考資料
- **[Product Spec v4.2](../product-spec.md)** - プロダクト仕様書セクション8「エラーハンドリング」
- **[UI Spec v3.2](../ui-spec.md)** - UI設計仕様書セクション10「特殊状態」

### 🔧 iOS専用資料
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準
- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX設計原則

### ✅ 実装完了後の必須作業
```bash
swiftlint
swift-format --lint --recursive ios/
swift test
```

---

## このフェーズで実現すること

エッジケース対応とUXの仕上げを行い、MVPを完成させます。

1. **エラーハンドリング**: 各種エラー画面の実装
2. **ローディング表示**: 0.4秒ルール（Doherty Threshold）対応
3. **アニメーション**: 画面遷移・マイクロインタラクション
4. **最終調整**: パフォーマンス最適化、アクセシビリティ対応

---

## 完了条件

- [ ] HealthKitデータ不足画面が表示される
- [ ] 位置情報取得失敗時に都市選択ダイアログが表示される
- [ ] オフライン画面が適切に表示される
- [ ] ローディングインジケーターが0.4秒ルールに従う
- [ ] 画面遷移アニメーションが滑らか
- [ ] カードタップ時のフィードバックがある
- [ ] VoiceOverで全画面がナビゲート可能
- [ ] メモリリークがない

---

## ═══════════════════════════════════════
## MVP 完成ライン
## ═══════════════════════════════════════

---

## 1. エラーハンドリング

### 1.1 HealthKitデータ不足画面

```swift
// Features/Error/Views/HealthKitDataMissingView.swift
struct HealthKitDataMissingView: View {
    let onOpenSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // アイコン
            Image(systemName: "applewatch")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            // タイトル
            Text("ヘルスケアデータが不足しています")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // 説明
            Text("Apple Watchを装着して、数日間データを記録してください。より精度の高いアドバイスをお届けできるようになります。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // ボタン
            Button(action: onOpenSettings) {
                Text("設定を確認する")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }
}
```

### 1.2 位置情報取得失敗画面

```swift
// Features/Error/Views/LocationErrorView.swift
struct LocationErrorView: View {
    @State private var selectedCity: String = ""
    let cities = ["東京", "大阪", "名古屋", "福岡", "札幌", "仙台", "広島", "京都"]
    let onCitySelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // アイコン
            Image(systemName: "location.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            // タイトル
            Text("位置情報を取得できませんでした")
                .font(.headline)
            
            // 説明
            Text("天気情報を取得するため、お住まいの都市を選択してください。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // 都市選択
            Picker("都市を選択", selection: $selectedCity) {
                Text("選択してください").tag("")
                ForEach(cities, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 24)
            
            // 確定ボタン
            Button(action: {
                if !selectedCity.isEmpty {
                    onCitySelected(selectedCity)
                }
            }) {
                Text("設定")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedCity.isEmpty ? Color.gray : Color.primary)
                    .cornerRadius(12)
            }
            .disabled(selectedCity.isEmpty)
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 32)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 24)
    }
}
```

### 1.3 オフライン画面

```swift
// Features/Error/Views/OfflineView.swift
struct OfflineView: View {
    let cachedAdvice: DailyAdvice?
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // バナー
            HStack {
                Image(systemName: "wifi.slash")
                Text("インターネット接続がありません")
                    .font(.subheadline)
                Spacer()
                Button("再試行", action: onRetry)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
            }
            .foregroundColor(.white)
            .padding(12)
            .background(Color.orange)
            
            if let advice = cachedAdvice {
                // 前日のアドバイスを表示
                ScrollView {
                    VStack(spacing: 16) {
                        Text("前日のアドバイスを表示しています")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        // 既存のアドバイス表示
                        AdviceSummaryCard(advice: advice, onTap: {})
                    }
                    .padding()
                }
            } else {
                // キャッシュなし
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "icloud.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("キャッシュされたデータがありません")
                        .font(.headline)
                    Text("インターネットに接続して、アドバイスを取得してください。")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding()
            }
        }
    }
}
```

### 1.4 一般エラー画面

```swift
// Features/Error/Views/GeneralErrorView.swift
struct GeneralErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("エラーが発生しました")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: onRetry) {
                Text("再試行")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.primary)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
    }
}
```

---

## 2. ローディング表示

### 2.1 Doherty Threshold（0.4秒ルール）

```swift
// Shared/Components/DelayedLoadingView.swift
struct DelayedLoadingView<Content: View>: View {
    let isLoading: Bool
    let delay: TimeInterval
    let content: () -> Content
    
    @State private var showLoading = false
    
    init(
        isLoading: Bool,
        delay: TimeInterval = 0.4,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isLoading = isLoading
        self.delay = delay
        self.content = content
    }
    
    var body: some View {
        ZStack {
            content()
                .opacity(showLoading ? 0.5 : 1.0)
            
            if showLoading {
                LoadingIndicatorView()
            }
        }
        .onChange(of: isLoading) { newValue in
            if newValue {
                // 0.4秒後にローディング表示
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if isLoading {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showLoading = true
                        }
                    }
                }
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showLoading = false
                }
            }
        }
    }
}
```

### 2.2 ローディングインジケーター

```swift
// Shared/Components/LoadingIndicatorView.swift
struct LoadingIndicatorView: View {
    let message: String
    
    init(message: String = "読み込み中...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

// アドバイス生成時の特別なローディング
struct AdviceGeneratingView: View {
    @State private var dots = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // アニメーションするアイコン
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.primary)
                .symbolEffect(.pulse)
            
            Text("あなた専用のアドバイスを準備中\(dots)")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("HealthKitデータと天気情報を分析しています")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            animateDots()
        }
    }
    
    private func animateDots() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            dots = dots.count >= 3 ? "" : dots + "."
        }
    }
}
```

### 2.3 スケルトンスクリーン

```swift
// Shared/Components/SkeletonView.swift
struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 200 : -200)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// スケルトンカード
struct SkeletonCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView()
                .frame(height: 24)
                .cornerRadius(4)
            
            SkeletonView()
                .frame(height: 16)
                .cornerRadius(4)
            
            SkeletonView()
                .frame(width: 200, height: 16)
                .cornerRadius(4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
```

---

## 3. アニメーション

### 3.1 画面遷移

```swift
// 詳細画面への遷移（右からスライドイン）
.navigationDestination(isPresented: $showDetail) {
    DetailView()
        .transition(.move(edge: .trailing))
}

// モーダル表示（下からスライドアップ）
.sheet(isPresented: $showModal) {
    ModalView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
```

### 3.2 カードタップフィードバック

```swift
// Shared/Components/TappableCard.swift
struct TappableCard<Content: View>: View {
    let action: () -> Void
    let content: () -> Content
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            content()
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
```

### 3.3 マイクロインタラクション

```swift
// スコア表示のアニメーション
struct AnimatedScoreView: View {
    let score: Int
    @State private var animatedScore: Int = 0
    
    var body: some View {
        Text("\(animatedScore)")
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedScore = score
                }
            }
    }
}

// プログレスバーのアニメーション
struct AnimatedProgressBar: View {
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary)
                    .frame(width: geometry.size.width * animatedProgress)
            }
        }
        .frame(height: 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animatedProgress = progress
            }
        }
    }
}
```

---

## 4. アクセシビリティ対応

### 4.1 VoiceOver対応

```swift
// ラベルとヒントの追加
CircadianCircleView(data: data)
    .accessibilityLabel("24時間サーカディアンサークル")
    .accessibilityValue("HRV \(Int(data.hrv.currentValue))ミリ秒、7日平均より\(data.hrv.differenceText)")
    .accessibilityHint("ダブルタップで詳細を表示")

// グループ化
VStack {
    Text("睡眠")
    Text("7.2時間")
    Text("回復に貢献")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("睡眠 7.2時間、回復に貢献")
```

### 4.2 Dynamic Type対応

```swift
// スケーラブルフォント
Text(advice.greeting)
    .font(.title2)
    .minimumScaleFactor(0.7)
    .lineLimit(2)

// 固定サイズが必要な場合
Text("HRV")
    .font(.system(size: 14, design: .rounded))
    .environment(\.sizeCategory, .medium)  // サイズ固定
```

### 4.3 カラーコントラスト

```swift
// コントラスト比を確保
Text(status)
    .foregroundColor(Color.primary)  // 常に十分なコントラスト
    .background(Color(.systemBackground))

// ステータス色は背景とセットで使用
HStack {
    Circle()
        .fill(statusColor)
        .frame(width: 8, height: 8)
    Text(statusText)
        .foregroundColor(.primary)  // テキストは常にプライマリ
}
```

---

## 5. パフォーマンス最適化

### 5.1 メモリリーク対策

```swift
// 弱参照の使用
class ConditionViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// Task のキャンセル
struct HomeView: View {
    @State private var loadTask: Task<Void, Never>?
    
    var body: some View {
        // ...
    }
    .onAppear {
        loadTask = Task { await viewModel.loadAdvice() }
    }
    .onDisappear {
        loadTask?.cancel()
    }
}
```

### 5.2 画像の最適化

```swift
// 非同期画像読み込み
AsyncImage(url: imageURL) { phase in
    switch phase {
    case .empty:
        SkeletonView()
    case .success(let image):
        image.resizable().scaledToFit()
    case .failure:
        Image(systemName: "photo")
    @unknown default:
        EmptyView()
    }
}

// 画像キャッシュ
let cache = URLCache(
    memoryCapacity: 50_000_000,  // 50MB
    diskCapacity: 100_000_000    // 100MB
)
```

### 5.3 リスト最適化

```swift
// LazyVStack の使用
ScrollView {
    LazyVStack(spacing: 16) {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
}

// ID による差分更新
ForEach(factors, id: \.type) { factor in
    FactorRowView(factor: factor)
}
```

---

## 6. 最終チェックリスト

### UI/UX確認

- [ ] 全画面がUI Spec v3.2に準拠
- [ ] カラーがデザインシステムに準拠
- [ ] 余白とスペーシングが統一
- [ ] フォントサイズの階層が明確
- [ ] タップターゲットが44pt以上

### 機能確認

- [ ] オンボーディングが完了する
- [ ] アドバイスが生成・表示される
- [ ] コンディション画面が表示される
- [ ] 詳細画面への遷移が動作する
- [ ] 設定画面が動作する

### エラーケース確認

- [ ] オフライン時の動作
- [ ] HealthKitデータ不足時の動作
- [ ] 位置情報取得失敗時の動作
- [ ] APIエラー時の動作

### パフォーマンス確認

- [ ] 起動時間が3秒以内
- [ ] 画面遷移が滑らか
- [ ] メモリ使用量が適切
- [ ] バッテリー消費が適切

### アクセシビリティ確認

- [ ] VoiceOverで全画面ナビゲート可能
- [ ] Dynamic Typeで崩れない
- [ ] カラーコントラスト比が適切

---

## ディレクトリ構造（追加分）

```
ios/TempoAI/
├── Features/
│   └── Error/
│       └── Views/
│           ├── HealthKitDataMissingView.swift
│           ├── LocationErrorView.swift
│           ├── OfflineView.swift
│           └── GeneralErrorView.swift
└── Shared/
    └── Components/
        ├── DelayedLoadingView.swift
        ├── LoadingIndicatorView.swift
        ├── SkeletonView.swift
        └── TappableCard.swift
```

---

## MVP完成後の次のステップ

Phase 15完了後、以下の手順でリリース準備を進めます：

1. **TestFlight配布**
   - 内部テスター向けビルド
   - フィードバック収集

2. **App Store申請準備**
   - スクリーンショット作成
   - App Store説明文作成
   - プライバシーポリシー準備
   - HealthKit使用理由の説明文

3. **App Store申請**
   - レビューガイドライン確認
   - 申請・審査対応

---

## 関連ドキュメント

- `ui-spec.md` - セクション10「特殊状態」、セクション12「インタラクションと動線」
- `product-spec.md` - セクション8「エラーハンドリング」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-19 | 初版作成 |

---

## ═══════════════════════════════════════
## 🎉 MVP 完成
## ═══════════════════════════════════════
