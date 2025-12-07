# TempoAI UI/UX 大幅刷新計画書

## 目次

1. [エグゼクティブサマリー](#エグゼクティブサマリー)
2. [現状分析と課題](#現状分析と課題)
3. [デザイン哲学と原則](#デザイン哲学と原則)
4. [デザインシステム仕様](#デザインシステム仕様)
5. [画面別詳細設計](#画面別詳細設計)
6. [実装ガイドライン](#実装ガイドライン)
7. [段階的実装計画](#段階的実装計画)
8. [品質保証とテスト](#品質保証とテスト)

---

## エグゼクティブサマリー

### プロジェクト概要

TempoAI の UI/UX を心理学的原則に基づいて大幅に刷新し、ユーザーエンゲージメントと満足度を向上させる包括的なリデザインプロジェクト。

### 核心コンセプト

**"Mindful Health Companion"** - 洗練されたミニマルデザインで、ユーザーの健康改善への長期的なコミットメントを心理学的にサポートする。

### 主要目標

- **エンゲージメント向上**: DAU/MAU 比率を 20%向上
- **認知負荷軽減**: Progressive Disclosure による情報の段階的表示
- **感情的つながり強化**: マイクロインタラクションと達成感の演出
- **アクセシビリティ**: WCAG 2.1 AAA 準拠

---

## 現状分析と課題

### 現 UI の問題点

#### 1. 視覚的階層の欠如

- 全ての情報が同じ重みで表示
- ユーザーの注意が分散
- 重要情報が埋もれている

#### 2. エモーショナルデザインの不足

- 機械的で冷たい印象
- 達成感や進捗を感じにくい
- ユーザーとの感情的つながりが希薄

#### 3. インタラクションの貧弱さ

- 静的な UI 要素
- フィードバックの欠如
- 予測可能性の低さ

#### 4. 情報過多

- 一度に多くの情報を提示
- コンテキストに応じた調整なし
- 認知的負荷が高い

### 心理学的課題

- **Hick's Law 違反**: 選択肢が多すぎる
- **Miller's Law 違反**: 7±2 を超える情報量
- **Peak-End Rule 未活用**: 印象的な終了体験なし

---

## デザイン哲学と原則

### コアプリンシプル

#### 1. Cognitive Load Management（認知負荷管理）

```
原則:
- 一度に提示する情報は5個以下
- 重要度による視覚的階層
- コンテキストに応じた情報フィルタリング

実装:
- Progressive Disclosure
- 折りたたみ可能なセクション
- スマートな情報優先順位付け
```

#### 2. Emotional Design（感情的デザイン）

```
原則:
- ポジティブな感情の喚起
- 達成感と進捗の可視化
- パーソナルな体験の提供

実装:
- 祝福アニメーション
- 進捗ビジュアライゼーション
- パーソナライズされたメッセージ
```

#### 3. Predictability & Control（予測可能性と制御）

```
原則:
- 一貫したインタラクションパターン
- 即座のフィードバック
- ユーザーコントロールの維持

実装:
- 標準化されたジェスチャー
- リアルタイムレスポンス
- 元に戻す/やり直し機能
```

---

## デザインシステム仕様

### カラーシステム

#### プライマリパレット（白黒基調）

```swift
enum ColorPalette {
    // Blacks
    static let pureBlack = Color(hex: "#000000")      // 最重要テキスト
    static let richBlack = Color(hex: "#0A0A0A")      // プライマリテキスト
    static let charcoal = Color(hex: "#1C1C1E")      // セカンダリ背景

    // Grays (5段階)
    static let gray900 = Color(hex: "#2C2C2E")       // ボーダー・ディバイダー
    static let gray700 = Color(hex: "#48484A")       // 非アクティブ要素
    static let gray500 = Color(hex: "#636366")       // セカンダリテキスト
    static let gray300 = Color(hex: "#8E8E93")       // プレースホルダー
    static let gray100 = Color(hex: "#C7C7CC")       // 薄い背景

    // Whites
    static let pureWhite = Color(hex: "#FFFFFF")     // プライマリ背景
    static let offWhite = Color(hex: "#FAFAFA")      // カード背景
    static let pearl = Color(hex: "#F2F2F7")         // セクション背景
}
```

#### セマンティックカラー（最小限使用）

```swift
enum SemanticColors {
    // 成功・達成
    static let success = Color(hex: "#34C759")
    static let successBackground = Color(hex: "#34C759").opacity(0.1)

    // 警告・注意
    static let warning = Color(hex: "#FF9500")
    static let warningBackground = Color(hex: "#FF9500").opacity(0.1)

    // エラー・緊急
    static let error = Color(hex: "#FF3B30")
    static let errorBackground = Color(hex: "#FF3B30").opacity(0.1)

    // 情報・ニュートラル
    static let info = Color(hex: "#007AFF")
    static let infoBackground = Color(hex: "#007AFF").opacity(0.1)
}
```

### タイポグラフィシステム

```swift
enum Typography {
    // Display
    case hero           // SF Pro Display Bold, 34pt, 行間41pt
    case title          // SF Pro Display Semibold, 28pt, 行間34pt

    // Text
    case headline       // SF Pro Text Semibold, 20pt, 行間25pt
    case body           // SF Pro Text Regular, 17pt, 行間22pt
    case callout        // SF Pro Text Regular, 16pt, 行間21pt
    case subhead        // SF Pro Text Regular, 15pt, 行間20pt
    case footnote       // SF Pro Text Regular, 13pt, 行間18pt
    case caption        // SF Pro Text Regular, 12pt, 行間16pt

    // Special
    case monoDigits     // SF Mono Regular, サイズ可変

    var font: Font {
        switch self {
        case .hero: return .system(size: 34, weight: .bold, design: .default)
        case .title: return .system(size: 28, weight: .semibold, design: .default)
        case .headline: return .system(size: 20, weight: .semibold, design: .default)
        case .body: return .system(size: 17, weight: .regular, design: .default)
        case .callout: return .system(size: 16, weight: .regular, design: .default)
        case .subhead: return .system(size: 15, weight: .regular, design: .default)
        case .footnote: return .system(size: 13, weight: .regular, design: .default)
        case .caption: return .system(size: 12, weight: .regular, design: .default)
        case .monoDigits: return .system(.body, design: .monospaced)
        }
    }
}
```

### スペーシングシステム

```swift
enum Spacing {
    static let xxs: CGFloat = 2   // 極小間隔
    static let xs: CGFloat = 4    // 最小間隔
    static let sm: CGFloat = 8    // 小間隔
    static let md: CGFloat = 16   // 標準間隔
    static let lg: CGFloat = 24   // 大間隔
    static let xl: CGFloat = 32   // 特大間隔
    static let xxl: CGFloat = 48  // 最大間隔
    static let huge: CGFloat = 64 // 巨大間隔
}
```

### コーナーラジアス

```swift
enum CornerRadius {
    static let xs: CGFloat = 4    // ボタン内要素
    static let sm: CGFloat = 8    // 小コンポーネント
    static let md: CGFloat = 12   // カード
    static let lg: CGFloat = 16   // モーダル
    static let xl: CGFloat = 20   // 大型カード
    static let full: CGFloat = .infinity // 完全円形
}
```

### 影（エレベーション）

```swift
enum Elevation {
    case none
    case low       // 影: 0 1 3 0 rgba(0,0,0,0.1)
    case medium    // 影: 0 2 6 0 rgba(0,0,0,0.15)
    case high      // 影: 0 4 12 0 rgba(0,0,0,0.2)
    case overlay   // 影: 0 8 24 0 rgba(0,0,0,0.25)

    var shadow: Shadow {
        switch self {
        case .none: return Shadow(color: .clear, radius: 0)
        case .low: return Shadow(color: .black.opacity(0.1), radius: 3, y: 1)
        case .medium: return Shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        case .high: return Shadow(color: .black.opacity(0.2), radius: 12, y: 4)
        case .overlay: return Shadow(color: .black.opacity(0.25), radius: 24, y: 8)
        }
    }
}
```

---

## 画面別詳細設計

### 1. ホーム画面

#### 構造設計

```
┌─────────────────────────┐
│   ダイナミックヘッダー    │ <- 時間帯対応グリーティング
├─────────────────────────┤
│                         │
│   ヘルススコアリング      │ <- 大型円形プログレス
│    (アニメーション)       │
│                         │
├─────────────────────────┤
│   優先アドバイスカード    │ <- 最重要1件を強調
├─────────────────────────┤
│   セカンダリアドバイス    │ <- 折りたたみ可能
│     (Expandable)        │
├─────────────────────────┤
│   クイックアクション      │ <- フローティングボタン
└─────────────────────────┘
```

#### コンポーネント仕様

##### ダイナミックヘッダー

```swift
struct DynamicHeader: View {
    @State private var greeting: String
    @State private var aiMessage: String

    // 時間帯別メッセージ
    private var timeBasedContent: (greeting: String, message: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return ("おはようございます", "素晴らしい一日の始まりです")
        case 12..<17:
            return ("こんにちは", "午後も健康的に過ごしましょう")
        case 17..<22:
            return ("こんばんは", "今日一日お疲れ様でした")
        default:
            return ("おやすみなさい", "良質な睡眠を")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(greeting)
                .font(Typography.title.font)
                .foregroundColor(ColorPalette.richBlack)

            Text(aiMessage)
                .font(Typography.subhead.font)
                .foregroundColor(ColorPalette.gray500)
        }
        .animation(.easeInOut(duration: 0.6))
    }
}
```

##### ヘルススコアリング

```swift
struct HealthScoreRing: View {
    let score: Double // 0.0 - 1.0
    @State private var animatedScore: Double = 0

    var body: some View {
        ZStack {
            // 背景リング
            Circle()
                .stroke(ColorPalette.gray100, lineWidth: 20)

            // プログレスリング
            Circle()
                .trim(from: 0, to: animatedScore)
                .stroke(
                    LinearGradient(
                        colors: scoreGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(dampingFraction: 0.8))

            // スコア表示
            VStack(spacing: Spacing.xs) {
                Text("\(Int(score * 100))")
                    .font(Typography.hero.font)
                    .foregroundColor(ColorPalette.richBlack)

                Text("健康スコア")
                    .font(Typography.caption.font)
                    .foregroundColor(ColorPalette.gray500)
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animatedScore = score
            }
        }
    }

    private var scoreGradient: [Color] {
        switch score {
        case 0.8...1.0:
            return [SemanticColors.success, SemanticColors.success.opacity(0.8)]
        case 0.6..<0.8:
            return [SemanticColors.warning, SemanticColors.warning.opacity(0.8)]
        default:
            return [SemanticColors.error, SemanticColors.error.opacity(0.8)]
        }
    }
}
```

### 2. オンボーディングフロー

#### 新フロー構造（5 ページ）

##### ページ 1: ウェルカム＆言語選択

```swift
struct WelcomeLanguagePage: View {
    @State private var selectedLanguage: String = "ja"
    @State private var logoScale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // アニメーションロゴ
            Image("TempoAILogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(logoScale)
                .onAppear {
                    withAnimation(.spring(dampingFraction: 0.6).delay(0.3)) {
                        logoScale = 1.0
                    }
                }

            Text("Tempo AI")
                .font(Typography.hero.font)
                .foregroundColor(ColorPalette.richBlack)

            Text("あなたの健康パートナー")
                .font(Typography.body.font)
                .foregroundColor(ColorPalette.gray500)

            Spacer()

            // 言語選択
            HStack(spacing: Spacing.md) {
                LanguageButton(
                    language: "日本語",
                    code: "ja",
                    isSelected: selectedLanguage == "ja"
                ) {
                    selectedLanguage = "ja"
                }

                LanguageButton(
                    language: "English",
                    code: "en",
                    isSelected: selectedLanguage == "en"
                ) {
                    selectedLanguage = "en"
                }
            }

            ContinueButton(action: nextPage)
        }
        .padding(Spacing.lg)
    }
}
```

##### ページ 2: 価値提案（インタラクティブ）

```swift
struct ValuePropositionPage: View {
    @State private var currentFeature = 0
    let features = [
        ("heart.fill", "健康データ分析", "HealthKitと連携して包括的な健康状態を把握"),
        ("cloud.sun.fill", "天候対応アドバイス", "その日の天気に合わせた健康アドバイス"),
        ("sparkles", "AI パーソナライゼーション", "あなただけの健康プランを毎日生成")
    ]

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // パララックス背景
            ParallaxBackground()

            // フィーチャーカルーセル
            TabView(selection: $currentFeature) {
                ForEach(0..<features.count, id: \.self) { index in
                    FeatureCard(
                        icon: features[index].0,
                        title: features[index].1,
                        description: features[index].2
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 300)

            // インタラクティブデモ
            InteractiveDemo(currentFeature: currentFeature)
        }
    }
}
```

##### ページ 3: パーソナライゼーション

```swift
struct PersonalizationPage: View {
    @State private var healthGoal: HealthGoal = .general
    @State private var notificationTime: Date = Date()
    @State private var activityLevel: ActivityLevel = .moderate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // ヘッダー
                Text("あなたに合わせてカスタマイズ")
                    .font(Typography.title.font)

                // 健康目標
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Label("健康目標", systemImage: "target")
                        .font(Typography.headline.font)

                    ForEach(HealthGoal.allCases) { goal in
                        SelectableCard(
                            title: goal.title,
                            description: goal.description,
                            isSelected: healthGoal == goal
                        ) {
                            withAnimation(.spring()) {
                                healthGoal = goal
                            }
                        }
                    }
                }

                // 通知時間
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Label("アドバイス通知時間", systemImage: "bell")
                        .font(Typography.headline.font)

                    DatePicker(
                        "",
                        selection: $notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                }

                // 活動レベル
                ActivityLevelSelector(selected: $activityLevel)
            }
            .padding(Spacing.lg)
        }
    }
}
```

### 3. アドバイスカード刷新

#### 新デザイン仕様

```swift
struct EnhancedAdviceCard: View {
    let advice: DailyAdvice
    @State private var isExpanded = false
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ヘッダー（常に表示）
            HStack {
                // アイコンとタイトル
                HStack(spacing: Spacing.sm) {
                    Image(systemName: advice.icon)
                        .font(.title2)
                        .foregroundColor(advice.color)

                    Text(advice.title)
                        .font(Typography.headline.font)
                        .foregroundColor(ColorPalette.richBlack)
                }

                Spacer()

                // 展開ボタン
                Button(action: toggleExpansion) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(ColorPalette.gray500)
                }
            }
            .padding(Spacing.md)

            // サマリー（常に表示）
            Text(advice.summary)
                .font(Typography.body.font)
                .foregroundColor(ColorPalette.gray700)
                .lineLimit(isExpanded ? nil : 2)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.sm)

            // 詳細（展開時のみ）
            if isExpanded {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Divider()
                        .padding(.horizontal, Spacing.md)

                    // 詳細コンテンツ
                    ForEach(advice.details, id: \.self) { detail in
                        DetailRow(text: detail)
                    }
                    .padding(.horizontal, Spacing.md)

                    // アクションボタン
                    HStack(spacing: Spacing.sm) {
                        ActionButton(
                            title: "完了",
                            style: .primary
                        ) {
                            markAsComplete()
                        }

                        ActionButton(
                            title: "後で",
                            style: .secondary
                        ) {
                            remindLater()
                        }
                    }
                    .padding(Spacing.md)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .background(ColorPalette.offWhite)
        .cornerRadius(CornerRadius.md)
        .shadow(radius: isExpanded ? 8 : 4)
        .animation(.spring(dampingFraction: 0.8), value: isExpanded)
    }
}
```

---

## 実装ガイドライン

### アニメーション仕様

#### 基本原則

```swift
enum AnimationDuration {
    static let instant: Double = 0.1      // 即座のフィードバック
    static let fast: Double = 0.2         // 小さな状態変化
    static let normal: Double = 0.3       // 標準的な遷移
    static let slow: Double = 0.5         // 重要な変化
    static let emphasis: Double = 0.8     // 強調表現
}

enum AnimationCurve {
    static let easeOut = Animation.timingCurve(0.0, 0.0, 0.2, 1.0)      // 開始
    static let easeIn = Animation.timingCurve(0.4, 0.0, 1.0, 1.0)       // 終了
    static let easeInOut = Animation.timingCurve(0.4, 0.0, 0.2, 1.0)    // 移動
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
}
```

#### マイクロインタラクション実装

```swift
// タップフィードバック
extension View {
    func tapFeedback() -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                // ハプティックフィードバック
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
    }
}

// ローディングスケルトン
struct SkeletonModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.1),
                        Color.gray.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 400 - 200)
                .animation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: phase
                )
            )
            .onAppear { phase = 1 }
    }
}
```

### レスポンシブデザイン

#### デバイス対応

```swift
struct ResponsiveLayout {
    static var columns: Int {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return UIScreen.main.bounds.width > 400 ? 2 : 1
        case .pad:
            return UIScreen.main.bounds.width > 800 ? 4 : 3
        default:
            return 2
        }
    }

    static var padding: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return Spacing.md
        case .pad:
            return Spacing.xl
        default:
            return Spacing.lg
        }
    }
}
```

### パフォーマンス最適化

#### 1. 遅延ローディング

```swift
struct LazyLoadedContent<Content: View>: View {
    let threshold: TimeInterval = 0.4
    let content: () -> Content
    @State private var shouldLoad = false

    var body: some View {
        Group {
            if shouldLoad {
                content()
            } else {
                SkeletonView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + threshold) {
                            shouldLoad = true
                        }
                    }
            }
        }
    }
}
```

#### 2. 画像最適化

```swift
struct OptimizedImage: View {
    let name: String
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            // 画像のリサイズとキャッシュ
            if let originalImage = UIImage(named: name),
               let resized = originalImage.resized(to: CGSize(width: 200, height: 200)) {
                DispatchQueue.main.async {
                    self.image = resized
                }
            }
        }
    }
}
```

---

## 段階的実装計画

### Phase 1: 基盤整備（5 日間）

#### Day 1-2: デザインシステム構築

```markdown
タスク:

- [ ] カラーパレット定義（ColorPalette.swift）
- [ ] タイポグラフィシステム実装（Typography.swift）
- [ ] スペーシングシステム実装（Spacing.swift）
- [ ] 基本コンポーネント作成
  - [ ] ボタンスタイル
  - [ ] カードスタイル
  - [ ] 入力フィールド

成果物:

- DesignSystem/
  ├── Colors.swift
  ├── Typography.swift
  ├── Spacing.swift
  └── Components/
  ├── Buttons.swift
  ├── Cards.swift
  └── Forms.swift
```

#### Day 3-4: アニメーションライブラリ

```markdown
タスク:

- [ ] アニメーション定数定義
- [ ] マイクロインタラクション実装
- [ ] トランジション定義
- [ ] ハプティックフィードバック統合

成果物:

- Animations/
  ├── Constants.swift
  ├── Transitions.swift
  ├── Interactions.swift
  └── Haptics.swift
```

#### Day 5: 基盤テスト

```markdown
タスク:

- [ ] コンポーネントテスト作成
- [ ] アニメーションパフォーマンステスト
- [ ] アクセシビリティ監査

成果物:

- Tests/
  ├── ComponentTests.swift
  ├── AnimationTests.swift
  └── AccessibilityTests.swift
```

### Phase 2: ホーム画面刷新（5 日間）

#### Day 6-7: レイアウト実装

```markdown
タスク:

- [ ] ダイナミックヘッダー実装
- [ ] ヘルススコアリング実装
- [ ] レスポンシブレイアウト対応

成果物:

- Views/Home/
  ├── DynamicHeader.swift
  ├── HealthScoreRing.swift
  └── HomeLayout.swift
```

#### Day 8-9: アドバイスカード刷新

```markdown
タスク:

- [ ] EnhancedAdviceCard 実装
- [ ] 優先度アルゴリズム実装
- [ ] 展開/折りたたみアニメーション

成果物:

- Views/Home/
  ├── EnhancedAdviceCard.swift
  ├── AdvicePrioritizer.swift
  └── AdviceSection.swift
```

#### Day 10: 統合とテスト

```markdown
タスク:

- [ ] コンポーネント統合
- [ ] パフォーマンステスト
- [ ] ユーザビリティテスト

成果物:

- HomeView.swift（更新）
- HomeViewTests.swift
```

### Phase 3: オンボーディング改善（4 日間）

#### Day 11-12: 新フロー実装

```markdown
タスク:

- [ ] 5 ページ構成実装
- [ ] パララックス効果実装
- [ ] インタラクティブデモ実装

成果物:

- Views/Onboarding/
  ├── WelcomeLanguagePage.swift
  ├── ValuePropositionPage.swift
  ├── PersonalizationPage.swift
  ├── PermissionsPage.swift
  └── CelebrationPage.swift
```

#### Day 13: トランジション最適化

```markdown
タスク:

- [ ] ページ間トランジション実装
- [ ] プログレスインジケーター実装
- [ ] スキップ機能実装

成果物:

- OnboardingFlow.swift（更新）
- OnboardingTransitions.swift
```

#### Day 14: セレブレーション実装

```markdown
タスク:

- [ ] 完了アニメーション実装
- [ ] 初回アドバイス生成
- [ ] フィードバック収集

成果物:

- CelebrationAnimation.swift
- FirstAdviceGenerator.swift
```

### Phase 4: 詳細画面改善（3 日間）

#### Day 15-16: データビジュアライゼーション

```markdown
タスク:

- [ ] レーダーチャート実装
- [ ] トレンドグラフ実装
- [ ] 比較バー実装

成果物:

- Visualizations/
  ├── RadarChart.swift
  ├── TrendGraph.swift
  └── ComparisonBar.swift
```

#### Day 17: インタラクション追加

```markdown
タスク:

- [ ] 長押しで詳細表示
- [ ] スワイプで履歴表示
- [ ] ピンチで拡大表示

成果物:

- Interactions/
  ├── LongPressDetail.swift
  ├── SwipeHistory.swift
  └── PinchZoom.swift
```

### Phase 5: 仕上げと最適化（3 日間）

#### Day 18: パフォーマンス最適化

```markdown
タスク:

- [ ] 画像最適化
- [ ] レンダリング最適化
- [ ] メモリ使用量削減
- [ ] 起動時間短縮

チェックリスト:

- [ ] 60fps 維持確認
- [ ] メモリリーク検査
- [ ] バッテリー消費測定
```

#### Day 19: アクセシビリティ

```markdown
タスク:

- [ ] VoiceOver 対応確認
- [ ] Dynamic Type 対応
- [ ] コントラスト比検証
- [ ] タップ領域検証

チェックリスト:

- [ ] WCAG 2.1 AAA 準拠
- [ ] iOS Accessibility Inspector 通過
- [ ] 実機テスト完了
```

#### Day 20: 最終テストとリリース準備

```markdown
タスク:

- [ ] 全機能統合テスト
- [ ] ユーザビリティテスト
- [ ] パフォーマンステスト
- [ ] ドキュメント更新

成果物:

- テストレポート
- リリースノート
- 更新された README
```

---

## 品質保証とテスト

### テスト戦略

#### 1. ユニットテスト

```swift
class DesignSystemTests: XCTestCase {
    func testColorContrast() {
        // WCAG 2.1 AAAコントラスト比テスト
        let textColor = ColorPalette.richBlack
        let backgroundColor = ColorPalette.pureWhite
        let contrastRatio = calculateContrast(textColor, backgroundColor)
        XCTAssertGreaterThanOrEqual(contrastRatio, 7.0)
    }

    func testTypographyHierarchy() {
        // フォントサイズの階層性テスト
        XCTAssertGreaterThan(Typography.hero.size, Typography.title.size)
        XCTAssertGreaterThan(Typography.title.size, Typography.headline.size)
    }
}
```

#### 2. UI テスト

```swift
class HomeViewUITests: XCTestCase {
    func testHealthScoreAnimation() {
        let app = XCUIApplication()
        app.launch()

        // アニメーション完了待機
        let scoreRing = app.otherElements["healthScoreRing"]
        XCTAssertTrue(scoreRing.waitForExistence(timeout: 2))

        // スコア表示確認
        let scoreLabel = scoreRing.staticTexts["scoreLabel"]
        XCTAssertTrue(scoreLabel.exists)
    }
}
```

#### 3. パフォーマンステスト

```swift
class PerformanceTests: XCTestCase {
    func testScrollPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            // スクロールパフォーマンス測定
            let app = XCUIApplication()
            app.launch()
            app.swipeUp(velocity: .fast)
            app.swipeDown(velocity: .fast)
        }
    }
}
```

### 品質メトリクス

#### コード品質

- SwiftLint 準拠率: 100%
- テストカバレッジ: 80%以上
- Cyclomatic Complexity: 10 以下

#### パフォーマンス

- 起動時間: 2 秒以内
- 画面遷移: 300ms 以内
- アニメーション FPS: 60fps 維持
- メモリ使用量: 100MB 以下

#### アクセシビリティ

- VoiceOver 対応: 100%
- Dynamic Type 対応: 全テキスト
- 最小タップ領域: 48x48pt
- コントラスト比: 7:1 以上

### リリースチェックリスト

```markdown
## リリース前チェックリスト

### 機能

- [ ] 全画面の実装完了
- [ ] 全アニメーション動作確認
- [ ] エラーハンドリング確認
- [ ] オフライン対応確認

### 品質

- [ ] 全テストパス
- [ ] メモリリーク 0
- [ ] クラッシュレポート 0
- [ ] パフォーマンス基準達成

### アクセシビリティ

- [ ] VoiceOver テスト完了
- [ ] Dynamic Type テスト完了
- [ ] カラーブラインドテスト完了

### ドキュメント

- [ ] README 更新
- [ ] API ドキュメント更新
- [ ] リリースノート作成
- [ ] スクリーンショット更新
```

---

## 成功指標と KPI

### ビジネス指標

```yaml
エンゲージメント:
  - DAU/MAU比率: 現状40% → 目標60%
  - セッション時間: 現状3分 → 目標5分
  - 離脱率: 現状30% → 目標15%

満足度:
  - App Store評価: 現状3.8 → 目標4.5
  - NPS: 現状30 → 目標50
  - サポート問い合わせ: 20%削減

採用率:
  - オンボーディング完了率: 現状60% → 目標85%
  - 7日継続率: 現状40% → 目標60%
  - 30日継続率: 現状20% → 目標40%
```

### 技術指標

```yaml
パフォーマンス:
  - Time to Interactive: <2秒
  - First Contentful Paint: <1秒
  - Cumulative Layout Shift: <0.1

品質:
  - クラッシュ率: <0.1%
  - ANR率: <0.05%
  - エラー率: <1%
```

---

## 付録

### A. 参照リンク

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [iOS Accessibility Programming Guide](https://developer.apple.com/accessibility/ios/)

### B. ツールとリソース

- Figma: デザインモックアップ
- Principle: プロトタイピング
- Instruments: パフォーマンス分析
- Accessibility Inspector: アクセシビリティテスト

### C. 変更履歴

```markdown
Version 1.0 (2024-12-06)

- 初版作成
- 基本設計とフェーズ計画策定
```

---

このドキュメントは生きた文書として、実装の進捗に応じて継続的に更新されます。
