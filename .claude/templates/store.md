# Zustand ストアテンプレート

## 基本ストア

```typescript
// ============================================
// app/src/stores/[storeName].ts
// ============================================

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// ============================================
// Types
// ============================================

export interface StoreState {
  // データ
  data: DataType | null;
  items: Item[];

  // UI状態
  isLoading: boolean;
  error: string | null;

  // アクション
  setData: (data: DataType) => void;
  addItem: (item: Item) => void;
  removeItem: (id: string) => void;
  fetchData: () => Promise<void>;
  reset: () => void;
}

interface DataType {
  id: string;
  value: number;
  updatedAt: Date;
}

interface Item {
  id: string;
  name: string;
}

// ============================================
// Initial State
// ============================================

const initialState = {
  data: null,
  items: [],
  isLoading: false,
  error: null,
};

// ============================================
// Store
// ============================================

export const useStore = create<StoreState>()(
  persist(
    (set, get) => ({
      // ============================================
      // State
      // ============================================
      ...initialState,

      // ============================================
      // Actions
      // ============================================

      setData: (data) => {
        set({ data, error: null });
      },

      addItem: (item) => {
        set((state) => ({
          items: [...state.items, item],
        }));
      },

      removeItem: (id) => {
        set((state) => ({
          items: state.items.filter((item) => item.id !== id),
        }));
      },

      fetchData: async () => {
        set({ isLoading: true, error: null });

        try {
          // API呼び出し
          const response = await apiClient.fetchData();

          if (response.success) {
            set({
              data: response.data,
              isLoading: false,
            });
          } else {
            set({
              error: response.error ?? 'Unknown error',
              isLoading: false,
            });
          }
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Unknown error',
            isLoading: false,
          });
        }
      },

      reset: () => {
        set(initialState);
      },
    }),
    {
      name: 'store-name-storage',
      storage: createJSONStorage(() => AsyncStorage),
      // 永続化するプロパティを限定
      partialize: (state) => ({
        data: state.data,
        items: state.items,
      }),
    }
  )
);

// ============================================
// Selectors
// ============================================

/**
 * データが存在するかどうか
 */
export const selectHasData = (state: StoreState): boolean =>
  state.data !== null;

/**
 * アイテム数
 */
export const selectItemCount = (state: StoreState): number =>
  state.items.length;

/**
 * ローディング中かどうか
 */
export const selectIsLoading = (state: StoreState): boolean =>
  state.isLoading;

/**
 * エラーメッセージ
 */
export const selectError = (state: StoreState): string | null =>
  state.error;

/**
 * 特定のアイテムを取得
 */
export const selectItemById = (id: string) =>
  (state: StoreState): Item | undefined =>
    state.items.find((item) => item.id === id);
```

---

## 使用例

```typescript
// コンポーネントでの使用

import { useStore, selectHasData, selectIsLoading } from '@/stores/[storeName]';

export const MyComponent: React.FC = () => {
  // ✅ Good: セレクターで必要なプロパティのみ選択
  const hasData = useStore(selectHasData);
  const isLoading = useStore(selectIsLoading);
  const fetchData = useStore((state) => state.fetchData);

  // ❌ Bad: ストア全体を選択（不要な再レンダリング）
  // const store = useStore();

  useEffect(() => {
    if (!hasData) {
      fetchData();
    }
  }, [hasData, fetchData]);

  if (isLoading) {
    return <LoadingView />;
  }

  return <DataDisplay />;
};
```

---

## 複雑なストア（分割構成）

```
stores/
├── [storeName]/
│   ├── index.ts      # メインストア
│   ├── types.ts      # 型定義
│   ├── selectors.ts  # セレクター関数
│   └── actions.ts    # アクション（オプション）
```

### types.ts

```typescript
export interface StoreState {
  // 状態
}

export interface StoreActions {
  // アクション
}

export type Store = StoreState & StoreActions;
```

### selectors.ts

```typescript
import type { Store } from './types';

export const selectData = (state: Store) => state.data;
export const selectIsLoading = (state: Store) => state.isLoading;
```

### index.ts

```typescript
import { create } from 'zustand';
import type { Store } from './types';

export const useStore = create<Store>()((set, get) => ({
  // 実装
}));

export * from './types';
export * from './selectors';
```

---

## パターン

### Optimistic Update

```typescript
updateItem: async (id, updates) => {
  const previousItems = get().items;

  // 1. 即座にUIを更新（楽観的）
  set((state) => ({
    items: state.items.map((item) =>
      item.id === id ? { ...item, ...updates } : item
    ),
  }));

  try {
    // 2. APIに送信
    await apiClient.updateItem(id, updates);
  } catch (error) {
    // 3. 失敗時はロールバック
    set({ items: previousItems, error: 'Update failed' });
  }
},
```

### Derived State

```typescript
// ストアに派生状態を持たせない
// セレクターで計算する

export const selectTotalValue = (state: Store): number =>
  state.items.reduce((sum, item) => sum + item.value, 0);

export const selectAverageValue = (state: Store): number => {
  const total = selectTotalValue(state);
  return state.items.length > 0 ? total / state.items.length : 0;
};
```

---

## チェックリスト

- [ ] 型定義が明確
- [ ] 初期状態が定義されている
- [ ] 永続化対象が適切に限定されている
- [ ] セレクター関数が定義されている
- [ ] エラー状態が適切に管理されている
- [ ] reset アクションがある
