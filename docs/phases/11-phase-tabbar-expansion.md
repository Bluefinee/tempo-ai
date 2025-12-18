# Phase 11: タブバー拡張設計書

**フェーズ**: 11 / 15  
**Part**: C（新仕様への調整）  
**前提フェーズ**: Phase 2（ホーム画面基本）、Phase 9（ホーム画面シンプル化）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[Product Spec v4.2](../product-spec.md)** - プロダクト仕様書（新仕様）
- **[UI Spec v3.2](../ui-spec.md)** - UI設計仕様書（新仕様）

### 🔧 iOS専用資料
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準
- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX設計原則

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

Phase 2で実装した2タブ構成を、3タブ構成に拡張します。

**変更内容**:
- タブバー: ホーム / 設定 → ホーム / コンディション / 設定
- コンディションタブのプレースホルダー画面を追加

---

## 完了条件

- [ ] タブバーが3つのタブ（ホーム / コンディション / 設定）で構成されている
- [ ] コンディションタブをタップするとプレースホルダー画面が表示される
- [ ] タブアイコンが適切に設定されている
- [ ] タブの選択状態が正しくハイライトされる
- [ ] オンボーディング完了後のデフォルトタブがホームである
- [ ] タブ間の切り替えがスムーズに動作する

---

## 変更前後の比較

### 旧仕様（Phase 2完了時点）

```
┌────────────┬────────────┐
│  🏠 ホーム  │  ⚙️ 設定   │
└────────────┴────────────┘
```

### 新仕様（Phase 11完了後）

```
┌────────────┬────────────┬────────────┐
│  🏠 ホーム  │📊コンディション│  ⚙️ 設定   │
└────────────┴────────────┴────────────┘
```

---

## タブ構成

### タブ一覧

| タブ | アイコン | ラベル | 遷移先 |
|------|----------|--------|--------|
| ホーム | `house.fill` | ホーム | HomeView |
| コンディション | `chart.bar.fill` | コンディション | ConditionView（Phase 12で実装） |
| 設定 | `gearshape.fill` | 設定 | SettingsView |

### タブバーの色指定

| 状態 | 色 |
|------|-----|
| 選択中 | Primary Color（Soft Sage Green） |
| 非選択 | Secondary Text Color |

---

## 実装

### MainTabView の修正

**修正前**:
```swift
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
    }
}
```

**修正後**:
```swift
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab: Hashable {
        case home
        case condition
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            ConditionPlaceholderView()
                .tabItem {
                    Label("コンディション", systemImage: "chart.bar.fill")
                }
                .tag(Tab.condition)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .tint(.primary)  // 選択中タブの色
    }
}
```

### ConditionPlaceholderView の作成

Phase 12で本実装を行うまでの仮画面:

```swift
// Features/Condition/Views/ConditionPlaceholderView.swift

import SwiftUI

struct ConditionPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // アイコン
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                
                // タイトル
                Text("コンディション")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                // 説明
                Text("この画面は現在準備中です")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                // サブテキスト
                Text("あなたの健康状態をより詳しく\n可視化する機能を開発中です")
                    .font(.subheadline)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundPrimary)
            .navigationTitle("コンディション")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ConditionPlaceholderView()
}
```

---

## ディレクトリ構造

### 追加するファイル

```
ios/TempoAI/Features/
├── Condition/
│   └── Views/
│       └── ConditionPlaceholderView.swift  # 新規追加
└── ...
```

### 修正するファイル

```
ios/TempoAI/App/
└── MainTabView.swift  # 修正
```

---

## タブバーのスタイリング

### カスタムタブバーの検討

標準のTabViewでも十分ですが、より細かいカスタマイズが必要な場合:

```swift
struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    
    var body: some View {
        HStack {
            TabBarButton(
                icon: "house.fill",
                label: "ホーム",
                isSelected: selectedTab == .home,
                action: { selectedTab = .home }
            )
            
            TabBarButton(
                icon: "chart.bar.fill",
                label: "コンディション",
                isSelected: selectedTab == .condition,
                action: { selectedTab = .condition }
            )
            
            TabBarButton(
                icon: "gearshape.fill",
                label: "設定",
                isSelected: selectedTab == .settings,
                action: { selectedTab = .settings }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.cardBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.separator),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .primary : .textSecondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
```

