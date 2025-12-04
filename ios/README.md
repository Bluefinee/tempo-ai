# 📱 Tempo AI - iOS アプリ

HealthKit データと天気情報を活用したパーソナライズ健康アドバイスアプリ

## 🎯 概要

Tempo AI iOS アプリは、ユーザーの HealthKit データ（睡眠、心拍変動、活動量など）と現在の天気情報を組み合わせて、AI が生成するパーソナライズされた健康アドバイスを毎日提供します。

## ✨ 主な機能

### 📊 HealthKit 統合

- 睡眠分析（時間、深度、REM、効率）
- 心拍変動（HRV）データ
- 心拍数（安静時・平均）
- 活動データ（歩数、距離、カロリー）

### 🌡️ 天気連動

- 位置情報ベースの天気取得
- 天気を考慮した健康アドバイス

### 🤖 AI 分析

- Claude AI による高度な健康データ分析
- 個人の状態に最適化された具体的アドバイス

### 📱 ユーザー体験

- **Today（ホーム）**: 今日のアドバイス表示
- **History**: 過去の推奨事項（Phase 3 で実装）
- **Trends**: データトレンド分析（Phase 4 で実装）
- **Profile**: ユーザー設定とプロフィール

## 🛠 技術スタック

- **言語**: Swift 5.9+
- **UI**: SwiftUI
- **最小 iOS**: 16.0
- **フレームワーク**:
  - HealthKit（ヘルスデータ）
  - CoreLocation（位置情報）
  - UserNotifications（通知）

## 📋 プロジェクト構造

```text
ios/
├── TempoAI.xcodeproj/          # Xcodeプロジェクト
└── TempoAI/                    # ソースコード
    ├── TempoAIApp.swift        # アプリエントリー
    ├── ContentView.swift       # メインタブビュー
    ├── HomeView.swift          # ホーム画面
    ├── Models.swift            # データモデル
    ├── HealthKitManager.swift  # HealthKit管理
    ├── APIClient.swift         # API通信
    ├── Assets.xcassets/        # アセット
    ├── Info.plist             # アプリ設定
    └── Preview Content/        # プレビューアセット
```

## 🚀 セットアップ

### 前提条件

1. **Xcode 15+** がインストールされている
2. **macOS Sonoma 14+**
3. **iPhone 実機**（HealthKit はシミュレーターでは制限あり）

### インストール手順

1. **リポジトリクローン**

   ```bash
   git clone https://github.com/masakazuiwahara/tempo-ai.git
   cd tempo-ai/ios
   ```

2. **Xcode でプロジェクトを開く**

   ```bash
   open TempoAI.xcodeproj
   ```

3. **API サーバー起動**（別ターミナル）

   ```bash
   cd ../backend
   npm run dev
   ```

4. **開発チーム設定**

   - Xcode で Signing & Capabilities
   - 開発チームを選択
   - Bundle Identifier を変更（必要に応じて）

5. **実機でビルド&実行**
   - iPhone 実機を接続
   - ⌘R でビルド&実行

## 🔧 開発設定

### API 接続設定

アプリは Debug ビルドで自動的にローカル API サーバー（`http://localhost:8787`）に接続します。

**APIClient.swift:**

```swift
#if DEBUG
self.baseURL = "http://localhost:8787/api"  // ローカル開発
#else
self.baseURL = "https://tempo-ai-backend.workers.dev/api"  // 本番環境
#endif
```

### 権限設定

以下の権限が自動的にリクエストされます：

- **HealthKit**: 健康データ読み取り
- **Location**: 天気情報取得用
- **Notifications**: 毎朝の通知用

## 📊 データフロー

```text
1. アプリ起動
   ↓
2. HealthKit権限リクエスト
   ↓
3. 位置情報権限リクエスト
   ↓
4. HealthKitからデータ取得
   ↓
5. 現在位置取得
   ↓
6. APIサーバーに分析リクエスト
   ↓
7. AIアドバイス受信・表示
   ↓
8. ローカルキャッシュに保存
```

