# Phase 2: ホーム画面UI（基本構造）実装計画書

**フェーズ**: 2 / 14  
**Part**: A（iOS UI）  
**前提フェーズ**: Phase 1（オンボーディング完了後にホームへ遷移）

---

## 🎯 実装概要

### 目的
Phase 1で完了したオンボーディング後のホーム画面基本構造を実装し、ユーザーが日々のアドバイスを確認できる基盤を構築する。

### 完了条件
- [ ] ホーム画面が表示され、ヘッダーに日付と挨拶が表示される
- [ ] アドバイスサマリーカードにMockデータが表示される
- [ ] タブバーでホームと設定を切り替えられる
- [ ] オンボーディング完了後、正しくホーム画面に遷移する
- [ ] 縦スクロールが機能する

---

## 📁 ファイル構造設計

### 新規作成ファイル一覧

```
ios/TempoAI/TempoAI/Features/Home/
├── Views/
│   ├── HomeView.swift                    # メインホーム画面
│   ├── HomeHeaderView.swift              # ヘッダー部分
│   ├── AdviceSummaryCard.swift           # アドバイスサマリーカード
│   ├── MainTabView.swift                 # タブバーコンテナ
│   └── SettingsPlaceholderView.swift     # 設定画面プレースホルダー

ios/TempoAI/TempoAI/Shared/
├── Models/
│   └── MockData.swift                    # Phase2用mockデータ
```

### 既存ファイル更新
- `ios/TempoAI/TempoAI/App/ContentView.swift` - タブバー構造への移行

---

## 🏗️ 実装詳細

### 1. MockData.swift 
**目的**: Phase 2で使用するモックデータを定義

```swift
import Foundation

#if DEBUG
struct MockData {
    // MARK: - Time-based Greeting
    
    static func getCurrentGreeting(nickname: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        
        switch hour {
        case 6..<13:
            timeOfDay = "おはようございます"
        case 13..<18:
            timeOfDay = "こんにちは"
        default:
            timeOfDay = "お疲れさまです"
        }
        
        return "\(nickname)さん、\(timeOfDay)"
    }
    
    // MARK: - Weather Mock Data
    
    static let mockWeather: WeatherInfo = WeatherInfo(
        cityName: "東京",
        temperature: 24,
        weatherIcon: "☀️"
    )
    
    // MARK: - Date Formatting
    
    static func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: Date())
    }
}

struct WeatherInfo {
    let cityName: String
    let temperature: Int
    let weatherIcon: String
}
#endif
```

### 2. HomeHeaderView.swift
**目的**: ヘッダー部分（天気情報、挨拶、日付）

```swift
import SwiftUI

struct HomeHeaderView: View {
    let userProfile: UserProfile
    
    var body: some View {
        VStack(spacing: 12) {
            // 天気情報行
            HStack {
                #if DEBUG
                Text("\(MockData.mockWeather.weatherIcon) \(MockData.mockWeather.cityName) \(MockData.mockWeather.temperature)°C")
                    .font(.subheadline)
                    .foregroundColor(.tempoSecondaryText)
                #endif
                
                Spacer()
            }
            
            // 挨拶
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    #if DEBUG
                    Text(MockData.getCurrentGreeting(nickname: userProfile.nickname))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.tempoPrimaryText)
                    #endif
                    
                    // 日付表示
                    #if DEBUG
                    Text(MockData.getCurrentDateString())
                        .font(.subheadline)
                        .foregroundColor(.tempoSecondaryText)
                    #endif
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            Color.tempoLightCream
                .ignoresSafeArea(edges: .top)
        )
    }
}

#Preview {
    HomeHeaderView(userProfile: UserProfile.sampleProfile)
}
```

### 3. AdviceSummaryCard.swift
**目的**: アドバイスサマリーの表示

```swift
import SwiftUI

struct AdviceSummaryCard: View {
    let advice: DailyAdvice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // カードタイトル
            Text("今日のアドバイス")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.tempoPrimaryText)
            
            // アドバイス本文
            Text(advice.condition.summary)
                .font(.body)
                .foregroundColor(.tempoPrimaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // 詳しく見るリンク
            HStack {
                Spacer()
                
                Button("詳しく見る") {
                    // Phase 4で実装予定
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.tempoSoftCoral)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }
}

#Preview {
    AdviceSummaryCard(advice: DailyAdvice.createMock())
        .padding()
        .background(Color.tempoLightCream)
}
```

### 4. SettingsPlaceholderView.swift
**目的**: Phase 6まで使用する設定画面プレースホルダー

```swift
import SwiftUI

struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "gear")
                        .font(.system(size: 60))
                        .foregroundColor(.tempoSageGreen.opacity(0.6))
                    
                    Text("設定")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.tempoPrimaryText)
                    
                    Text("Phase 6で設定画面を実装予定です")
                        .font(.subheadline)
                        .foregroundColor(.tempoSecondaryText)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.tempoLightCream.ignoresSafeArea())
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsPlaceholderView()
}
```

### 5. MainTabView.swift
**目的**: タブバー構造の実装

