import type { AdviceRequest } from './types';

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

/**
 * 性別を日本語にマッピング
 */
const mapGender = (gender: string): string => {
  const map: Record<string, string> = {
    male: '男性',
    female: '女性',
    other: 'その他',
    preferNotToSay: '回答しない',
  };
  return map[gender] || gender;
};

/**
 * クロノタイプを日本語にマッピング
 */
const mapChronotype = (chronotype: string): string => {
  const map: Record<string, string> = {
    morning: '朝型',
    intermediate: '中間型',
    evening: '夜型',
  };
  return map[chronotype] || chronotype;
};

/**
 * 職業を日本語にマッピング
 */
const mapOccupation = (occupation: string): string => {
  const map: Record<string, string> = {
    deskWork: 'デスクワーク',
    standingWork: '立ち仕事',
    physicalWork: '肉体労働',
    hybrid: 'ハイブリッド',
    other: 'その他',
  };
  return map[occupation] || occupation;
};

/**
 * 運動頻度を日本語にマッピング
 */
const mapExerciseFrequency = (frequency: string): string => {
  const map: Record<string, string> = {
    rarely: 'ほとんどしない',
    onceWeek: '週1回',
    twiceWeek: '週2回',
    threeOrMore: '週3回以上',
    daily: '毎日',
  };
  return map[frequency] || frequency;
};

/**
 * リズムステータスを日本語にマッピング
 */
const mapRhythmStatus = (status: string): string => {
  const map: Record<string, string> = {
    stable: '安定',
    recovering: '回復中',
    unstable: '乱れ気味',
  };
  return map[status] || status;
};

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
今日1日を最適に過ごすためのパーソナライズされた提案を行います。
</role>

<character>
- 温かみがありながらも、専門家としての信頼感がある
- ニックネームで「〇〇さん」と呼びかける
- 押し付けず、提案する（「〜してみてください」「〜するといいかもしれません」）
- 科学的根拠を示しながらも、難しい言葉は使わない
- ポジティブな面を先に伝え、改善点は建設的に提案
</character>

<scientific_knowledge>
サーカディアンリズムの原則:
- 脳の視交叉上核（SCN）が体内時計の司令塔
- 朝の光（特に青色光）がSCNをリセットし、14〜16時間後のメラトニン分泌をセット
- 就寝・起床時刻の一貫性がリズム安定の鍵
- 末梢時計（肝臓、腸など）は食事時間でリセットされる

自律神経の原則:
- HRV（心拍変動）は自律神経バランスの客観的指標
- HRVが高い = 副交感神経優位 = リラックス・回復状態
- HRVが低い = 交感神経優位 = 緊張・ストレス状態
- 日中は交感神経、夜は副交感神経へのスムーズな切り替えが健康の鍵

データの解釈:
- 手首体温の夜間低下パターンでリズムの正常性を確認
- 日光暴露時間が短いとメラトニン分泌が遅れ、入眠が遅くなる
- 気圧の急低下は頭痛・倦怠感のリスク要因
- 深い睡眠は全体の15-25%が理想
</scientific_knowledge>

<output_format>
以下のJSON形式で出力してください。

{
  "summary": "ホーム画面に表示する要約（3-4文、100-150文字）",
  "full_insight": "詳細画面に表示するフルバージョン（後述の構成に従う）",
  "recommended_action": {
    "type": "breathing | morning_light | rest | activity",
    "message": "Quick Actionに表示するメッセージ（20文字以内）"
  }
}
</output_format>

<full_insight_structure>
full_insightは以下の構成で、合計400-600文字程度で記述してください。

1. 挨拶（1文）
   - ニックネーム + 時間帯に応じた挨拶

2. 今日のコンディション総評（2-3文）
   - スコアに基づく全体的な状態
   - ポジティブな面を先に

3. 睡眠分析（3-4文）
   - 昨夜の睡眠の質と量
   - 深い睡眠、レム睡眠の状態
   - 目標就寝時刻との比較
   - 【因果関係】睡眠がHRVやコンディションにどう影響したか

