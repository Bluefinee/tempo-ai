# Phase 9: リリース準備

## 概要

| 項目 | 内容 |
|------|------|
| **目的** | App Store に申請し、一般公開 |
| **期間目安** | 1-2週間（審査期間含む） |
| **依存** | Phase 8（HealthKit連携） + Apple Developer |
| **成果物** | App Store で公開されたアプリ |

---

## 前提条件

| 要件 | 状態 | 備考 |
|------|------|------|
| Phase 8 完了 | 必須 | HealthKit 動作確認済み |
| Apple Developer | 必須 | 有効なアカウント |
| アプリアイコン | 必要 | 1024x1024 PNG |
| スクリーンショット | 必要 | 6.5インチ、5.5インチ |
| プライバシーポリシー | 必要 | URL 必須 |

---

## タスク詳細

### 9.1 App Store Connect 設定

#### 9.1.1 アプリ作成

1. [App Store Connect](https://appstoreconnect.apple.com/) にアクセス
2. 「マイApp」→「+」→「新規App」
3. 以下を入力:

| 項目 | 値 |
|------|-----|
| プラットフォーム | iOS |
| 名前 | TempoAI |
| プライマリ言語 | 日本語 |
| バンドル ID | com.tempoai.app |
| SKU | tempoai-ios-001 |

#### 9.1.2 アプリ情報

**アプリ名**: TempoAI

**サブタイトル**: 睡眠と自律神経のAIアドバイザー

**説明文（日本語）**:
```
TempoAI は、あなたの睡眠データと自律神経の状態を分析し、
パーソナライズされた健康アドバイスを提供するアプリです。

【主な機能】
・Apple Health との連携で睡眠・HRV データを自動取得
・AI が毎日のコンディションを分析
・気圧変化や天気を考慮したアドバイス
・生活リズムの安定度を可視化

【こんな方におすすめ】
・睡眠の質を改善したい方
・自律神経を整えたい方
・気圧の変化に敏感な方
・毎日の体調管理をしたい方

プライバシーを大切にしています。
健康データはデバイス上で処理され、
あなたの許可なく外部に送信されることはありません。
```

**キーワード**:
```
睡眠,自律神経,HRV,健康,ヘルスケア,AI,アドバイス,気圧,生活リズム,体調管理
```

#### 9.1.3 カテゴリ

| 種類 | 選択 |
|------|------|
| プライマリ | Health & Fitness |
| セカンダリ | Lifestyle |

#### 9.1.4 年齢制限

- **年齢制限**: 4+（全年齢対象）
- 医療/治療情報: なし（一般的な健康アドバイスのみ）

---

### 9.2 アセット準備

#### 9.2.1 アプリアイコン

**仕様**:
- サイズ: 1024x1024 ピクセル
- 形式: PNG（透過なし）
- 角丸: なし（システムが自動適用）

**デザイン要素**:
- TempoAI のロゴ
- 睡眠・健康を連想させるカラー
- シンプルで認識しやすいデザイン

#### 9.2.2 スクリーンショット

**必須サイズ**:

| デバイス | サイズ | 必要枚数 |
|---------|--------|----------|
| iPhone 6.5インチ | 1284 x 2778 | 最低3枚 |
| iPhone 5.5インチ | 1242 x 2208 | 最低3枚 |

**推奨枚数**: 各5-8枚

**撮影すべき画面**:
1. ホーム画面（スコア表示）
2. AI インサイト詳細
3. メトリクス詳細
4. 設定画面
5. オンボーディング（価値訴求）

**スクリーンショット作成ツール**:
- [Hotpot.ai](https://hotpot.ai/screenshot_generator)
- [Screenshots.pro](https://screenshots.pro/)
- Figma / Sketch でフレーム追加

#### 9.2.3 プレビュー動画（オプション）

- 長さ: 15-30秒
- 形式: MP4 / MOV
- 内容: アプリの主要機能デモ

---

### 9.3 プライバシーポリシー

#### 9.3.1 ホスティング

GitHub Pages や Notion で公開:

```
https://yourdomain.com/privacy
または
https://your-notion-page.notion.site/privacy
```

#### 9.3.2 必須記載事項

```markdown
# TempoAI プライバシーポリシー

最終更新日: 2026年1月

## 収集するデータ

### Apple Health データ
- 睡眠分析（就寝・起床時刻、睡眠ステージ）
- 心拍変動（HRV）
- 歩数
- 消費カロリー

これらのデータはアプリの機能提供のためにのみ使用され、
お客様の明示的な許可なく第三者と共有されることはありません。

### 位置情報
天気情報の取得のために使用します。
正確な位置情報は保存されず、天気取得時のみ使用されます。

### AI 分析
健康データは AI 分析のためにサーバーに送信されますが、
個人を特定する情報は含まれません。

## データの保存

- 健康データ: デバイス上にのみ保存
- ユーザー設定: デバイス上にのみ保存
- AI 分析結果: デバイス上にのみ保存

## データの第三者共有

以下の場合を除き、データを第三者と共有することはありません：
- 法的要請がある場合
- お客様の明示的な同意がある場合

## お問い合わせ

プライバシーに関するご質問は以下までご連絡ください：
contact@yourdomain.com
```

---

### 9.4 HealthKit 審査対策

#### 9.4.1 HealthKit 使用理由

App Store Connect の「App Privacy」セクションで説明:

```
TempoAI uses HealthKit to provide personalized health insights:

1. Sleep Analysis: To analyze sleep patterns and provide sleep quality recommendations
2. Heart Rate Variability: To assess autonomic nervous system status
3. Step Count: To evaluate daily activity levels
4. Active Energy: To calculate exercise duration

All data is processed locally on the device and used solely for generating personalized health advice. Data is not sold or shared with third parties for advertising purposes.
```

#### 9.4.2 App Privacy ラベル

| データタイプ | 収集目的 | リンク |
|-------------|----------|--------|
| Health & Fitness | App Functionality | No |
| Location | App Functionality | No |

**「追跡」**: なし
**「サードパーティ広告」**: なし

#### 9.4.3 審査用メモ

```
【審査チームへのメモ】

このアプリは HealthKit データを使用して、
パーソナライズされた健康アドバイスを提供します。

テストアカウントは不要です。
オンボーディング完了後、すぐにアプリを使用できます。

HealthKit の権限は初回起動時にリクエストされます。
権限を許可すると、睡眠・HRV・活動データが自動取得されます。

テストデータがない場合は、iOS シミュレータの
Health アプリでサンプルデータを追加してテストできます。
```

---

### 9.5 Production Build

#### 9.5.1 バージョン管理

`app/app.json` を更新:

```json
{
  "expo": {
    "version": "1.0.0",
    "ios": {
      "buildNumber": "1"
    }
  }
}
```

**バージョン番号ルール**:
- `version`: ユーザー表示用（1.0.0, 1.0.1, 1.1.0...）
- `buildNumber`: Apple 内部用（毎ビルドでインクリメント）

#### 9.5.2 ビルド実行

```bash
cd app
eas build --profile production --platform ios
```

#### 9.5.3 ビルド完了後

EAS Build が完了すると、以下が生成:
- `.ipa` ファイル
- ビルド情報（バージョン、ビルド番号）

---

### 9.6 TestFlight

#### 9.6.1 アップロード

**方法1: EAS Submit（推奨）**
```bash
eas submit --platform ios
```

**方法2: Transporter アプリ**
1. Mac App Store から Transporter をダウンロード
2. `.ipa` ファイルをドラッグ＆ドロップ
3. 「配信」をクリック

#### 9.6.2 内部テスト

1. App Store Connect → 「TestFlight」
2. 「内部テスト」→ テスターを追加
3. ビルドを選択して「テスト開始」

**テスト項目**:
- [ ] オンボーディング完了
- [ ] HealthKit 権限リクエスト
- [ ] ホーム画面表示
- [ ] AI インサイト生成
- [ ] 設定画面操作
- [ ] クラッシュなし確認

#### 9.6.3 外部テスト（オプション）

1. 「外部テスト」グループ作成
2. テスターのメールアドレスを追加
3. 「Beta App Review」を通過後、テスト開始

---

### 9.7 審査申請

#### 9.7.1 申請前チェックリスト

- [ ] アプリ情報（名前、説明、キーワード）入力
- [ ] スクリーンショットアップロード
- [ ] アプリアイコン設定
- [ ] 年齢制限設定
- [ ] プライバシーポリシー URL 設定
- [ ] App Privacy ラベル設定
- [ ] 審査用メモ入力
- [ ] ビルドを選択

#### 9.7.2 申請

1. App Store Connect → 「App Store」タブ
2. 「審査用に追加」でビルドを選択
3. 「審査へ提出」をクリック

#### 9.7.3 審査期間

- **通常**: 24-48時間
- **初回**: 最大1週間（HealthKit 使用のため慎重に審査される可能性）

#### 9.7.4 リジェクト対応

よくあるリジェクト理由と対応:

| 理由 | 対応 |
|------|------|
| HealthKit 使用理由不明 | 説明を詳細化 |
| プライバシーポリシー不備 | 必須事項を追記 |
| クラッシュ | ログを確認して修正 |
| 機能不足 | 最低限の機能を確認 |
| メタデータ不備 | 説明文・スクリーンショット修正 |

---

### 9.8 公開

#### 9.8.1 審査通過後

審査通過後の公開オプション:

| オプション | 説明 |
|-----------|------|
| 自動公開 | 審査通過後すぐに公開 |
| 手動公開 | 自分で公開タイミングを決定 |

#### 9.8.2 公開確認

1. App Store で検索
2. 「TempoAI」が表示されることを確認
3. ダウンロード・インストールテスト

---

## チェックリスト

### App Store Connect 設定

- [ ] アプリ作成
- [ ] アプリ名・説明文入力
- [ ] キーワード設定
- [ ] カテゴリ設定
- [ ] 年齢制限設定

### アセット

- [ ] アプリアイコン（1024x1024）準備
- [ ] スクリーンショット（6.5インチ）準備
- [ ] スクリーンショット（5.5インチ）準備

### プライバシー

- [ ] プライバシーポリシー作成
- [ ] URL で公開
- [ ] App Privacy ラベル設定

### ビルド・テスト

- [ ] Production Build 作成
- [ ] TestFlight アップロード
- [ ] 内部テスト実施
- [ ] 動作確認完了

### 審査

- [ ] 審査用メモ準備
- [ ] 審査申請
- [ ] （リジェクト時）修正対応
- [ ] 審査通過

### 公開

- [ ] App Store 公開
- [ ] 公開確認

---

## 完了条件

1. App Store で「TempoAI」が検索できる
2. ダウンロード・インストールが可能
3. 実機で正常に動作する

---

## リリース後のタスク

### 初期モニタリング

- クラッシュレポート確認（App Store Connect → Analytics）
- ユーザーレビュー確認
- ダウンロード数確認

### 継続的改善

- ユーザーフィードバック収集
- バグ修正リリース
- 機能追加計画

---

## 参考リンク

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [HealthKit Guidelines](https://developer.apple.com/app-store/review/guidelines/#health-and-health-research)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [EAS Submit Documentation](https://docs.expo.dev/submit/introduction/)