```swift
import SwiftUI

struct MainTabView: View {
    let userProfile: UserProfile
    
    var body: some View {
        TabView {
            HomeView(userProfile: userProfile)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .tag(0)
            
            SettingsPlaceholderView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
                .tag(1)
        }
        .accentColor(.tempoSageGreen)
    }
}

#Preview {
    MainTabView(userProfile: UserProfile.sampleProfile)
}
```

### 6. HomeView.swift（新実装）
**目的**: メインホーム画面の新構造実装

```swift
import SwiftUI

struct HomeView: View {
    let userProfile: UserProfile
    @State private var mockAdvice: DailyAdvice = DailyAdvice.createMock()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // 背景
                Color.tempoLightCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ヘッダー（固定）
                    HomeHeaderView(userProfile: userProfile)
                    
                    // スクロール可能コンテンツ
                    ScrollView {
                        VStack(spacing: 24) {
                            // Phase 3で追加エリアのためのスペース
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 8)
                            
                            // アドバイスサマリーカード
                            AdviceSummaryCard(advice: mockAdvice)
                                .padding(.horizontal, 24)
                            
                            // Phase 3で追加予定エリア
                            VStack(spacing: 16) {
                                Text("Phase 3で追加予定")
                                    .font(.subheadline)
                                    .foregroundColor(.tempoSecondaryText)
                                
                                Text("• メトリクスカード\n• トライカード")
                                    .font(.caption)
                                    .foregroundColor(.tempoSecondaryText.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                            
                            // タブバー分のスペース
                            Spacer()
                                .frame(height: 100)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    HomeView(userProfile: UserProfile.sampleProfile)
}
```

### 7. ContentView.swift（更新）
**目的**: タブバー構造への移行

```swift
// ContentViewの既存のHomeViewを以下に置き換え
MainTabView(userProfile: userProfile)
```

具体的な変更箇所:
```swift
// 変更前（行26-28）
if isOnboardingCompleted, let userProfile = userProfile {
  HomeView(userProfile: userProfile)
}

// 変更後
if isOnboardingCompleted, let userProfile = userProfile {
  MainTabView(userProfile: userProfile)
}
```

---

## 🎨 デザイン仕様

### カラーパレット使用方針
- **背景**: `tempoLightCream` - アプリ全体の背景
- **カード背景**: `white` - アドバイスカード
- **メインテキスト**: `tempoPrimaryText` - 主要テキスト
- **セカンダリテキスト**: `tempoSecondaryText` - 補足情報
- **アクセント**: `tempoSoftCoral` - リンク、重要な要素

### タイポグラフィ階層
- **挨拶**: `.title2` + `.semibold` 
- **カードタイトル**: `.headline` + `.semibold`
- **本文**: `.body`
- **日付・天気**: `.subheadline`

### レイアウト規則
- **水平パディング**: 24pt（標準）
- **垂直スペーシング**: 16pt（標準）、24pt（セクション間）
- **カード角丸**: 16pt
- **影**: 8ptの柔らかい影

---

## 🧪 品質確認手順

### 1. コンパイル確認
```bash
# Xcodeでのビルド確認
cd ios/TempoAI
xcodebuild -scheme TempoAI -configuration Debug build
```

### 2. コード品質チェック
```bash
# SwiftLint実行
swiftlint

# Swift Format確認
swift-format --lint --recursive ios/
```

### 3. テスト実行
```bash
# テストスイート実行
swift test
```

### 4. プレビュー確認
- 各Viewコンポーネントで#Previewが正常に動作することを確認
- ライト・ダークモード対応（Phase 2ではライトモードのみ）

---

## 📋 実装チェックリスト

### ファイル作成
- [ ] `Features/Home/Views/` ディレクトリ作成
- [ ] `MockData.swift` 作成
- [ ] `HomeHeaderView.swift` 作成
- [ ] `AdviceSummaryCard.swift` 作成
- [ ] `MainTabView.swift` 作成
- [ ] `SettingsPlaceholderView.swift` 作成
- [ ] `HomeView.swift` 新実装

### 機能実装
- [ ] 時間帯別挨拶ロジック動作
- [ ] mockデータ表示確認
- [ ] タブ切り替え動作確認
- [ ] スクロール動作確認
- [ ] レスポンシブレイアウト確認

### 品質確認
- [ ] SwiftLintエラー 0件
- [ ] コンパイルエラー 0件
- [ ] プレビュー正常動作
- [ ] ナビゲーション動作確認

---

## 🔄 Phase 3への準備

このPhase 2の実装により、Phase 3で追加予定の以下要素を円滑に統合できるようになります：

1. **メトリクスカード4つ** - HomeViewのスクロールエリアに追加
2. **今日のトライカード** - アドバイス下に配置
3. **今週のトライカード** - 今日のトライカード下に配置
4. **追加アドバイス（フローティング吹き出し）** - 必要に応じて表示

Phase 2では拡張可能な構造を意識し、Phase 3での統合を容易にする設計としています。

---

**実装完了日**: 2025-12-11  
**次フェーズ**: Phase 3 - ホーム画面UI（詳細機能）