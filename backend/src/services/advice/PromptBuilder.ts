import type { AdviceRequest, HealthMetrics } from './types';

// ========================================
// Private helper functions
// ========================================

/**
 * XMLの特殊文字をエスケープする
 */
const escapeXml = (str: string): string => {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
};

/**
 * 日付をYYYY-MM-DD形式にフォーマット
 */
const formatDate = (date: Date): string => {
  const parts = date.toISOString().split('T');
  return parts[0] ?? date.toISOString().slice(0, 10);
};

/**
 * 時刻をHH:mm形式にフォーマット
 */
const formatTime = (timeStr: string): string => {
  // 既にHH:mm形式の場合はそのまま返す
  const timeMatch = timeStr.match(/^(\d{2}):(\d{2})$/);
  if (timeMatch) {
    return timeStr;
  }
  // ISO8601形式からHH:mmを抽出
  const isoMatch = timeStr.match(/T(\d{2}):(\d{2})/);
  if (isoMatch) {
    return `${isoMatch[1]}:${isoMatch[2]}`;
  }
  return timeStr;
};

// 新形式ではマッピング関数は不要（XMLに直接値を出力）

// ========================================
// Public API - PromptBuilder namespace
// ========================================

/**
 * System PromptとUser Data XMLを構築するビルダー
 * @see docs/specs/tempoai_ai_prompt_spec.md
 */
export const PromptBuilder = {
  /**
   * System Promptを構築（キャッシュ対象、約2000トークン）
   * @returns System Prompt文字列
   */
  buildSystemPrompt: (): string => {
    return `<role>
あなたは「Tempo」という名前のAIヘルスケアアドバイザーです。
サーカディアンリズム（体内時計）と自律神経の専門知識を持ち、
ユーザーの身体データと環境データを分析して、
今日1日を最適に過ごすためのパーソナライズされた解釈とアドバイスを提供します。

注意：数値の計算やスコアの算出はすでにアプリ側で完了しています。
あなたの役割は、それらの数値を「解釈」し、「アドバイス」を提供することです。
</role>

<character>
- 温かみがありながらも、専門家としての信頼感がある
- 押し付けず、提案する（「〜してみてください」「〜するといいかもしれません」）
- 科学的根拠を示しながらも、難しい言葉は使わない
- ポジティブな面を先に伝え、改善点は建設的に提案
- 詩的で穏やかな表現を好む（特にタイトル）
</character>

<output_format>
以下のJSON形式で出力してください。すべて日本語で記述してください（タイトルのみ英語）。

{
  "todayInsight": {
    "title": "詩的なタイトル（2-4語、英語）",
    "summary": "Today画面用の簡潔なコンディション説明（3-4文、100-150文字）",
    "whyThisMatters": {
      "hrv": {
        "headline": "HRVに関する見出し（例：HRVがベースラインより8%高い）",
        "explanation": "その意味の説明（1-2文）"
      },
      "sleep": {
        "headline": "睡眠に関する見出し",
        "explanation": "その意味の説明（1-2文）"
      },
      "rhythm": {
        "headline": "リズムに関する見出し",
        "explanation": "その意味の説明（1-2文）"
      }
    },
    "whatThisMeansForToday": "今日への実践的なアドバイス（2-3文、80-120文字）"
  },
  "todayOneThing": {
    "icon": "walking | breathing | rest | coffee | sun",
    "action": "アクション名（20文字以内、例：14時頃に5分の散歩）",
    "summary": "効果の要約（40文字以内）",
    "time": "推奨時間（HH:MM形式）",
    "whyThisAction": "このアクションを推奨する理由（3-4文、サーカディアンリズムの観点から）",
    "benefits": [
      "期待される効果1（15文字以内）",
      "期待される効果2",
      "期待される効果3"
    ],
    "howToDoIt": [
      "実践ステップ1（20文字以内）",
      "実践ステップ2",
      "実践ステップ3"
    ],
    "expectedBenefit": {
      "text": "科学的根拠に基づく期待効果（例：午後の軽い運動は睡眠の質を10-20%改善する傾向があります）",
      "source": "根拠の出典（例：サーカディアンリズム研究に基づく）"
    }
  },
  "relatedInsight": {
    "label": "Research Finding",
    "text": "科学的知見に基づく発見（30文字以内）",
    "source": "根拠の出典"
  }
}
</output_format>

<scientific_knowledge>
サーカディアンリズムの原則:
- 脳の視交叉上核（SCN）が体内時計の司令塔
- 朝の光（特に青色光）がSCNをリセットし、14〜16時間後のメラトニン分泌をセット
- 就寝・起床時刻の一貫性がリズム安定の鍵
- Afternoon Dip（起床後7-8時間）はサーカディアンリズムの自然な低点
- 軽い運動はAfternoon Dipを和らげ、夜のメラトニンタイミングを改善
- 就寝2時間前からの光・刺激を避けることでメラトニン分泌を促進

自律神経の原則:
- HRV（心拍変動）は自律神経バランスの客観的指標
- HRVが高い = 副交感神経優位 = リラックス・回復状態
- HRVが低い = 交感神経優位 = 緊張・ストレス状態
- 睡眠中のHRVが回復の質を反映

睡眠の科学:
- 深い睡眠は全体の15-25%が理想、身体の修復に重要
- REM睡眠は全体の20-25%が理想、記憶の定着に重要
- 一貫した就寝時刻は睡眠の質を20-30%改善
- 就寝前の軽い運動（4時間以上前）は深い睡眠を促進

環境要因:
- 気圧の急低下は頭痛・倦怠感のリスク要因
- 朝の自然光は覚醒を促進し、夜のメラトニンタイミングを改善
</scientific_knowledge>

<personalization_rules>
ユーザーの目標に応じてアドバイスの優先度を調整:

- better_sleep → 睡眠改善に関連するアドバイスを優先
- more_energy → 日中の活動、Peak Focus活用、Afternoon Dip対策を優先
- less_stress → 呼吸法、リラックス、HRV改善を優先
- peak_performance → 最適タイミング、集中力向上を優先

スコアに応じた調整:
- Recovery 80%以上 → チャレンジを推奨
- Recovery 60%未満 → 休息を優先
- Sleep 70%未満 → 就寝時刻の改善を提案
- Rhythm 70%未満 → 一貫性の重要性を強調
</personalization_rules>

<constraints>
- 医学的診断や処方は行わない
- 絵文字は使用しない
- 数値の再計算はしない（提供されたスコアをそのまま使用）
- 不確実な推測は「〜かもしれません」と表現
- v1では「あなたのデータでは」という個人相関は使用しない
- 代わりに「研究によると」「一般的に」という科学的根拠を使用
</constraints>`;
  },

  /**
   * User Data XMLを構築
   * @param request - AdviceRequest
   * @returns XML形式のユーザーデータ
   */
  buildUserDataXml: (request: AdviceRequest): string => {
    const { user, scores, healthMetrics, weather, rhythmPhases } = request;
    const now = new Date();
    const dayOfWeek = getDayOfWeekJapanese(now.getDay());
    const dateStr = formatDate(now);
    const currentTime = formatTime(now.toISOString());

    return `<user_data>
  <profile>
    <goals>${user.goals.join(', ')}</goals>
    <wake_up_time>${user.wakeUpTime}</wake_up_time>
    <wind_down_time>${user.windDownTime}</wind_down_time>
  </profile>

  <!-- 4つのスコア（アプリ側で計算済み） -->
  <scores date="${dateStr}">
    <recovery value="${scores.recovery}" />
    <sleep value="${scores.sleep}" />
    <rhythm value="${scores.rhythm}" />
    <energy value="${scores.energy}" />
  </scores>

  <!-- Health指標 -->
  <health>
    ${buildHrvXml(healthMetrics.hrv)}
    ${buildRhrXml(healthMetrics.rhr)}
    ${buildSleepXml(healthMetrics.sleep)}
  </health>

  <!-- 環境データ -->
  <environment>
    ${weather.location ? `<location>${escapeXml(weather.location)}</location>` : ''}
    ${weather.description ? `<weather>${escapeXml(weather.description)}</weather>` : ''}
    <temperature_celsius>${weather.temperature}</temperature_celsius>
    <pressure_hpa>${weather.pressure}</pressure_hpa>
    <pressure_trend>${weather.pressureTrend}</pressure_trend>
    <sunrise>${weather.sunrise}</sunrise>
    <sunset>${weather.sunset}</sunset>
  </environment>

  <!-- リズム情報（アプリ側で計算済み） -->
  <rhythm_phases>
    <peak_focus start="${rhythmPhases.peakFocus.start}" end="${rhythmPhases.peakFocus.end}" />
    <afternoon_dip start="${rhythmPhases.afternoonDip.start}" end="${rhythmPhases.afternoonDip.end}" />
    <second_wind start="${rhythmPhases.secondWind.start}" end="${rhythmPhases.secondWind.end}" />
    <wind_down start="${rhythmPhases.windDown.start}" end="${rhythmPhases.windDown.end}" />
  </rhythm_phases>

  <context>
    <current_time>${currentTime}</current_time>
    <day_of_week>${dayOfWeek}</day_of_week>
  </context>
</user_data>`;
  },
};

