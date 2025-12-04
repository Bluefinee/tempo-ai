# Tempo AI Project Quality Management
.PHONY: help check fix install setup ci api ios clean test test-coverage test-mutation test-real-api test-performance ci-full dev-api status

# デフォルトターゲット
help:
	@echo "🚀 Tempo AI Development Commands"
	@echo "================================="
	@echo ""
	@echo "Quality Management:"
	@echo "  make check     - 全プロジェクトの品質チェック実行"
	@echo "  make fix       - 全プロジェクトの自動修正実行"
	@echo "  make api       - TypeScript API品質チェック"
	@echo "  make ios       - Swift iOS品質チェック"
	@echo ""
	@echo "Testing:"
	@echo "  make test      - 全テスト実行（カバレッジ含む）"
	@echo "  make test-coverage - テストカバレッジレポート生成"
	@echo "  make test-mutation - ミューテーションテスト実行"
	@echo "  make test-performance - パフォーマンステスト実行"
	@echo ""
	@echo "Development:"
	@echo "  make setup     - 開発環境の初期セットアップ"
	@echo "  make install   - 依存関係のインストール"
	@echo "  make ci        - CI環境での動作確認"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean     - 生成ファイルのクリーンアップ"

# 品質チェック（全体）
check:
	@echo "🔍 Running full project quality checks..."
	@./scripts/quality-check-all.sh

# 自動修正（全体）
fix:
	@echo "🛠️ Auto-fixing all issues..."
	@./scripts/fix-all.sh

# TypeScript API品質チェック
api:
	@echo "📝 Checking TypeScript API..."
	@cd backend && pnpm run quality:check

# Swift iOS品質チェック
ios:
	@echo "📱 Checking Swift iOS..."
	@cd ios && ./scripts/quality-check.sh

# 初期セットアップ
setup:
	@echo "⚙️ Setting up development environment..."
	@echo "Checking dependencies..."
	@command -v brew >/dev/null 2>&1 || { echo "❌ Error: Homebrew is required but not installed. Visit https://brew.sh"; exit 1; }
	@command -v pnpm >/dev/null 2>&1 || { echo "❌ Error: pnpm is required but not installed. Run 'npm install -g pnpm'"; exit 1; }
	@echo "Installing Homebrew dependencies..."
	@brew install swiftlint swift-format
	@echo "Installing Node.js dependencies..."
	@cd backend && pnpm install
	@echo "Making scripts executable..."
	@chmod +x scripts/*.sh ios/scripts/*.sh
	@echo "✅ Setup completed!"

# 依存関係インストール
install:
	@echo "📦 Installing dependencies..."
	@cd backend && pnpm install

# CI模擬実行
ci:
	@echo "🚀 Running CI simulation..."
	@./scripts/quality-check-all.sh
	@cd backend && pnpm run test:api

# テスト実行
test:
	@echo "🧪 Running all tests..."
	@cd backend && pnpm run test:coverage
	@cd backend && pnpm run test:api

# テストカバレッジレポート
test-coverage:
	@echo "📊 Generating test coverage reports..."
	@cd backend && pnpm run test:coverage
	@echo "✅ Coverage reports generated in backend/coverage/"

# ミューテーションテスト（コストセーフ）
test-mutation:
	@echo "🧬 Running mutation testing (cost-safe)..."
	@cd backend && pnpm add -D @stryker-mutator/core @stryker-mutator/vitest-runner @stryker-mutator/typescript-checker
	@echo "💡 Note: Using mocked APIs to avoid costs"
	@cd backend && ENABLE_COSTLY_TESTS=false npx stryker run --mutate 'src/**/*.ts' --test-runner vitest
	@echo "✅ Mutation testing completed!"

# 実APIテスト（コスト注意）
test-real-api:
	@echo "💸 WARNING: This will use real APIs and incur costs!"
	@echo "💰 Estimated cost: ~$0.10-0.50 per run"
	@if [ -t 0 ] && [ "$$CI" != "true" ]; then \
		read -p "Continue? (y/N): " confirm && [ "$$confirm" = "y" ]; \
	else \
		echo "🤖 CI environment detected - skipping interactive prompt"; \
	fi
	@echo "🚨 Running tests with REAL API calls..."
	@cd backend && ENABLE_COSTLY_TESTS=true pnpm run test
	@echo "✅ Real API testing completed!"

# パフォーマンステスト
test-performance:
	@echo "⚡ Running performance tests..."
	@cd backend && pnpm run test tests/performance/
	@echo "✅ Performance testing completed!"

# CI環境模擬（拡張版）
ci-full:
	@echo "🚀 Running full CI pipeline simulation..."
	@echo "1. Code quality checks..."
	@./scripts/quality-check-all.sh
	@echo "2. Test coverage analysis..."
	@cd backend && pnpm run test:coverage
	@echo "3. Security audit..."
	@cd backend && pnpm run security:check
	@echo "4. Build verification..."
	@cd backend && pnpm run build
	@echo "✅ Full CI pipeline completed!"

# クリーンアップ
clean:
	@echo "🧹 Cleaning up..."
	@cd backend && pnpm run clean
	@echo "✅ Cleanup completed!"

# 開発サーバー起動（API）
dev-api:
	@echo "🚀 Starting API development server..."
	@cd backend && pnpm run dev

# 開発環境確認
status:
	@echo "📊 Development Environment Status"
	@echo "=================================="
	@echo ""
	@echo "Tools Status:"
	@if command -v swiftlint &> /dev/null; then echo "✅ SwiftLint: Installed"; else echo "❌ SwiftLint: Not installed"; fi
	@if command -v swift-format &> /dev/null; then echo "✅ swift-format: Installed"; else echo "❌ swift-format: Not installed"; fi
	@if command -v pnpm &> /dev/null; then echo "✅ pnpm: Installed"; else echo "❌ pnpm: Not installed"; fi
	@if command -v xcodebuild &> /dev/null; then echo "✅ Xcode: Installed"; else echo "❌ Xcode: Not installed"; fi
	@echo ""
	@echo "Project Status:"
	@if [ -d "backend/node_modules" ]; then echo "✅ API Dependencies: Installed"; else echo "❌ API Dependencies: Not installed"; fi
	@if [ -f "ios/.swiftlint.yml" ]; then echo "✅ SwiftLint Config: Present"; else echo "❌ SwiftLint Config: Missing"; fi