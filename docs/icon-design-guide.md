# アイコンデザインガイド

**バージョン**: 1.0
**最終更新**: 2025-12-13
**関連ドキュメント**: [ui-spec.md](./ui-spec.md)

---

## 1. 概要

Tempo AIのアイコンシステムは、標準絵文字（emoji）を廃止し、カスタムデザインのアイコンを採用します。本ガイドでは、アイコンのデザイン原則、スタイル仕様、および各メトリクスのアイコン定義を示します。

### 1.1 絵文字廃止の理由

- **OS/デバイス間での表示差異**: 絵文字は環境によって見た目が異なる
- **感情の暗示回避**: 🥱😴などは特定の感情を暗示してしまう
- **ブランド一貫性**: カスタムアイコンでアプリの独自性を表現
- **柔軟な状態表現**: 色やサイズを自由にコントロール可能

---

## 2. デザイン原則

### 2.1 4つの原則

| 原則 | 説明 |
|-----|------|
| **ニュートラル** | 特定の感情や判断を示唆しない。良い/悪いの印象を与えない |
| **シンプル** | 最小限の線と形で構成。一目で認識できる |
| **ポップ** | 親しみやすく、明るい印象。重たくならない |
| **一貫性** | 全アイコンで同じ線の太さ、角丸、スタイルを使用 |

### 2.2 アンチパターン

❌ 避けるべきデザイン:

- 顔の表情（笑顔、眠そうな顔など）
- リアルすぎる描写
- 複雑な詳細
- 影やグラデーション（状態色以外）
- 3D効果

---

## 3. スタイルガイド

### 3.1 線と形

| 項目 | 仕様 |
|-----|------|
| 線の太さ | 2pt（統一） |
| 角丸 | 2px |
| 線端 | Round cap |
| 線の結合 | Round join |
| 塗りつぶし | 線のみ（outline style）、一部要素のみ塗りつぶし可 |

### 3.2 サイズバリエーション

| 用途 | サイズ | 使用場所 |
|-----|-------|---------|
| Small | 24×24px | ナビゲーション、リスト項目 |
| Medium | 32×32px | メトリクスカード内 |
| Large | 48×48px | 詳細画面ヘッダー |
| Extra Large | 64×64px | オンボーディング、空状態 |

### 3.3 カラーシステム

#### 基本カラー

| 用途 | 色 | HEX |
|-----|---|-----|
| デフォルト | Primary (Soft Sage Green) | #7CB342 |
| 非アクティブ | Gray | #9E9E9E |

#### 状態別カラー

| スコア範囲 | 状態 | 色 | HEX |
|----------|-----|---|-----|
| 60-100 | 良好 | Primary | #7CB342 |
| 40-59 | 普通 | Yellow | #FFC107 |
| 20-39 | 注意 | Orange | #FF9800 |
| 0-19 | 要改善 | Red | #F44336 |

---

## 4. メトリクスアイコン定義

### 4.1 睡眠アイコン

**コンセプト**: 三日月 + Z

```
デザイン要素:
- 左向きの三日月（クレセント）
- 右上に小さなZ文字（1つ）
- 星は含めない（シンプルさ優先）
```

**ビジュアルイメージ**:
```
    z
   🌙
```

**実装ノート**:
- 三日月は正円から楕円を切り抜いた形
- Zは斜体、三日月の右上に配置
- SF Symbol代替: `moon.zzz` （カスタマイズ推奨）

---

### 4.2 HRVアイコン

**コンセプト**: 心臓 + 波形

```
デザイン要素:
- シンプルなハートマーク（線のみ）
- ハートの中央から右に伸びる緩やかな波線
- 波線は2-3サイクル
```

**ビジュアルイメージ**:
```
  ♡~~~
```

**実装ノート**:
- ハートは対称、尖りすぎない
- 波線はサイン波を簡略化
- SF Symbol代替: `heart.text.square` + カスタム波形

---

### 4.3 リズムアイコン

**コンセプト**: 時計 + サイクル矢印

```
デザイン要素:
- シンプルな円形時計（文字盤の線は12時と6時のみ）
- 時計の周りを循環する矢印（1/4周程度）
- 針は短針のみ、または針なし
```

**ビジュアルイメージ**:
```
  ⟳⏱
```

**実装ノート**:
- 時計は正円
- 循環矢印は時計の外側に配置
- SF Symbol代替: `clock.arrow.circlepath`

---

### 4.4 活動量アイコン

**コンセプト**: 歩く人 または 靴/足跡

```
デザイン要素:
オプション A: 歩く人のシルエット
- スティックフィギュア風
- 片足を前に出した動きのあるポーズ

オプション B: スニーカー/靴
- 横向きのシンプルな靴
- 動きを示す短い線（モーションライン）
```

**ビジュアルイメージ**:
```
オプションA: 🚶 (スティック版)
オプションB: 👟 → (シンプル靴+動線)
```

**実装ノート**:
- オプションBを推奨（よりシンプル）
- SF Symbol代替: `figure.walk` または `shoeprints.fill`

---

### 4.5 ストレスグラフ

