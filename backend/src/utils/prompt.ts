import type { GenerateAdviceParams, AdditionalAdviceParams, ClaudePromptLayer } from "../types/claude.js";
import type { Interest, Gender, Occupation, LifestyleRhythm, ExerciseFrequency } from "../types/domain.js";
import { fitnessExamples } from "../prompts/examples/fitness.js";
import { beautyExamples } from "../prompts/examples/beauty.js";
import { mentalExamples } from "../prompts/examples/mental.js";
import { workExamples } from "../prompts/examples/work.js";
import { nutritionExamples } from "../prompts/examples/nutrition.js";
import { sleepExamples } from "../prompts/examples/sleep.js";

const formatGender = (gender: Gender): string => {
  switch (gender) {
    case "male":
      return "男性";
    case "female":
      return "女性";
    case "other":
      return "その他";
    case "not_specified":
      return "未設定";
    default:
      return "未設定";
  }
};

const formatOccupation = (occupation: Occupation): string => {
  switch (occupation) {
    case "it_engineer":
      return "ITエンジニア";
    case "sales":
      return "営業";
    case "standing_work":
      return "立ち仕事";
    case "medical":
      return "医療従事者";
    case "creative":
      return "クリエイティブ";
    case "freelance":
      return "フリーランス";
    case "student":
      return "学生";
    case "homemaker":
      return "主婦/主夫";
    case "other":
      return "その他";
    default:
      return "未設定";
  }
};

const formatLifestyle = (lifestyle: LifestyleRhythm): string => {
  switch (lifestyle) {
    case "morning":
      return "朝型";
    case "night":
      return "夜型";
    case "irregular":
      return "不規則";
    default:
      return "未設定";
  }
};

const formatExercise = (exercise: ExerciseFrequency): string => {
  switch (exercise) {
    case "rarely":
      return "運動習慣なし";
    case "one_to_two":
      return "週1-2回";
    case "three_to_four":
      return "週3-4回";
    case "daily":
      return "ほぼ毎日";
    default:
      return "未設定";
  }
};

export const getExamplesForInterest = (primaryInterest?: Interest): ClaudePromptLayer => {
  let examples: string;

  switch (primaryInterest) {
    case "fitness":
      examples = fitnessExamples;
      break;
    case "beauty":
      examples = beautyExamples;
      break;
    case "mental_health":
      examples = mentalExamples;
      break;
    case "work_performance":
      examples = workExamples;
      break;
    case "nutrition":
      examples = nutritionExamples;
      break;
    case "sleep":
      examples = sleepExamples;
      break;
    default:
      examples = fitnessExamples; // デフォルトはフィットネス
  }

  return {
    type: "text",
    text: examples,
    cache_control: { type: "ephemeral" },
  };
};

export const buildUserDataPrompt = (params: GenerateAdviceParams): string => {
  const { userProfile, healthData, weatherData, airQualityData, context } = params;

  return `
<user_data>
  <profile>
    ニックネーム: ${userProfile.nickname}
    年齢: ${userProfile.age}歳
    性別: ${formatGender(userProfile.gender)}
    体重: ${userProfile.weightKg}kg
    身長: ${userProfile.heightCm}cm
    職業: ${userProfile.occupation ? formatOccupation(userProfile.occupation) : "未設定"}
    生活リズム: ${userProfile.lifestyleRhythm ? formatLifestyle(userProfile.lifestyleRhythm) : "未設定"}
    運動習慣: ${userProfile.exerciseFrequency ? formatExercise(userProfile.exerciseFrequency) : "未設定"}
    関心ごと: ${userProfile.interests.join(", ")}
  </profile>

  <health_data>
    日付: ${healthData.date}
    
    睡眠データ:
    - 就寝: ${healthData.sleep?.bedtime ?? "不明"}
    - 起床: ${healthData.sleep?.wakeTime ?? "不明"}
    - 睡眠時間: ${healthData.sleep?.durationHours ?? "不明"}時間
    - 深い睡眠: ${healthData.sleep?.deepSleepHours ?? "不明"}時間
    - 中途覚醒: ${healthData.sleep?.awakenings ?? "不明"}回
    
    朝のバイタル:
    - 安静時心拍数: ${healthData.morningVitals?.restingHeartRate ?? "不明"}bpm
    - HRV: ${healthData.morningVitals?.hrvMs ?? "不明"}ms
    
    昨日の活動:
    - 歩数: ${healthData.yesterdayActivity?.steps ?? "不明"}歩
    - 運動: ${healthData.yesterdayActivity?.workoutType ?? "なし"}
    
    週間トレンド:
    - 平均睡眠時間: ${healthData.weekTrends?.avgSleepHours ?? "不明"}時間
    - 平均HRV: ${healthData.weekTrends?.avgHrv ?? "不明"}ms
    - 平均歩数: ${healthData.weekTrends?.avgSteps ?? "不明"}歩
  </health_data>

  <environment>
    ${weatherData ? `
    天気: ${weatherData.condition}
    気温: ${weatherData.tempCurrentC}℃（最高${weatherData.tempMaxC}℃/最低${weatherData.tempMinC}℃）
    湿度: ${weatherData.humidityPercent}%
    気圧: ${weatherData.pressureHpa}hPa
    UV指数: ${weatherData.uvIndex}
    降水確率: ${weatherData.precipitationProbability}%
    ` : "気象データ: 取得できませんでした"}
    
    ${airQualityData ? `
    AQI: ${airQualityData.aqi}
    PM2.5: ${airQualityData.pm25}μg/m³
    ` : "大気汚染データ: 取得できませんでした"}
  </environment>

  <context>
    現在時刻: ${context.currentTime}
    曜日: ${context.dayOfWeek}
    月曜日: ${context.isMonday ? "はい" : "いいえ"}
    過去2週間の今日のトライ: ${context.recentDailyTries.join(", ") || "なし"}
    先週の今週のトライ: ${context.lastWeeklyTry || "なし"}
  </context>
</user_data>

上記のデータに基づいて、今日のアドバイスをJSON形式で生成してください。`;
};

export const buildAdditionalAdviceUserPrompt = (params: AdditionalAdviceParams): string => {
  const { mainAdvice, timeSlot, userProfile } = params;

  const timeSlotText = timeSlot === "midday" ? "昼間" : "夕方";
  const greeting = timeSlot === "midday" ? "お疲れ様です" : "お疲れ様でした";

  return `
<context>
  時間帯: ${timeSlotText}
  ユーザー: ${userProfile.nickname}さん
  
  朝のメインアドバイス:
  - 挨拶: ${mainAdvice.greeting}
  - 体調要約: ${mainAdvice.condition.summary}
  - 今日のトライ: ${mainAdvice.dailyTry.title}
</context>

${userProfile.nickname}さんに向けて、${timeSlotText}の追加アドバイスをJSON形式で生成してください。
朝のアドバイスを踏まえ、この時間帯に適したアドバイスをお願いします。

挨拶は「${userProfile.nickname}さん、${greeting}」で始めてください。`;
};