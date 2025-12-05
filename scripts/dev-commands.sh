#!/bin/bash
# 
# Development Commands Automation Script
# TempoAI Project Phase 0 - Development Efficiency
# 
# Usage: ./scripts/dev-commands.sh {command}
# Available commands: test-all, build-ios, dev-backend, lint-fix, help
#

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}🚀 Tempo AI - Development Commands${NC}"
    echo -e "${BLUE}====================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Command implementations
run_all_tests() {
    print_header
    echo -e "${BLUE}🧪 Running comprehensive test suite...${NC}"
    echo ""
    
    # Check if quality-check script exists
    if [[ -f "scripts/quality-check-all.sh" ]]; then
        print_info "Using existing quality-check-all.sh script"
        ./scripts/quality-check-all.sh
    elif [[ -f "scripts/quality-check.sh" ]]; then
        print_info "Using quality-check.sh script"
        ./scripts/quality-check.sh
    else
        print_info "Running manual quality checks..."
        
        # iOS Tests
        print_info "Running iOS quality checks..."
        if cd ios && ./scripts/quality-check.sh; then
            print_success "iOS quality checks passed"
            cd ..
        else
            print_error "iOS quality checks failed"
            exit 1
        fi
        
        # Backend Tests
        print_info "Running backend quality checks..."
        if cd backend && pnpm run quality:check 2>/dev/null || (pnpm run type-check && pnpm run test && pnpm run lint:check); then
            print_success "Backend quality checks passed"
            cd ..
        else
            print_error "Backend quality checks failed"
            exit 1
        fi
    fi
    
    print_success "All tests completed successfully!"
}

build_ios() {
    print_header
    echo -e "${BLUE}📱 Building iOS application...${NC}"
    echo ""
    
    print_info "Switching to iOS directory..."
    cd ios
    
    print_info "Running iOS build..."
    if xcodebuild -scheme TempoAI -destination 'platform=iOS Simulator,name=iPhone 15' build; then
        print_success "iOS build completed successfully"
    else
        print_error "iOS build failed"
        exit 1
    fi
    
    cd ..
    print_success "iOS build process completed!"
}

start_dev_backend() {
    print_header
    echo -e "${BLUE}💻 Starting backend development server...${NC}"
    echo ""
    
    print_info "Switching to backend directory..."
    cd backend
    
    print_info "Installing dependencies if needed..."
    pnpm install --silent
    
    print_info "Starting development server..."
    print_warning "Press Ctrl+C to stop the server"
    echo ""
    
    # Start the dev server
    pnpm run dev
}

lint_fix() {
    print_header
    echo -e "${BLUE}🔧 Running automatic lint fixes...${NC}"
    echo ""
    
    # iOS linting fixes
    print_info "Fixing iOS linting issues..."
    if cd ios && ./scripts/fix-all.sh; then
        print_success "iOS lint fixes applied"
        cd ..
    else
        print_warning "iOS fix script not found, running manual fixes..."
        cd ios
        if swiftlint --fix; then
            print_success "iOS SwiftLint fixes applied"
        else
            print_warning "SwiftLint fix encountered issues"
        fi
        cd ..
    fi
    
    # Backend linting fixes
    print_info "Fixing backend linting issues..."
    if cd backend; then
        # Try different fix commands based on what's available
        if pnpm run lint:fix 2>/dev/null; then
            print_success "Backend lint fixes applied (using pnpm run lint:fix)"
        elif pnpm run quality:fix 2>/dev/null; then
            print_success "Backend quality fixes applied"
        elif command -v biome &> /dev/null; then
            print_info "Using Biome for formatting..."
            npx biome check --write . && npx biome format --write .
            print_success "Biome fixes applied"
        else
            print_warning "No automatic backend fix command found"
        fi
        cd ..
    fi
    
    print_success "Lint fix process completed!"
    print_info "Run './scripts/dev-commands.sh test-all' to verify fixes"
}

show_help() {
    print_header
    echo ""
    echo "Available commands:"
    echo ""
    echo -e "${GREEN}test-all${NC}     - Run comprehensive test suite (iOS + Backend)"
    echo -e "${GREEN}build-ios${NC}    - Build iOS application for simulator"
    echo -e "${GREEN}dev-backend${NC}  - Start backend development server"
    echo -e "${GREEN}lint-fix${NC}     - Automatically fix linting issues"
    echo -e "${GREEN}help${NC}         - Show this help message"
    echo ""
    echo "Examples:"
    echo -e "  ${BLUE}./scripts/dev-commands.sh test-all${NC}"
    echo -e "  ${BLUE}./scripts/dev-commands.sh build-ios${NC}"
    echo -e "  ${BLUE}./scripts/dev-commands.sh dev-backend${NC}"
    echo -e "  ${BLUE}./scripts/dev-commands.sh lint-fix${NC}"
    echo ""
    echo "For more detailed documentation, see: guidelines/claude-plans/phase-0-implementation-plan.md"
}

# Main command routing
main() {
    case "$1" in
        "test-all")
            run_all_tests
            ;;
        "build-ios")
            build_ios
            ;;
        "dev-backend")
            start_dev_backend
            ;;
        "lint-fix")
            lint_fix
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        "")
            print_error "No command specified"
            echo ""
            show_help
            exit 1
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Error handling
trap 'print_error "Command interrupted"; exit 130' INT
trap 'print_error "Command failed"; exit 1' ERR

# Run main function with all arguments
main "$@"