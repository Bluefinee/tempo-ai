---
description: リント・フォーマットエラーを自動修正
allowed-tools: Bash, Read, Edit, Glob, Grep
---

# リント修正コマンド

対象: $ARGUMENTS（未指定の場合は全体）

## 実行手順

### 1. アプリ（ESLint + TypeScript）

```bash
cd app
npm run lint -- --fix
npm run typecheck
```

### 2. バックエンド（Biome）

```bash
cd backend
pnpm check:fix
pnpm typecheck
```

### 3. エラーが残っている場合

1. エラーメッセージを確認
2. 自動修正できないものは手動で修正
3. 修正後、再度チェックを実行

### 4. 完了条件

- [ ] `npm run lint` がエラーなしで完了（app）
- [ ] `npm run typecheck` がエラーなしで完了（app）
- [ ] `pnpm check` がエラーなしで完了（backend）
- [ ] `pnpm typecheck` がエラーなしで完了（backend）

## 注意事項

- `any` 型のエラーは `unknown` に置き換える
- 未使用変数は削除する（`_` プレフィックスで抑制しない）
- function 宣言は arrow function に変換する
