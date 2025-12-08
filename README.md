# 🎵 Tempo AI

> **あなたの「テンポ」に合わせたヘルスケアパートナー**  
> AIがヘルスケアデータを分析し、体調や生活リズムに最適化されたアドバイスを提供

[![CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/ci.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/ci.yml)
[![Backend CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/backend.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/backend.yml)
[![iOS CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/ios.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/ios.yml)

---

## 🎯 **Tempo AIとは**

Tempo AIは、**あなたの生活リズム（テンポ）**に完全に同期する次世代ヘルスケアアシスタントです。

従来のヘルスケアアプリとは違い、単なる「データ表示」ではなく：
- **状況を理解**: 睡眠不足？気圧低下？ストレス？複合的要因をAIが分析
- **専門的アドバイス**: 6つの関心分野それぞれの専門AIが最適化された提案
- **実行可能な提案**: 「何をすべきか」を明確に、今すぐできることから習慣改善まで

---

## 🌟 **主な特徴**

### 🧠 **6つの専門AI分野**
選択した関心分野に応じて、専門AIアドバイザーが個別最適化されたアドバイスを提供：

- **🧠 Work**: 認知パフォーマンス・集中力最適化コーチ
- **✨ Beauty**: 美容・スキンケア専門コンシェルジュ  
- **🥗 Diet**: 食事タイミング・栄養最適化アドバイザー
- **🍃 Chill**: ストレス管理・リラクゼーション専門家
- **💤 Sleep**: 睡眠質向上・リカバリー専門アドバイザー
- **🏃‍♂️ Fitness**: 運動習慣・フィットネス最適化コーチ

### 📊 **包括的データ統合**
- **ヘルスケアデータ**: 心拍・HRV・睡眠・活動量の詳細分析
- **環境データ**: 気温・湿度・気圧・大気質・UV指数
- **生活コンテキスト**: 時間帯・天候・個人設定の総合判断

### 🎨 **プレミアムユーザー体験**
- **UX心理学原則**: Fitts's Law、Miller's Law等の科学的設計
- **直感的エネルギー表示**: 一目でわかる体調可視化
- **美しいインターフェース**: ミニマリストデザインと効果的なカラーアクセント

---

## 🏗️ **技術アーキテクチャ**

### 📱 **iOS アプリケーション**
```
┌─────────────────────────────┐
│        Digital Cockpit      │
│  ┌─────────────────────────┐ │
│  │   エネルギー可視化        │ │ ← リアルタイム状態表示
│  └─────────────────────────┘ │
│  ┌─────────────────────────┐ │
│  │   AI分析アドバイス        │ │ ← 関心分野別専門提案
│  └─────────────────────────┘ │
│  ┌─────────────────────────┐ │
│  │   今日・今週のトライ      │ │ ← 新体験・習慣改善提案
│  └─────────────────────────┘ │
└─────────────────────────────┘
```

### 🔄 **バックエンド処理**
```
┌────────────────┐    HTTPS     ┌─────────────────┐    ┌──────────────┐
│   iOS クライアント │─────────────▶│ Cloudflare      │───▶│ Claude API   │
│   (SwiftUI)    │               │ Workers + Hono  │    │ (Anthropic)  │
│                │               │                 │    └──────────────┘
│ • HealthKit    │               │ • TypeScript    │           │
│ • CoreLocation │               │ • スマートキャッシュ │           ▼
│ • 高品質UX      │               │ • 高速処理       │    ┌──────────────┐
└────────────────┘               └─────────────────┘    │ Open-Meteo   │
                                                         │ 気象API      │
                                                         └──────────────┘
```

### 🤖 **AI処理パイプライン**
```
ヘルスケアデータ + 環境コンテキスト + 関心分野設定
                        ↓
              関心分野別専門AI分析 (朝・週次)
                        ↓
                Claude API 高度解析
                        ↓
        温かく個人的なアドバイス + 今日・今週のトライ
                        ↓
              ローカル軽量分析 (リアルタイム反応)
```

---

## 🔬 **技術革新**

### 🎯 **3段階AI分析システム**
**コスト効率と体験価値の最適バランス**

- **🌅 朝の詳細分析** (1日1回): 包括的AI解析 + 今日のトライ提案
- **⚡ リアルタイム軽量** (アプリ起動時): ローカル処理での即座反応
- **📅 月曜週次分析** (週1回): 深い習慣改善の温かい提案

### 🧠 **関心分野特化システム**
6つの専門分野から複数選択し、それぞれ独立したAIスペシャリストが作動：
- 単一分野: 深い専門性でのアドバイス
- 複数分野: シナジー効果を考慮した統合提案

### 📊 **ハイブリッド処理方式**
- **ローカル処理**: エネルギー計算、即座のUI更新、軽量分析
- **クラウド処理**: 複雑な相関分析、AI生成アドバイス、環境データ統合
- **スマートキャッシュ**: 効率的なデータ再利用と高速レスポンス

### 🎨 **UX心理学設計**
- **Aesthetic-Usability Effect**: 美しいデザインによる使いやすさ向上
- **Fitts's Law**: 最適なボタン配置とタップエリア設計
- **Miller's Law**: 情報量の最適化（7±2原則）
- **Progressive Disclosure**: 段階的な複雑性の開示

---

## 🚀 **開発環境セットアップ**

### 📋 **必要な環境**
- **iOS開発**: Xcode 15+、macOS Sonoma 14+、iPhone実機推奨
- **バックエンド開発**: Node.js 20+、pnpm 9+
- **API**: Claude API キー (Anthropic)

### ⚡ **クイックスタート**
```bash
# 1. リポジトリクローン
git clone https://github.com/Bluefinee/tempo-ai.git
cd tempo-ai

# 2. 環境セットアップ
./scripts/dev-commands.sh help

# 3. バックエンド設定
cd backend && cp .dev.vars.example .dev.vars
# .dev.varsにClaude APIキーを設定

# 4. 開発開始
./scripts/dev-commands.sh dev-backend    # バックエンド起動
./scripts/dev-commands.sh build-ios      # iOS ビルド
```

### 🔧 **開発コマンド**
```bash
# 全プロジェクト品質チェック
./scripts/dev-commands.sh test-all

# 問題自動修正
./scripts/dev-commands.sh lint-fix

# iOS個別開発
cd ios && ./scripts/quality-check.sh

# バックエンド個別開発  
cd backend && pnpm run dev
```

---

## 📁 **プロジェクト構造**

```
tempo-ai/
├── 📱 ios/TempoAI/              # iOS アプリケーション
│   ├── TempoAI/
│   │   ├── Views/               # UI コンポーネント
│   │   ├── Models/              # データモデル
│   │   ├── Services/            # HealthKit、AI、天気サービス
│   │   └── DesignSystem/        # カラー、タイポグラフィ、コンポーネント
│   └── Tests/                   # iOS テスト
│
├── 🚀 backend/                  # Cloudflare Workers API
│   ├── src/
│   │   ├── routes/              # API エンドポイント
│   │   ├── services/            # ビジネスロジック
│   │   ├── ai/                  # Claude統合
│   │   └── types/               # TypeScript型定義
│   └── tests/                   # バックエンドテスト
│
├── 📚 guidelines/               # 開発ドキュメント
│   ├── development-plans/       # フェーズ別詳細計画
│   ├── messaging-guidelines.md  # AIメッセージング指針
│   └── mode-specific-ai-requirements.md
│
└── 🛠️ scripts/                 # 開発自動化スクリプト
```

---

## 🔐 **セキュリティ・プライバシー**

### 🛡️ **データ保護**
- **ヘルスケアデータ**: 端末内処理、分析時のみ暗号化送信
- **位置情報**: 市町村レベルのみ、個人特定不可
- **AI処理**: データ保持なし、処理後即座削除
- **GDPR準拠**: ユーザーによる完全なデータ制御

### 🔒 **技術セキュリティ**
- HTTPS/TLS 1.3 全通信暗号化
- 環境変数によるAPIキー管理
- 依存関係自動脆弱性スキャン
- 定期セキュリティ監査

---

## 📊 **現在の実装状況**

### ✅ **完了済み機能**
- プレミアムオンボーディング（Apple純正権限ダイアログ）
- 6つの関心分野選択システム
- エネルギー状態可視化（直感的バッテリー風UI）
- モックAI分析機能
- 包括的デザインシステム

### 🔄 **開発中機能**
- 実HealthKitデータ統合
- Open-Meteo天気API接続
- Claude AI分析（関心分野別）
- スマートキャッシュシステム

### 📋 **今後予定**
- 今日のトライ・今週のトライ機能
- 複数関心分野のシナジー分析
- パフォーマンス最適化

---

## 🛠️ **技術スタック**

### 📱 **フロントエンド**
- **フレームワーク**: SwiftUI (iOS 16.0+)
- **言語**: Swift 5.9+ (厳密型付け)
- **アーキテクチャ**: MVVM + Combine
- **デザイン**: カスタムデザインシステム (8pxグリッド)

### 🚀 **バックエンド**  
- **ランタイム**: Cloudflare Workers (エッジコンピューティング)
- **フレームワーク**: Hono.js (TypeScript)
- **言語**: TypeScript 5.9+ (strict mode)
- **AI**: Claude API (カスタムプロンプトエンジニアリング)

### 🔗 **外部API統合**
- **ヘルスデータ**: HealthKit (iOS ネイティブ統合)
- **環境データ**: Open-Meteo (気象・大気質・UV)
- **AI分析**: Claude API (関心分野別ペルソナ)
- **位置情報**: CoreLocation (プライバシー配慮)

---

## 🧪 **テスト・品質管理**

### 🔍 **テスト戦略**
```bash
# 包括的品質チェック
./scripts/dev-commands.sh test-all

# iOS 固有テスト
cd ios && ./scripts/quality-check.sh

# バックエンド固有テスト
cd backend && pnpm run test
```

### 📊 **品質指標**
- **バックエンドカバレッジ**: 80%以上維持
- **iOS テスト**: XCTest + UIテスト
- **コード品質**: SwiftLint + Biome 厳格ルール
- **パフォーマンス**: 実機テスト必須

---

## 🤝 **開発参加**

### 📋 **開発ワークフロー**
1. **セットアップ**: 上記クイックスタートに従う
2. **基準確認**: [CLAUDE.md](./CLAUDE.md) と [Swift基準](.claude/swift-coding-standards.md) を熟読
3. **UX適用**: [UX原則](.claude/ux_concepts.md) に基づく設計
4. **メッセージング**: [メッセージング指針](guidelines/messaging-guidelines.md) に準拠

### 🔄 **プルリクエスト手順**
1. フィーチャーブランチ作成: `git checkout -b feature/改善内容`
2. プロジェクト基準に従って実装
3. 包括的テスト実行: `./scripts/dev-commands.sh test-all`
4. 詳細なPR説明付きで作成
5. CodeRabbit自動レビューへの対応

---

## 📚 **重要ドキュメント**

### 📖 **必読資料**
- **[🏗️ 開発ガイドライン](./CLAUDE.md)** - アーキテクチャ、コーディング基準、プロセス
- **[🎨 UX設計原則](./.claude/ux_concepts.md)** - 心理学に基づくデザイン原則
- **[💬 メッセージング指針](./guidelines/messaging-guidelines.md)** - AIペルソナ・コミュニケーション基準

### 🗺️ **フェーズ別詳細計画**
- **[Phase 1.5: AI分析基盤](./guidelines/development-plans/phase-1.5.md)** - 関心分野別AI・タイミング戦略
- **[Phase 2: 高度個人化](./guidelines/development-plans/phase-2.md)** - 複数分野統合・週次分析
- **[Phase 3: 最適化](./guidelines/development-plans/phase-3.md)** - パフォーマンス・スケーリング

---

## 🎉 **最新の成果**

### 🔄 **v2.0 オンボーディング改善**
- UX心理学原則に基づく最適なユーザーフロー設計
- Googleスタイルのカラーアクセントとプレミアム感
- Apple純正権限ダイアログの実装

### 🧠 **6分野専門化システム**
- ライフスタイル選択を削除し、関心分野中心の直感的設計
- 各分野で独立したAIスペシャリストが作動
- 複数選択でのシナジー効果も考慮

### 📋 **開発品質向上**
- Swift Coding Standards 100%準拠
- CodeRabbit AI レビュー完全対応
- ファイル構造最適化（大型ファイル分割）

---

## 🎯 **将来ビジョン**

Tempo AIは、単なるヘルスケアアプリを超えて、**あなた専用のウェルネス・コンパニオン**となることを目指しています。

6つの専門分野からの精密な分析と、温かく個人的な「今日のトライ」「今週のトライ」提案により、毎日新鮮な発見と継続的な成長を支援します。

データを見るだけでなく、**次に何をすべきかが明確にわかる**、真に実用的なヘルスケア体験を実現します。

---

## 📞 **サポート・コミュニティ**

### 🐛 **問題報告**
- GitHub Issues でバグ報告・機能要求
- デバイスモデル、iOS バージョン、再現手順を含めてください

### 💡 **機能提案**
- 既存フェーズ計画を確認してから提案
- ユーザー価値と技術実現性を重視

---

## 📄 **ライセンス**

このプロジェクトは MIT ライセンスの下でライセンスされています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。

---

**❤️ [Claude Code](https://claude.ai/code) で構築**

*最終更新: 2025年12月 | バージョン: 2.0 (6分野専門化・オンボーディング改善)*