## 🧪 テスト

### 実機テスト

1. **HealthKit データ**がある実機を使用
2. **ヘルスアプリ**で睡眠データを確認
3. **設定 > プライバシーとセキュリティ > 位置情報サービス**が有効

### シミュレーターテスト

HealthKit データが制限されるため、モックデータが使用されます：

```swift
// HealthKitManager.swift でモックデータを返す
return SleepData(
    duration: 6.5,
    deep: 1.2,
    rem: 1.8,
    light: 3.0,
    awake: 0.5,
    efficiency: 92
)
```

## 🔍 デバッグ

### API 接続確認

```swift
// APIClient.swift
func testConnection() async -> Bool
```

### ログ確認

- Xcode コンソールでネットワーク通信ログ
- Console.app でシステムログ

### 一般的な問題

1. **HealthKit 権限エラー**

   - 設定アプリ > プライバシーとセキュリティ > ヘルスケア
   - Tempo AI の権限を確認

2. **位置情報エラー**

   - 設定アプリ > プライバシーとセキュリティ > 位置情報サービス
   - Tempo AI が「App 使用中のみ」で許可されているか確認

3. **API 接続エラー**
   - ローカル API サーバーが起動しているか確認
   - `http://localhost:8787` にアクセス可能か確認

## 🎨 UI デザイン

### カラーパレット

- **プライマリ**: ソフトグリーン (`#4ECDC4`)
- **セカンダリ**: ウォームベージュ (`#F7F3E9`)
- **アクセント**: サンセットオレンジ (`#FF6B6B`)

### コンポーネント

- **カード角丸**: 16pt
- **フォント**: SF Pro Display/Text
- **アイコン**: SF Symbols

## 🔮 ロードマップ

### Phase 1 ✅

- 基本 UI 実装
- HealthKit 統合
- API 通信
- 今日のアドバイス表示

### Phase 2（Week 3-4）

- UX 改善
- アニメーション追加
- エラーハンドリング強化
- オンボーディング

### Phase 3（Week 5-6）

- 履歴機能
- データベース統合
- 7 日間のアドバイス保存

### Phase 4（Week 7-8+）

- トレンドグラフ
- Apple Watch 対応
- 通知カスタマイズ

## 🏗️ アーキテクチャ

### MVVM + ObservableObject

```swift
// ViewModel
@MainActor
class HealthKitManager: ObservableObject {
    @Published var isAuthorized = false
    // ...
}

// View
struct HomeView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    // ...
}
```

### データレイヤー

- **UserDefaults**: プロフィール、キャッシュ
- **HealthKit**: リアルタイム健康データ
- **API**: AI アドバイス生成

## 📝 注意事項

### Apple Review Guidelines

- HealthKit データの適切な使用説明
- 医療アドバイスではない旨の明記
- プライバシーポリシーの準備

### セキュリティ

- HealthKit データはデバイスローカル保持
- API 通信は一時的、即座に削除
- 個人識別情報の送信なし

## CodeRabbit レビューの実行要件

```
下記の通り、code rabbitによるレビュー・修正を適切に行なってください。
### 1. レビューの実行
- CodeRabbit CLIのレビューコマンドを実行してコードレビューを受けること
- **重要**: レビュー処理には5-10分程度かかるため、コマンドの完了まで待機すること

### 2. レビュー結果の処理
レビュー結果が返却されたら、以下の手順で対応すること:

- 結果を分析し、詳細な修正計画を策定
- 修正計画はチェックリスト形式でMarkdownファイルにまとめる
- 計画的かつ適切な順序で修正を実施

### 3. 修正方針
- **基本原則**: 指摘事項は全て修正対象とする
- **例外**: 明らかに修正不要、または指摘が誤っていると判断できる場合のみ無視可

### 4. レビュー対象の確認
- `.coderabbit.yaml`の設定を確認し、レビュー対象から除外されているファイルを把握すること
- 除外設定を理解した上で、適切なファイルのみレビューを依頼すること

```
