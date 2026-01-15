# プロジェクトコンテキスト

このドキュメントには、プロジェクト固有のコンテキストを記録します。

---

## プロジェクト概要

**TempoAI** - サーカディアンリズムと自律神経の状態を可視化し、AI が毎朝パーソナライズされたアドバイスを提供するヘルスケアアプリ。

### ビジョン

「自分のテンポを知り、テンポに乗る」

### ターゲットユーザー

- 年齢層: 25-40歳
- 属性: 健康意識の高いプロフェッショナル
- デバイス: Apple Watch 装着者
- ペイン: 数字の羅列に疲れている、何をすべきかわからない
- ゲイン: 自分の身体を理解したい、最適なタイミングで行動したい

---

## 開発状況

### 現在のフェーズ

React Native (Expo) への移行完了。主要機能の実装中。

### 実装済み機能

- [x] オンボーディングフロー
- [x] Today 画面（4スコア表示）
- [x] スコア詳細画面
- [x] AI アドバイス表示
- [x] バックエンド API（Cloudflare Workers）
- [x] モックデータでの動作確認

### 進行中/未実装

- [ ] HealthKit 統合
- [ ] リマインダー通知
- [ ] 多言語対応（日本語/英語切り替え）
- [ ] ウィジェット

---

## 重要なコンテキスト

### データソース切り替え

開発中は `mock` モードで動作。実機テストでは `healthkit` に切り替え。

```typescript
// app/src/config/dataSource.ts
export const DATA_SOURCE: DataSourceType = 'mock';
```

### Baseline 計算

スコアの基準値は個人の過去30日平均から算出。新規ユーザーは人口統計的なデフォルト値を使用。

### AI プロンプト設計

- System prompt はキャッシュ対象（トークン節約）
- ユーザーデータは毎回変わるため後半に配置
- 詳細: `docs/specs/tempoai_ai_prompt_spec.md`

---

## よくある問題と解決策

### Expo 開発サーバーが起動しない

```bash
cd app
npx expo start --clear
```

### TypeScript エラー: モジュールが見つからない

`@/` エイリアスが正しく設定されているか確認:

```json
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

### Biome と ESLint の競合

- app: ESLint を使用
- backend: Biome を使用

混在させない。