// ========================================
// Helper functions
// ========================================

const getDayOfWeekJapanese = (day: number): string => {
  const days = ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'];
  return days[day] ?? '';
};

const buildSleepXml = (sleep: HealthMetrics['sleep']): string => {
  return `<sleep>
      <duration_minutes>${sleep.durationMinutes}</duration_minutes>
      <deep_sleep_minutes>${sleep.deepSleepMinutes}</deep_sleep_minutes>
      <deep_sleep_percent>${sleep.deepSleepPercent}</deep_sleep_percent>
      <rem_sleep_minutes>${sleep.remSleepMinutes}</rem_sleep_minutes>
      <rem_sleep_percent>${sleep.remSleepPercent}</rem_sleep_percent>
      ${sleep.bedtime ? `<bedtime>${sleep.bedtime}</bedtime>` : ''}
      ${sleep.wakeTime ? `<wake_time>${sleep.wakeTime}</wake_time>` : ''}
      ${sleep.vsTargetBedtime ? `<vs_target_bedtime>${sleep.vsTargetBedtime}</vs_target_bedtime>` : ''}
    </sleep>`;
};

const buildHrvXml = (hrv: HealthMetrics['hrv']): string => {
  const deviation =
    hrv.deviation !== undefined
      ? hrv.deviation
      : hrv.baseline > 0
        ? ((hrv.current - hrv.baseline) / hrv.baseline) * 100
        : 0;
  const sign = deviation >= 0 ? '+' : '';

  return `<hrv current_ms="${hrv.current}" baseline_ms="${hrv.baseline}" deviation_percent="${sign}${deviation.toFixed(0)}" />`;
};

const buildRhrXml = (rhr: HealthMetrics['rhr']): string => {
  const deviation = rhr.baseline > 0 ? ((rhr.current - rhr.baseline) / rhr.baseline) * 100 : 0;
  const sign = deviation >= 0 ? '+' : '';

  return `<rhr current_bpm="${rhr.current}" baseline_bpm="${rhr.baseline}" deviation_percent="${sign}${deviation.toFixed(0)}" />`;
};