4. リズム分析（2-3文）
   - 就寝・起床時刻の規則性
   - 連続安定日数がある場合はその効果
   - 日光暴露時間、手首体温のデータがあれば活用
   - 【因果関係】リズムの状態が回復にどう影響しているか

5. 環境影響予測（2-3文）
   - 今日の気象条件（気圧、天気、気温）
   - 体調への影響予測
   - 【因果関係】環境がコンディションにどう影響しそうか

6. 今日の過ごし方提案（3-4文）
   - 午前・午後・夜それぞれの具体的な提案
   - ユーザーの職業やクロノタイプを考慮
   - 1つは具体的な行動（時間や場所を含む）

7. クロージング（1文）
   - 温かいエールや励まし
</full_insight_structure>

<personalization_rules>
ユーザーの属性に応じてアドバイスをパーソナライズしてください。

職業別:
- デスクワーク → 座りすぎ対策、目の疲れ、こまめな休憩を提案
- 立ち仕事 → 足の疲労、むくみ対策を提案
- 肉体労働 → 十分な休息と回復の重要性を強調

クロノタイプ別:
- 朝型 → 午前中のゴールデンタイムを活用する提案
- 夜型 → 無理に早起きせず、リズムを徐々に調整する提案
- 中間型 → バランスの取れた提案

運動頻度別:
- 運動習慣あり → 今日のコンディションに適した運動強度を提案
- 運動習慣なし → 軽い散歩など取り入れやすい活動を提案

今日のモード別:
- normal（通常）→ 標準的なアドバイス
- challenge（頑張る日）→ 午前中に集中力を高める提案。「大事な予定があるんですね」と言及し、プレゼン前の深呼吸、カフェインのタイミング（本番2時間前）、昼食は軽めになど具体的に
- holiday（休日）→ 回復重視の提案。「今日はゆっくり過ごせる日ですね」と言及し、無理しない、リラックスアクティビティを提案
</personalization_rules>

