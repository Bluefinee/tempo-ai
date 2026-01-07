# Tempo AI リリース TODO

## 現在の状態

- **Frontend typecheck**: 0 errors
- **Backend typecheck**: 0 errors
- **Frontend lint**: 0 warnings
- **成功基準**: 11/12 passed

---

## ブロッカー（リリース前に必須）

### 1. HealthKit/Health Connect 統合
- **現状**: MOCKデータを使用中
- **対象ファイル**: `app/src/stores/healthStore.ts`
- **実装内容**:
  - [ ] `react-native-health` (iOS) または `expo-health-connect` (Android) 導入
  - [ ] 睡眠データ取得の実装
  - [ ] HRVデータ取得の実装
  - [ ] アクティビティデータ取得の実装
  - [ ] MOCKデータを実データに置換

### 2. 位置情報パーミッションリクエスト
- **現状**: TODOコメントのみ
- **対象ファイル**: `app/app/(onboarding)/location.tsx`
- **実装内容**:
  - [ ] `expo-location` の `requestForegroundPermissionsAsync` 実装
  - [ ] パーミッション拒否時のハンドリング
  - [ ] 設定画面への誘導UI

### 3. バックエンドテスト修正
- **対象ファイル**: `backend/src/services/advice/__tests__/PromptBuilder.test.ts`
- **問題**: Line 37で旧形式 `"summary"` を期待
- **修正**: 新形式 `"message"` に更新

### 4. プライバシーポリシー作成
- **作成場所**: `docs/legal/privacy-policy.md` または WebページURL
- **実装内容**:
  - [ ] プライバシーポリシー文書作成
  - [ ] Settings画面からのリンク実装

### 5. 利用規約作成
- **作成場所**: `docs/legal/terms-of-service.md` または WebページURL
- **実装内容**:
  - [ ] 利用規約文書作成
  - [ ] Settings画面からのリンク実装

---

## 追加タスク

### Settings画面の未実装メニュー
- **対象ファイル**: `app/app/(main)/settings.tsx`
- [ ] アカウント設定
- [ ] 通知設定
- [ ] データエクスポート
- [ ] データ削除
- [ ] ログアウト

### テスト
- [ ] 実機テスト（iOSシミュレータ）
- [ ] 実機テスト（iOS実機）
- [ ] 実機テスト（Androidエミュレータ）
- [ ] 実機テスト（Android実機）
- [ ] E2Eテスト実行

### リリース準備
- [ ] App Store Connect設定
- [ ] Google Play Console設定
- [ ] アプリアイコン最終版作成
- [ ] スプラッシュ画面作成
- [ ] App Store用スクリーンショット準備
- [ ] ストア掲載文作成

### ビルド・リリース
- [ ] iOS本番ビルド
- [ ] Android本番ビルド
- [ ] TestFlight配布
- [ ] Google Play内部テスト配布
- [ ] App Store審査提出
- [ ] Google Play審査提出

---

## 実機テスト手順

### iOS実機テスト（Expo Go使用）

```bash
# 1. appディレクトリに移動
cd app

# 2. 開発サーバー起動
npx expo start

# 3. iPhoneでExpo Goアプリを開く
# 4. カメラでQRコードをスキャン
# 5. アプリが自動的に起動
```

### iOS開発ビルド（ネイティブ機能テスト用）

```bash
# 1. appディレクトリに移動
cd app

# 2. iOS開発ビルドを作成・実行
npx expo run:ios --device

# ※ Apple Developer Programの登録が必要
# ※ 実機をMacに接続しておく
```

### Androidエミュレータテスト

```bash
# 1. Android Studioでエミュレータを起動
# 2. appディレクトリに移動
cd app

# 3. 開発サーバー起動
npx expo start

# 4. ターミナルで 'a' を押してAndroidで開く
```

### Android実機テスト

```bash
# 1. Android端末でExpo Goアプリをインストール
# 2. appディレクトリに移動
cd app

# 3. 開発サーバー起動
npx expo start

# 4. Expo GoアプリでQRコードをスキャン
```

---

## 確認項目チェックリスト

### オンボーディング
- [ ] Welcome画面表示
- [ ] HealthKit権限画面（iOS）
- [ ] ニックネーム入力
- [ ] 基本情報入力
- [ ] ライフスタイル選択
- [ ] 位置情報許可
- [ ] 完了画面

### メイン画面
- [ ] Today画面：スコア表示、AIメッセージ
- [ ] Rhythm画面：24時間リズムビジュアル
- [ ] Breathe画面：4-7-8呼吸法アニメーション
- [ ] Insights画面：週間グラフ
- [ ] Settings画面：メニュー一覧

### その他
- [ ] タブナビゲーション動作
- [ ] 画面遷移アニメーション
- [ ] ダークモード対応（設定時）
- [ ] エラーハンドリング表示
- [ ] ローディング状態表示

---

## 優先順位

1. **最優先**: ブロッカー5項目の解消
2. **高**: 実機テストの実施
3. **中**: Settings画面の完成
4. **低**: E2Eテスト、ストア準備