### 標準TabViewを使用する場合の設定

```swift
// App/TempoAIApp.swift または MainTabView.swift

init() {
    // タブバーの外観をカスタマイズ
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor.systemBackground
    
    // 選択時の色
    appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primary)
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
        .foregroundColor: UIColor(Color.primary)
    ]
    
    // 非選択時の色
    appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
        .foregroundColor: UIColor.secondaryLabel
    ]
    
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
}
```

---

## 状態管理

### タブ選択状態の保持

```swift
// タブ切り替え時に各画面の状態を保持
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    // 各タブのNavigationPathを保持（必要に応じて）
    @State private var homeNavigationPath = NavigationPath()
    @State private var conditionNavigationPath = NavigationPath()
    @State private var settingsNavigationPath = NavigationPath()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homeNavigationPath) {
                HomeView()
            }
            .tabItem {
                Label("ホーム", systemImage: "house.fill")
            }
            .tag(Tab.home)
            
            NavigationStack(path: $conditionNavigationPath) {
                ConditionPlaceholderView()
            }
            .tabItem {
                Label("コンディション", systemImage: "chart.bar.fill")
            }
            .tag(Tab.condition)
            
            NavigationStack(path: $settingsNavigationPath) {
                SettingsView()
            }
            .tabItem {
                Label("設定", systemImage: "gearshape.fill")
            }
            .tag(Tab.settings)
        }
        .tint(.primary)
    }
}
```

### オンボーディング後のタブ選択

```swift
// ContentView.swift
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()  // デフォルトでホームタブが選択される
        } else {
            OnboardingView(onComplete: {
                hasCompletedOnboarding = true
            })
        }
    }
}
```

---

## アニメーション

### タブ切り替えアニメーション

標準のTabViewは自動的にフェードアニメーションを適用します。

カスタムアニメーションが必要な場合:

```swift
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // 各タブのコンテンツ
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .condition:
                    ConditionPlaceholderView()
                case .settings:
                    SettingsView()
                }
            }
            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
        }
        
        // カスタムタブバー
        VStack {
            Spacer()
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}
```

---

## アクセシビリティ対応

```swift
// タブバーのアクセシビリティラベル
TabView(selection: $selectedTab) {
    HomeView()
        .tabItem {
            Label("ホーム", systemImage: "house.fill")
        }
        .tag(Tab.home)
        .accessibilityLabel("ホームタブ")
        .accessibilityHint("今日のアドバイスを表示します")
    
    ConditionPlaceholderView()
        .tabItem {
            Label("コンディション", systemImage: "chart.bar.fill")
        }
        .tag(Tab.condition)
        .accessibilityLabel("コンディションタブ")
        .accessibilityHint("健康状態のダッシュボードを表示します")
    
    SettingsView()
        .tabItem {
            Label("設定", systemImage: "gearshape.fill")
        }
        .tag(Tab.settings)
        .accessibilityLabel("設定タブ")
        .accessibilityHint("アプリの設定を変更します")
}
```

---

## テスト観点

### UI確認

- [ ] タブバーに3つのタブが表示されている
- [ ] 各タブのアイコンとラベルが正しい
- [ ] 選択中タブがハイライトされている
- [ ] タブ切り替えがスムーズ
- [ ] コンディションタブでプレースホルダーが表示される

### 動作確認

- [ ] アプリ起動時にホームタブが選択されている
- [ ] オンボーディング完了後にホームタブが表示される
- [ ] 各タブの状態が切り替え後も保持される
- [ ] NavigationStackが各タブで独立している

### アクセシビリティ確認

- [ ] VoiceOverで各タブが読み上げられる
- [ ] Dynamic Typeでラベルが適切に拡大される

---

## 今後のフェーズとの関係

### Phase 12（コンディショントップ）

- `ConditionPlaceholderView`を`ConditionView`に置き換え
- 24時間サークル図 + HRV、要因マップ、AIの見立てを実装

### Phase 13（詳細画面）

- コンディション画面から詳細画面への遷移を追加

---

## 関連ドキュメント

- `ui-spec.md` - セクション4「画面構成全体マップ」
- `product-spec.md` - セクション2.1「画面構成」
- `02-phase-home-basic.md` - Phase 2詳細設計書

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-19 | 初版作成 |
