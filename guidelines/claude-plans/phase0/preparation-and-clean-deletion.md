# Phase 0: 準備・整理・クリーン削除プラン

## 🎯 Goal: Clean Start Foundation for Complete Rebuild

**Philosophy**: CLAUDE.md 準拠で既存の技術債務から完全に解放し、新仕様に基づくクリーンな再実装基盤を準備

## 📊 現状分析

### 保持すべき要素

- ✅ **プロジェクト構造**: Xcode project files (.xcodeproj)
- ✅ **設定ファイル**: Info.plist, entitlements
- ✅ **アセット**: Assets.xcassets (アイコン、カラー)
- ✅ **Localization**: ja.lproj, en.lproj (文字列リソース)
- ✅ **CI 設定**: .github workflows (既存 CI pipeline)

### 削除対象（ごちゃごちゃしたコード）

- ❌ **全 Swift ファイル**: ViewModels, Services, Models 等の混乱したコード
- ❌ **複雑な統合**: Phase 2 で導入された複雑な Services layer
- ❌ **重複したデータモデル**: HRVData/HRVMetrics 等の重複
- ❌ **壊れた統合**: HealthKitManager 等の複雑な統合コード

## 🗂️ 段階的実行プラン

### Step 1: ブランチ準備 (15 分)

1. main ブランチに戻る
2. 新ブランチ `feature/clean-rebuild-phase1` 作成
3. 現在の作業ブランチの成果をドキュメント化

### Step 2: 既存コード分析・保存 (15 分)

1. 保持すべきアセット・設定の特定
2. 有用なコードパターンの保存（参考用）
3. 削除対象ファイルリストの作成

### Step 3: クリーン削除実行 (15 分)

1. 全 Swift ソースファイル削除
2. プロジェクト構造クリーンアップ
3. 基本ファイル構成の再構築

### Step 4: 新基盤準備 (15 分)

1. 新仕様に基づく基本ディレクトリ構造作成
2. 基本の ContentView.swift, App.swift 作成
3. 初期コンパイル成功確認

## 📋 成功基準

- [ ] 既存技術債務から完全に解放
- [ ] プロジェクトが正常にコンパイル（基本状態）
- [ ] 新仕様実装の準備完了
- [ ] CI pipeline 基本動作確認

## 🎯 Phase 1 準備完了状態

- Clean Xcode project structure
- 基本 SwiftUI アプリケーション動作
- 新仕様実装の明確な出発点
- CLAUDE.md 準拠の開発環境

---

**Risk Level**: Low (保存作業なので安全)  
**Next**: Phase 1 Digital Cockpit 基盤実装開始
