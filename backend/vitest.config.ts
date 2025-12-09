import { defineWorkersConfig } from '@cloudflare/vitest-pool-workers/config';

export default defineWorkersConfig({
  test: {
    // Cloudflare Workers 環境でテストを実行
    poolOptions: {
      workers: {
        wrangler: { configPath: './wrangler.toml' },
      },
    },

    // カバレッジ設定
    coverage: {
      enabled: false, // CI環境で問題が解決するまで一時的に無効化
      provider: 'c8',
      reporter: ['text', 'json', 'html', 'lcov'],
      reportsDirectory: './coverage',
      include: ['src/**/*.ts'],
      exclude: [
        'src/**/*.test.ts',
        'src/**/*.spec.ts',
        'src/**/index.ts',
        'src/types/**',
      ],
      thresholds: {
        // カバレッジ閾値（MVPでは緩めに設定）
        lines: 60,
        functions: 60,
        branches: 60,
        statements: 60,
      },
    },

    // テストファイルのパターン
    include: ['src/**/*.{test,spec}.ts'],
    exclude: ['node_modules', 'dist', '.wrangler'],

    // グローバル設定
    globals: true,

    // タイムアウト
    testTimeout: 10000,

    // レポーター
    reporters: ['verbose'],
  },
});
