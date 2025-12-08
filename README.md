# 🎵 Tempo AI

> **あなたの「テンポ」に合わせたヘルスケアパートナー**  
> AIがヘルスケアデータを分析し、あなたの体調や生活リズムに最適化されたアドバイスを提供

[![CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/ci.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/ci.yml)
[![Backend CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/backend.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/backend.yml)
[![iOS CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/ios.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/ios.yml)
[![Security](https://github.com/Bluefinee/tempo-ai/actions/workflows/security.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/security.yml)

---

## 🎯 **Tempo AIとは**

Tempo AIは、**あなたの生活リズム（テンポ）**に完全に同期する次世代ヘルスケアアシスタントです。

### 💡 **Core Vision**
従来のヘルスケアアプリは「データを表示するだけ」でした。Tempo AIは違います：
- **状況を理解する**: 睡眠不足？気圧低下？ストレス過多？AIが複合的要因を分析
- **個人化されたアドバイス**: スタンダードモード（日常重視）とアスリートモード（パフォーマンス重視）
- **実行可能な提案**: 「何をすべきか」を明確に、小さなアクションから戦略的判断まで

---

## 🌟 **主な特徴**

### 🧠 **6つの専門AI分野**
- **🧠 Work**: 認知パフォーマンス・集中力最適化
- **✨ Beauty**: 美容・スキンケア専門アドバイス  
- **🥗 Diet**: 食事タイミング・栄養最適化
- **🍃 Chill**: ストレス管理・リラクゼーション
- **💤 Sleep**: 睡眠質向上・リカバリー専門
- **🏃‍♂️ Fitness**: 運動習慣・フィットネス最適化

### 📊 **包括的データ統合**
- **HealthKit**: 心拍・HRV・睡眠・活動量の詳細分析
- **環境データ**: 気温・湿度・気圧・大気質・UV指数
- **生活コンテキスト**: 時間帯・天候・個人設定の総合判断

### 🎨 **プレミアムユーザー体験**
- **UX心理学原則**: Fitts's Law, Miller's Law, Aesthetic-Usability Effect適用
- **直感的エネルギー表示**: バッテリー風UIで状態を一目で把握
- **美しいオンボーディング**: Googleスタイルのカラーアクセントとアニメーション
- **🌱 今日のトライ**: すぐに始められる新しい体験提案（2-15分）
- **📅 今週のトライ**: より深い習慣改善の温かい提案（週次配信）

---

## 🏗️ **技術アーキテクチャ**

### 📱 **iOS App (SwiftUI)**
```
┌─────────────────────────────┐
│        Digital Cockpit      │
│  ┌─────────────────────────┐ │
│  │   Energy Visualization  │ │ ← LiquidBatteryView
│  └─────────────────────────┘ │
│  ┌─────────────────────────┐ │
│  │    AI Advice Cards      │ │ ← 個人化アドバイス
│  └─────────────────────────┘ │
│  ┌─────────────────────────┐ │
│  │   Smart Suggestions     │ │ ← Focus Tag別提案
│  └─────────────────────────┘ │
└─────────────────────────────┘
```

### 🔄 **Backend Architecture**
```
┌────────────────┐    HTTPS     ┌─────────────────┐    ┌──────────────┐
│   iOS Client   │─────────────▶│ Cloudflare      │───▶│ Claude API   │
│   (SwiftUI)    │               │ Workers + Hono  │    │ (Anthropic)  │
│                │               │                 │    └──────────────┘
│ • HealthKit    │               │ • TypeScript    │           │
│ • CoreLocation │               │ • Zod Schemas   │           ▼
│ • Native UX    │               │ • Smart Caching │    ┌──────────────┐
└────────────────┘               └─────────────────┘    │ Open-Meteo   │
                                                         │ Weather API  │
                                                         └──────────────┘
```

### 🤖 **AI Processing Pipeline**
```
HealthKit Data + Environmental Context + User Preferences
                        ↓
              Mode-Specific Prompt Engineering
                        ↓
                Claude API Analysis
                        ↓
        Lifestyle-Adapted Response Formatting
                        ↓
              Personalized Actionable Advice
```

---

## 🚀 **Development Setup**

### 🔧 **Requirements**
- **iOS**: Xcode 15+, macOS Sonoma 14+, iPhone実機推奨
- **Backend**: Node.js 20+, pnpm 9+
- **APIs**: Claude API key (Anthropic), Weather API access

### ⚡ **Quick Start**
```bash
# 1. Clone repository
git clone https://github.com/Bluefinee/tempo-ai.git
cd tempo-ai

# 2. One-command setup (Phase 0 dev commands)
./scripts/dev-commands.sh help

# 3. Setup environment
cd backend && cp .dev.vars.example .dev.vars
# Add your Claude API key to .dev.vars

# 4. Start development
./scripts/dev-commands.sh dev-backend    # Backend server
./scripts/dev-commands.sh build-ios      # iOS build
```

### 📱 **iOS Development**
```bash
cd ios/TempoAI
open TempoAI.xcodeproj

# Quality checks
./scripts/dev-commands.sh test-all       # Comprehensive testing
./scripts/dev-commands.sh lint-fix       # Auto-fix issues
```

---

## 📁 **Project Structure**

```
tempo-ai/
├── 📱 ios/TempoAI/              # iOS Application
│   ├── TempoAI/
│   │   ├── Views/
│   │   │   ├── Onboarding/      # Premium onboarding flow
│   │   │   ├── Home/            # Digital cockpit interface
│   │   │   └── Settings/        # Configuration
│   │   ├── Models/              # Data models
│   │   ├── Services/            # HealthKit, AI, Weather
│   │   └── DesignSystem/        # Colors, Typography, Components
│   └── Tests/                   # iOS unit tests
│
├── 🚀 backend/                  # Cloudflare Workers API
│   ├── src/
│   │   ├── routes/              # API endpoints
│   │   ├── services/            # Business logic
│   │   ├── ai/                  # Claude integration
│   │   └── types/               # TypeScript definitions
│   └── tests/                   # Backend tests
│
├── 📚 guidelines/               # Development Documentation
│   ├── development-plans/       # Phase roadmaps
│   ├── messaging-guidelines.md  # AI persona & messaging
│   └── mode-specific-ai-requirements.md
│
└── 🛠️ scripts/                 # Development automation
    └── dev-commands.sh          # Phase 0 unified commands
```

---

## 🎯 **Development Phases & Current Status**

### ✅ **Phase 0: Infrastructure** (Completed)
- Multi-language development environment (iOS + Backend)
- Design system with Google-inspired color accents
- Premium onboarding with UX psychological principles
- Native HealthKit & CoreLocation permissions

### 🔄 **Phase 1: Digital Cockpit** (In Progress)
- **Current**: Mock data display with energy visualization
- **Next**: Real HealthKit data integration, Open-Meteo weather API
- **Target**: Live health + environmental analysis

### 📋 **Phase 1.5: AI Analysis Architecture** (Planned)
- Lifestyle-mode specific AI personas (Partner vs Mentor)
- Claude API integration with smart caching
- Environmental correlation analysis (pressure → headaches, humidity → skin)

### 🎨 **Phase 2: Deep Personalization** (Planned)
- Focus Tags × Lifestyle Mode matrix (8+ unique AI personalities)
- Multi-tag synthesis for complex user needs
- Advanced behavioral pattern recognition

### ⚡ **Phase 3: Optimization** (Planned)
- Performance optimization & cost management
- A/B testing for AI advice effectiveness
- Production-scale monitoring & alerting

---

## 🎨 **Design Principles**

### 🧠 **UX Foundations**
- **Aesthetic-Usability Effect**: Beautiful design perceived as more functional
- **Fitts's Law**: Buttons positioned for optimal thumb reach
- **Miller's Law**: Information limited to 7±2 chunks
- **Progressive Disclosure**: Gradual complexity introduction

### 💬 **Messaging Philosophy**
- **Human-First**: Never treat users as "batteries" or machines
- **Mode-Adaptive**: Different personas for different lifestyles
- **Empathetic**: Understanding external factors (weather, stress)
- **Actionable**: Always provide clear next steps

---

## 🔬 **Technical Innovation**

### 🤖 **6分野専門AI + Try機能**
```typescript
// Example: Focus area-specific advice + Try suggestions
const healthData = { hrv: -10ms, sleep: 5.5h, energy: 40% };

// 🧠 Work Focus
→ Analysis: "集中力が低下気味ですね。重要なタスクは午前中に。"
→ 今日のトライ: "新しいポモドーロテクニック（25分+5分）を試してみませんか？"

// 💤 Sleep Focus  
→ Analysis: "昨夜の睡眠が浅めでした。今夜は早めの就寝を。"
→ 今日のトライ: "カモミールティーで自然な眠気を誘ってみませんか？"
→ 今週のトライ: "睡眠前リチュアルで、ラベンダーオイルマッサージを..."

// 🏃‍♂️ Fitness Focus
→ Analysis: "今日は軽めの運動が最適です。"
→ 今日のトライ: "5分の階段ストレッチで新しい刺激を与えてみませんか？"
```

### 📊 **Smart Data Processing**
- **Static Calculations**: Real-time energy state (local processing)
- **AI Enhancement**: Complex correlation analysis (cloud processing)
- **Hybrid Response**: Immediate feedback + intelligent insights

---

## 🔐 **Privacy & Security**

### 🛡️ **Data Protection**
- **HealthKit Data**: Never leaves device except for analysis requests
- **Location Privacy**: City-level accuracy only, no personal tracking
- **AI Processing**: Encrypted transmission, no data retention
- **GDPR Compliant**: User control over all data usage

### 🔒 **Technical Security**
- HTTPS/TLS 1.3 for all communications
- API key management via environment variables
- Automated dependency vulnerability scanning
- Regular security audits and updates

---

## 📈 **Performance Metrics**

### ⚡ **Response Times**
- **Energy Calculation**: <0.4s (local, instant)
- **AI Analysis**: <2.0s (95th percentile)
- **UI Updates**: <0.1s (immediate feedback)

### 💰 **Cost Optimization**
- **Target**: <$0.10 per daily active user
- **Strategy**: Smart caching + mode-specific token limits
- **Standard Mode**: 1,500 tokens (simpler responses)
- **Athlete Mode**: 2,500 tokens (detailed analysis)

---

## 🧪 **Testing & Quality**

### 🔍 **Testing Strategy**
```bash
# Comprehensive testing
./scripts/dev-commands.sh test-all

# iOS specific
cd ios && ./scripts/quality-check.sh

# Backend specific  
cd backend && pnpm run test
```

### 📊 **Quality Metrics**
- **Backend Coverage**: 80%+ maintained
- **iOS Testing**: XCTest + UI testing
- **Code Quality**: SwiftLint + Biome strict rules
- **Performance**: Real-device testing required

---

## 🤝 **Contributing**

### 📋 **Development Workflow**
1. **Setup**: Follow Phase 0 development commands
2. **Standards**: Read [CLAUDE.md](./CLAUDE.md) and [Swift Standards](.claude/swift-coding-standards.md)
3. **UX Guidelines**: Apply [UX Concepts](.claude/ux_concepts.md) principles
4. **Messaging**: Follow [Messaging Guidelines](guidelines/messaging-guidelines.md)

### 🔄 **PR Process**
1. Create feature branch: `git checkout -b feature/amazing-improvement`
2. Implement following project standards
3. Test comprehensively: `./scripts/dev-commands.sh test-all`
4. Create PR with detailed description
5. Address CodeRabbit review (automated AI code review)

---

## 📚 **Documentation**

### 📖 **Essential Reading**
- **[🏗️ Development Guidelines](./CLAUDE.md)** - Architecture, coding standards, process
- **[📱 Product Specification](./guidelines/tempo-ai-product-spec.md)** - Product vision & requirements  
- **[🎨 UX Design Concepts](./.claude/ux_concepts.md)** - Psychological design principles
- **[💬 Messaging Guidelines](./guidelines/messaging-guidelines.md)** - AI persona & communication

### 🗺️ **Phase Documentation**
- **[Phase 1.5: AI Architecture](./guidelines/development-plans/phase-1.5.md)** - Lifestyle-adaptive AI
- **[Phase 2: Deep Personalization](./guidelines/development-plans/phase-2.md)** - Focus Tags matrix
- **[Phase 3: Optimization](./guidelines/development-plans/phase-3.md)** - Performance & scaling

---

## 🌟 **Technology Stack**

### 📱 **Frontend**
- **Framework**: SwiftUI (iOS 16.0+)
- **Language**: Swift 5.9+ with strict typing
- **Architecture**: MVVM + Combine
- **Design**: Custom design system with 8px grid
- **Performance**: GeometryReader layouts, optimized animations

### 🚀 **Backend**  
- **Runtime**: Cloudflare Workers (Edge computing)
- **Framework**: Hono.js (TypeScript)
- **Language**: TypeScript 5.9+ with strict mode
- **AI**: Claude API (Anthropic) with custom prompt engineering
- **Caching**: KV storage with intelligent invalidation

### 🔗 **External APIs**
- **Health Data**: HealthKit (native iOS integration)
- **Weather**: Open-Meteo (pressure, humidity, UV, air quality)
- **AI**: Claude API with mode-specific personas
- **Location**: CoreLocation (city-level privacy)

---

## 🏃‍♂️ **Getting Started**

### 🚀 **For Users**
1. Download from App Store (coming soon)
2. Complete 5-step onboarding (~2 minutes)
3. Grant HealthKit permissions for personalized analysis
4. Receive daily AI-powered health insights

### 👨‍💻 **For Developers**
```bash
# Complete setup in one command
git clone https://github.com/Bluefinee/tempo-ai.git
cd tempo-ai
./scripts/dev-commands.sh help

# Start developing
./scripts/dev-commands.sh dev-backend     # Start API server
./scripts/dev-commands.sh build-ios       # Build iOS app
```

---

## 🎉 **Recent Achievements**

### 🔄 **v2.0 Onboarding Redesign** (Latest)
- **UX Transformation**: Applied psychological principles for optimal user flow
- **Premium Design**: Google-inspired color accents with minimalist aesthetic  
- **State Management**: Fixed navigation issues with direct condition checking
- **File Organization**: Split large files, removed dead code (CodeRabbit reviewed)

### 🗣️ **Messaging Guidelines v2.0**
- **Human-Centered**: Eliminated mechanical "battery" language
- **Mode-Specific**: Different AI personas for different lifestyles
- **Culturally Aware**: Japanese nuance-appropriate expressions

---

## 🔮 **Roadmap Highlights**

### 🎯 **Phase 1.5 - AI Intelligence** (Q1 2025)
- Claude API integration with lifestyle-specific prompts
- Real-time health + weather correlation analysis
- Smart caching for cost optimization (<$0.10/user/day)

### 🎨 **Phase 2 - Hyper-Personalization** (Q2 2025)  
- 8+ unique AI personalities (Standard×Work, Athlete×Beauty, etc.)
- Advanced behavioral pattern recognition
- Multi-factor decision support system

### ⚡ **Phase 3 - Scale & Optimize** (Q3 2025)
- Performance optimization for 10x user growth
- A/B testing for AI advice effectiveness
- Production monitoring & alerting

---

## 🤖 **AI Integration**

### 🧠 **Persona System**
Tempo AI implements sophisticated mode-adaptive AI personas:

```
┌─────────────────────────────────────────────────────────┐
│              6つの専門AI分野選択                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 🧠 Work      ✨ Beauty    🥗 Diet                    │ │
│  │ 🍃 Chill     💤 Sleep     🏃‍♂️ Fitness                 │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                         │
│  選択された分野 → 専門AIスペシャリスト活性化                │
└─────────────────────────────────────────────────────────┘
                                ↓
                    専門分野別AI分析 + Try提案
                                ↓
              今日のトライ + 今週のトライ + 通常アドバイス
```

---

## 🎨 **Design Philosophy**

### 🎯 **"Digital Cockpit" Concept**
Unlike traditional health dashboards, Tempo AI provides:
- **Immediate Answers**: Not just data, but "what should I do now?"
- **Contextual Intelligence**: Considers weather, stress, schedule
- **Beautiful Functionality**: Premium UI that users want to open daily

### 🌈 **Visual Design Language**
- **Minimalist Foundation**: Clean typography, ample whitespace
- **Color Accents**: Google-inspired pops of color for key interactions
- **Smooth Animations**: Spring physics for natural, delightful feedback
- **Intuitive Metaphors**: Energy visualization without mechanical language

---

## 📊 **Current Implementation Status**

### ✅ **Completed**
- Premium onboarding with native permission dialogs
- 6 Focus Areas specialization (Work/Beauty/Diet/Chill/Sleep/Fitness)
- Simplified UX (removed redundant lifestyle selection)
- Energy state visualization (battery-style UI)
- Mock AI advice generation with specialist personas
- Comprehensive design system with Google-inspired accents

### 🔄 **In Development**
- Real HealthKit data integration
- Open-Meteo weather API connection  
- Claude AI analysis with focus area-specific prompts
- Smart caching layer

### 📋 **Upcoming (Phase 1.5+)**
- **今日のトライ機能**: 各分野での即実行可能な新体験提案
- **今週のトライ機能**: 月曜配信の温かい習慣改善提案
- Advanced multi-focus area synthesis (Sleep×Beauty, Work×Fitness等)
- Trial success tracking and personalized recommendation engine

---

## 🏆 **Recognition & Quality**

### 🤖 **AI Code Review**
- **CodeRabbit Integration**: Automated code quality assessment
- **11/11 Review Points**: Completely addressed in latest version
- **Swift Standards**: 100% compliance with project coding standards

### 🎨 **Design Excellence**
- **UX Psychology**: Evidence-based psychological principles
- **Accessibility**: WCAG 2.1 AA compliance planned
- **Performance**: Sub-400ms response times for core interactions

---

## 📞 **Support & Community**

### 🐛 **Issue Reporting**
- GitHub Issues for bugs and feature requests
- Please include device model, iOS version, and steps to reproduce

### 💡 **Feature Suggestions**
- Check existing Phase roadmaps before suggesting
- Focus on user benefit and technical feasibility

### 🎯 **Contributing Guidelines**
- Follow [CLAUDE.md](./CLAUDE.md) development standards
- Apply [UX Concepts](.claude/ux_concepts.md) for UI/UX changes
- Use [Messaging Guidelines](guidelines/messaging-guidelines.md) for text

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ using [Claude Code](https://claude.ai/code)**

*Last updated: December 2025 | Version: 2.0 (Onboarding Redesign)*