**コンセプト**: 波形グラフ（メトリクスカードではなくグラフ用）

```
デザイン要素:
- なだらかな波形線
- 背景にグリッドライン（薄い）
- グラデーション塗りつぶし（緑→黄→赤）
```

**実装ノート**:
- これはアイコンではなくグラフコンポーネント
- SwiftUI Charts または カスタムPath描画で実装

---

## 5. その他のアイコン

### 5.1 ナビゲーション・UIアイコン

| 用途 | コンセプト | SF Symbol |
|-----|----------|-----------|
| ホーム | 家 | `house` |
| コンディション | グラフ | `chart.bar` |
| 設定 | 歯車 | `gearshape` |
| 戻る | 左矢印 | `chevron.left` |
| 詳細 | 右矢印 | `chevron.right` |
| 更新 | 循環矢印 | `arrow.clockwise` |
| カレンダー | カレンダー | `calendar` |

### 5.2 アクション・フィードバックアイコン

| 用途 | コンセプト | SF Symbol |
|-----|----------|-----------|
| 完了 | チェックマーク | `checkmark.circle` |
| 情報 | iマーク | `info.circle` |
| 警告 | 三角 | `exclamationmark.triangle` |
| ヘルプ | ?マーク | `questionmark.circle` |
| 閉じる | ×マーク | `xmark` |

---

## 6. 実装ガイドライン

### 6.1 SwiftUI実装例

```swift
// カスタムアイコンの定義
enum MetricIcon: String {
    case sleep = "icon_sleep"
    case hrv = "icon_hrv"
    case rhythm = "icon_rhythm"
    case activity = "icon_activity"
}

// アイコンビューコンポーネント
struct MetricIconView: View {
    let icon: MetricIcon
    let size: IconSize
    let status: MetricStatus

    enum IconSize: CGFloat {
        case small = 24
        case medium = 32
        case large = 48
        case extraLarge = 64
    }

    var body: some View {
        Image(icon.rawValue)
            .resizable()
            .scaledToFit()
            .frame(width: size.rawValue, height: size.rawValue)
            .foregroundColor(status.color)
    }
}

// 使用例
MetricIconView(icon: .sleep, size: .medium, status: .good)
```

### 6.2 アセット管理

```
Assets.xcassets/
├── Icons/
│   ├── Metrics/
│   │   ├── icon_sleep.imageset/
│   │   ├── icon_hrv.imageset/
│   │   ├── icon_rhythm.imageset/
│   │   └── icon_activity.imageset/
│   └── UI/
│       ├── icon_home.imageset/
│       └── ...
```

### 6.3 SF Symbolsとの併用

カスタムアイコンが準備できるまで、SF Symbolsで代替可能:

```swift
// 暫定実装
struct MetricIconView: View {
    let icon: MetricIcon

    var sfSymbolName: String {
        switch icon {
        case .sleep: return "moon.zzz"
        case .hrv: return "heart.text.square"
        case .rhythm: return "clock.arrow.circlepath"
        case .activity: return "figure.walk"
        }
    }

    var body: some View {
        Image(systemName: sfSymbolName)
            .font(.system(size: 24, weight: .regular))
    }
}
```

---

## 7. アクセシビリティ

### 7.1 要件

- すべてのアイコンにアクセシビリティラベルを設定
- 色だけに依存しない（形状でも区別可能に）
- コントラスト比 4.5:1 以上を確保

### 7.2 実装例

```swift
Image(icon.rawValue)
    .accessibilityLabel(icon.accessibilityLabel)
    .accessibilityHint("メトリクスの詳細を表示します")

extension MetricIcon {
    var accessibilityLabel: String {
        switch self {
        case .sleep: return "睡眠スコア"
        case .hrv: return "HRVスコア"
        case .rhythm: return "リズムスコア"
        case .activity: return "活動量スコア"
        }
    }
}
```

---

## 8. ダークモード対応

### 8.1 カラー調整

| 要素 | ライトモード | ダークモード |
|-----|------------|------------|
| アイコン線 | Primary (#7CB342) | Primary Light (#9CCC65) |
| 背景 | White | Dark Gray (#1C1C1E) |
| 非アクティブ | Gray (#9E9E9E) | Light Gray (#AEAEB2) |

### 8.2 実装

```swift
extension Color {
    static let metricIconPrimary = Color("MetricIconPrimary")
    // Assets.xcassets で Light/Dark の色を定義
}
```

---

## 9. 移行計画

### 9.1 フェーズ

1. **Phase 4.5**: SF Symbolsベースの暫定実装
2. **Phase 6以降**: カスタムアイコンアセットの導入
3. **最終**: 全アイコンをカスタムアセットに置き換え

### 9.2 旧絵文字からの移行マッピング

| 旧（絵文字） | 新（アイコン） |
|------------|--------------|
| 💚 | HRVアイコン (icon_hrv) |
| 😴 | 睡眠アイコン (icon_sleep) |
| ⚡ | 活動量アイコン (icon_activity) |
| 🧘 | （廃止→ストレスグラフへ） |
| ⏰ | リズムアイコン (icon_rhythm) |