<constraints>
- 医学的診断や処方は行わない
- 「病気」「治療」「医師に相談」などの表現は、明らかに深刻な場合のみ
- 絵文字は使用しない
- 「！」は1回の出力で2-3個まで
- データがない項目については言及しない
- 不確実な推測は「〜かもしれません」「〜の可能性があります」と表現
</constraints>`;
  },

  /**
   * User Data XMLを構築
   * @param request - AdviceRequest
   * @returns XML形式のユーザーデータ
   */
  buildUserDataXml: (request: AdviceRequest): string => {
    const { profile, healthData, location, context, weather } = request;

    let xml = '<user_data>\n';

    // Profile section
    xml += '  <profile>\n';
    xml += `    <nickname>${escapeXml(profile.nickname)}</nickname>\n`;
    xml += `    <age>${profile.age}</age>\n`;
    xml += `    <gender>${mapGender(profile.gender)}</gender>\n`;
    xml += `    <chronotype>${mapChronotype(profile.chronotype)}</chronotype>\n`;
    if (profile.occupation) {
      xml += `    <occupation>${mapOccupation(profile.occupation)}</occupation>\n`;
    }
    if (profile.exerciseFrequency) {
      xml += `    <exercise_frequency>${mapExerciseFrequency(profile.exerciseFrequency)}</exercise_frequency>\n`;
    }
    xml += `    <target_bedtime>${profile.targetBedtime}</target_bedtime>\n`;
    xml += '  </profile>\n\n';

    // Health section
    xml += `  <health date="${formatDate(new Date())}" day_of_week="${context.dayOfWeek}">\n`;

    if (healthData.sleep) {
      const s = healthData.sleep;
      xml += '    <sleep>\n';
      xml += `      <bedtime>${formatTime(s.bedtime)}</bedtime>\n`;
      xml += `      <wake_time>${formatTime(s.wakeTime)}</wake_time>\n`;
      xml += `      <duration_hours>${s.durationHours.toFixed(1)}</duration_hours>\n`;
      xml += `      <deep_sleep_minutes>${s.deepSleepMinutes}</deep_sleep_minutes>\n`;
      xml += `      <rem_sleep_minutes>${s.remSleepMinutes}</rem_sleep_minutes>\n`;
      xml += `      <deep_sleep_ratio>${s.deepSleepRatio.toFixed(2)}</deep_sleep_ratio>\n`;
      xml += '    </sleep>\n';
    }

    if (healthData.hrv) {
      const h = healthData.hrv;
      xml += '    <hrv>\n';
      xml += `      <value_ms>${h.value.toFixed(0)}</value_ms>\n`;
      xml += `      <baseline_30d_ms>${h.baseline30d.toFixed(0)}</baseline_30d_ms>\n`;
      xml += `      <deviation_percent>${h.deviationPercent > 0 ? '+' : ''}${h.deviationPercent.toFixed(1)}</deviation_percent>\n`;
      xml += '    </hrv>\n';
    }

    if (healthData.activity) {
      const a = healthData.activity;
      xml += '    <activity>\n';
      xml += `      <steps_yesterday>${a.stepsYesterday}</steps_yesterday>\n`;
      xml += `      <active_minutes_yesterday>${a.activeMinutesYesterday}</active_minutes_yesterday>\n`;
      xml += '    </activity>\n';
    }

    // Rhythm
    const r = healthData.rhythmAnalysis;
    xml += '    <rhythm>\n';
    xml += `      <bedtime_stddev_minutes>${r.bedtimeStddevMinutes.toFixed(0)}</bedtime_stddev_minutes>\n`;
    xml += `      <waketime_stddev_minutes>${r.wakeTimeStddevMinutes.toFixed(0)}</waketime_stddev_minutes>\n`;
    xml += `      <consecutive_stable_days>${r.consecutiveStableDays}</consecutive_stable_days>\n`;
    xml += `      <stability_status>${mapRhythmStatus(r.status)}</stability_status>\n`;
    xml += '    </rhythm>\n';

    // Auxiliary data
    if (healthData.auxiliary) {
      const aux = healthData.auxiliary;
      if (aux.daylightMinutesYesterday !== undefined) {
        xml += '    <daylight>\n';
        xml += `      <minutes_yesterday>${aux.daylightMinutesYesterday}</minutes_yesterday>\n`;
        xml += '    </daylight>\n';
      }
      if (aux.wristTemperatureDeviation !== undefined) {
        xml += '    <wrist_temperature>\n';
        xml += `      <deviation_celsius>${aux.wristTemperatureDeviation > 0 ? '+' : ''}${aux.wristTemperatureDeviation.toFixed(1)}</deviation_celsius>\n`;
        xml += '    </wrist_temperature>\n';
      }
    }

    // Scores
    const scores = healthData.scores;
    xml += '    <scores>\n';
    xml += `      <autonomic>${scores.autonomic}</autonomic>\n`;
    xml += `      <sleep>${scores.sleep}</sleep>\n`;
    xml += `      <rhythm>${scores.rhythm}</rhythm>\n`;
    xml += `      <activity>${scores.activity}</activity>\n`;
    xml += '    </scores>\n';

    xml += '  </health>\n\n';

    // Environment (weather)
    if (weather) {
      xml += '  <environment>\n';
      xml += `    <location>${escapeXml(location.city)}</location>\n`;
      xml += `    <temperature_celsius>${weather.temperature.toFixed(0)}</temperature_celsius>\n`;
      xml += `    <humidity_percent>${weather.humidity.toFixed(0)}</humidity_percent>\n`;
      xml += `    <pressure_hpa>${weather.pressure.toFixed(0)}</pressure_hpa>\n`;
      xml += `    <uv_index>${weather.uvIndexMax.toFixed(0)}</uv_index>\n`;
      xml += '  </environment>\n\n';
    }

    // Context
    xml += '  <context>\n';
    xml += `    <current_time>${formatTime(context.currentTime)}</current_time>\n`;
    if (context.mood !== undefined) {
      xml += `    <mood>${context.mood}</mood>\n`;
    }
    xml += `    <today_mode>${context.todayMode}</today_mode>\n`;
    xml += '  </context>\n';

    xml += '</user_data>';

    return xml;
  },
};
