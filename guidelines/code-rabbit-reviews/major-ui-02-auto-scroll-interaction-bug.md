# Major Issue: Auto-scroll Pause Logic Bug

## 📍 Location
- **File**: `ios/TempoAI/TempoAI/Views/Onboarding/ValuePropositionPage.swift`
- **Line**: 181
- **Priority**: 🟠 Major

## ❗ Problem Description

**Auto-scroll pause logic does not match "8 seconds of no interaction" intent**

コメントでは "Resume auto-scroll after 8 seconds of no interaction" と記載されているが、現在の実装では早期再開される可能性がある：

### 問題の詳細:
- 各タップが前のものをキャンセルすることなく新しい`asyncAfter`ブロックをスケジュールする
- ユーザーが8秒以内に再度タップした場合、最初にスケジュールされたブロックが依然として発火し、最後のタップから約1秒後（8秒後ではなく）にauto-scrollが再開される

これは微妙だがUXの不具合です。

## 🔧 Recommended Solutions

### 1. DispatchWorkItemを使用した修正

```swift
@State private var resumeAutoScrollWorkItem: DispatchWorkItem?

private func handleFeatureInteraction() {
    HapticFeedback.light.trigger()
    isInteracting = true

    // Resume auto-scroll after 8 seconds of no interaction
    resumeAutoScrollWorkItem?.cancel()
    let workItem = DispatchWorkItem {
        isInteracting = false
    }
    resumeAutoScrollWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: workItem)
}
```

### 2. Task/async-awaitへの将来的移行

`.claude/swift-coding-standards.md`の「async/await強制」方針に従い、将来的にはGCDベースの実装を`Task.sleep`/構造化同期に移行することも検討。

## 🚀 Implementation Steps

1. `@State private var resumeAutoScrollWorkItem: DispatchWorkItem?`を追加
2. `handleFeatureInteraction()`メソッドを修正
3. 既存の`asyncAfter`実装をDispatchWorkItem版に置換
4. テストして正しく8秒後に再開されることを確認

## 🎯 Success Criteria

- [ ] ユーザーのタップから正確に8秒後にauto-scrollが再開される
- [ ] 複数のタップが正しくデバウンスされる
- [ ] UXが意図通りに動作する
- [ ] 既存の機能に影響なし

## 🧪 Testing

1. ValuePropositionPageを開く
2. auto-scrollが開始されることを確認
3. 何度かタップして一時停止
4. 8秒待って自動再開されることを確認
5. 8秒以内に再度タップして、タイマーがリセットされることを確認

---

**Code Rabbit Comment ID**: Found in PR #9 review  
**Related Standards**: `.claude/swift-coding-standards.md` - async/await推奨  
**Effort**: Low (simple logic fix)