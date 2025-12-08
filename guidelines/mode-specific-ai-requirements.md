# ライフスタイルモード別AI体験 - 技術要件仕様書

## 概要

ユーザーフィードバックに基づき、スタンダード/アスリートモードによってAIプロンプト、出力情報、体験全体を根本的に変更する必要性が明確になりました。この文書では、その技術実装要件を定義します。

---

## 1. モード別ペルソナシステム アーキテクチャ

### A. 動的プロンプト構築システム

```typescript
interface ModeAwarePromptBuilder {
  buildPrompt(
    userMode: 'standard' | 'athlete',
    activeTags: FocusTag[],
    context: HealthContext
  ): string;
  
  getModePersona(mode: UserMode): PersonaDefinition;
  getCombinedPersona(mode: UserMode, tags: FocusTag[]): CombinedPersona;
}

interface PersonaDefinition {
  name: string;
  core_identity: string;
  tone_guidelines: string[];
  response_complexity: 'simple' | 'detailed';
  technical_depth: 'minimal' | 'comprehensive';
  encouragement_style: 'nurturing' | 'motivational';
}
```

### B. モード別レスポンス処理

```typescript
interface ModeSpecificResponse {
  standard: {
    max_technical_terms: 2;
    sentence_structure: 'gentle_suggestions';
    data_presentation: 'human_friendly';
    action_complexity: 'micro_actions'; // 2-5分
    empathy_level: 'high';
  };
  
  athlete: {
    max_technical_terms: 8;
    sentence_structure: 'strategic_analysis';
    data_presentation: 'metrics_focused';
    action_complexity: 'strategic_interventions'; // 10-30分
    empathy_level: 'objective_support';
  };
}
```

---

## 2. 実装要件

### A. Backend (Cloudflare Workers)

**必須変更点:**
1. **PromptBuilder の拡張**
   - `UserMode` パラメータの追加
   - モード別テンプレートシステム
   - 動的ペルソナ注入機能

2. **Response Validation の強化**
   - モード別レスポンス品質チェック
   - スタンダード: 共感度スコア
   - アスリート: データ正確性スコア

3. **Caching Strategy の調整**
   - スタンダード: 80分キャッシュ（安定した生活パターン）
   - アスリート: 60分キャッシュ（動的なトレーニングニーズ）

### B. iOS App

**必須変更点:**
1. **AIAnalysisService の拡張**
   ```swift
   func requestAnalysis(
       userMode: UserMode,
       activeTags: Set<FocusTag>,
       // 既存パラメータ...
   ) async throws -> ModeSpecificAnalysisResponse
   ```

2. **UI Component の調整**
   - モード別データ表示密度
   - スタンダード: シンプルなカード形式
   - アスリート: 詳細なメトリクス表示

3. **LocalizationManager の拡張**
   - モード別メッセージングキーの管理
   - 動的な言語調整機能

---

## 3. データ構造の拡張

### A. Enhanced AI Request

```typescript
interface ModeAwareAIRequest extends AIAnalysisRequest {
  userMode: 'standard' | 'athlete';
  modePreferences: {
    detail_level: 'basic' | 'advanced';
    technical_terms: boolean;
    coaching_style: 'supportive' | 'strategic';
  };
  
  // モード別データ重要度
  dataWeighting: {
    standard: {
      stress_management: 0.4,
      sleep_quality: 0.3,
      gentle_suggestions: 0.3
    },
    athlete: {
      performance_metrics: 0.4,
      recovery_efficiency: 0.3,
      strategic_timing: 0.3
    }
  };
}
```

### B. Mode-Specific Response Schema

```typescript
interface ModeSpecificAnalysisResponse {
  mode: 'standard' | 'athlete';
  
  headline: {
    title: string;
    subtitle: string;
    tone: 'gentle' | 'strategic';
    complexity_score: number; // 1-10
  };
  
  insights: ModeSpecificInsight[];
  suggestions: ModeSpecificSuggestion[];
  
  // モード別メタデータ
  response_metadata: {
    empathy_score?: number;      // Standard mode only
    data_confidence?: number;    // Athlete mode only
    persona_consistency: number; // Both modes
  };
}
```

---

## 4. 品質保証要件

### A. モード別KPI

**Standard Mode:**
- 共感度スコア: >4.2/5.0
- ストレス軽減感: >4.0/5.0  
- アドバイス実行率: >75%
- 「優しさ」評価: >4.5/5.0

**Athlete Mode:**
- データ有用性: >4.0/5.0
- パフォーマンス向上感: >4.2/5.0
- 戦略的洞察度: >4.0/5.0
- 「科学的信頼性」評価: >4.3/5.0

### B. Cross-Mode Testing

**一貫性テスト:**
- 同じデータでの異なるモード応答比較
- ペルソナ逸脱の検出と修正
- モード切り替え時のシームレス体験

---

## 5. 段階的実装戦略

### Phase 1.5: 基盤構築
- [ ] モード別プロンプトシステム実装
- [ ] 基本的なペルソナ切り替え機能
- [ ] レスポンス品質の初期評価

### Phase 2.0: 高度化
- [ ] Focus Tag + Mode の複合ペルソナ
- [ ] 動的データ重要度調整
- [ ] A/Bテストによる最適化

### Phase 2.5: 最適化
- [ ] パフォーマンス最適化
- [ ] コスト効率化
- [ ] 品質保証システム完成

---

## 6. 成功基準

### 技術的成功
- [ ] モード切り替え応答時間 <1秒
- [ ] ペルソナ一貫性 >95%
- [ ] モード別コスト目標達成

### ユーザー体験成功  
- [ ] モード別満足度向上
- [ ] 継続利用率の向上
- [ ] モード適合性の高評価

この要件に基づき、真にパーソナライズされたAI体験を実現します。