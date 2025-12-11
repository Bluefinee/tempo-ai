import type {
  GenerateAdviceParams,
  AdditionalAdviceParams,
  ClaudePromptLayer,
} from '../types/claude.js';
import type {
  Interest,
  Gender,
  Occupation,
  LifestyleRhythm,
  ExerciseFrequency,
} from '../types/domain.js';
import { fitnessExamples } from '../prompts/examples/fitness.js';
import { beautyExamples } from '../prompts/examples/beauty.js';
import { mentalExamples } from '../prompts/examples/mental.js';
import { workExamples } from '../prompts/examples/work.js';
import { nutritionExamples } from '../prompts/examples/nutrition.js';
import { sleepExamples } from '../prompts/examples/sleep.js';

const genderLabels: Record<Gender, string> = {
  male: '男性',
  female: '女性',
  other: 'その他',
  not_specified: '未設定',
};

const formatGender = (gender: Gender): string => {
  return genderLabels[gender] ?? '未設定';
};

const occupationLabels: Record<Occupation, string> = {
  it_engineer: 'ITエンジニア',
  sales: '営業',
  standing_work: '立ち仕事',
  medical: '医療従事者',
  creative: 'クリエイティブ',
  freelance: 'フリーランス',
  student: '学生',
  homemaker: '主婦/主夫',
  other: 'その他',
};

const formatOccupation = (occupation: Occupation): string => {
  return occupationLabels[occupation] ?? '未設定';
};

const lifestyleLabels: Record<LifestyleRhythm, string> = {
  morning: '朝型',
  night: '夜型',
  irregular: '不規則',
};

const formatLifestyle = (lifestyle: LifestyleRhythm): string => {
  return lifestyleLabels[lifestyle] ?? '未設定';
};

const exerciseLabels: Record<ExerciseFrequency, string> = {
  rarely: '運動習慣なし',
  one_to_two: '週1-2回',
  three_to_four: '週3-4回',
  daily: 'ほぼ毎日',
};

const formatExercise = (exercise: ExerciseFrequency): string => {
  return exerciseLabels[exercise] ?? '未設定';
};

const interestExamplesMap: Record<Interest, string> = {
  fitness: fitnessExamples,
  beauty: beautyExamples,
  mental_health: mentalExamples,
  work_performance: workExamples,
  nutrition: nutritionExamples,
  sleep: sleepExamples,
};

export const getExamplesForInterest = (primaryInterest?: Interest): ClaudePromptLayer => {
  const examples = primaryInterest
    ? (interestExamplesMap[primaryInterest] ?? fitnessExamples)
    : fitnessExamples;

  return {
    type: 'text',
    text: examples,
    cache_control: { type: 'ephemeral' },
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
    職業: ${userProfile.occupation ? formatOccupation(userProfile.occupation) : '未設定'}
    生活リズム: ${userProfile.lifestyleRhythm ? formatLifestyle(userProfile.lifestyleRhythm) : '未設定'}
    運動習慣: ${userProfile.exerciseFrequency ? formatExercise(userProfile.exerciseFrequency) : '未設定'}
    関心ごと: ${userProfile.interests.join(', ')}
  </profile>

  <health_data>
    日付: ${healthData.date}
    
    睡眠データ:
    - 就寝: ${healthData.sleep?.bedtime ?? '不明'}
    - 起床: ${healthData.sleep?.wakeTime ?? '不明'}
    - 睡眠時間: ${healthData.sleep?.durationHours ?? '不明'}時間
    - 深い睡眠: ${healthData.sleep?.deepSleepHours ?? '不明'}時間
    - 中途覚醒: ${healthData.sleep?.awakenings ?? '不明'}回
    
    朝のバイタル:
    - 安静時心拍数: ${healthData.morningVitals?.restingHeartRate ?? '不明'}bpm
    - HRV: ${healthData.morningVitals?.hrvMs ?? '不明'}ms
    
    昨日の活動:
    - 歩数: ${healthData.yesterdayActivity?.steps ?? '不明'}歩
    - 運動: ${healthData.yesterdayActivity?.workoutType ?? 'なし'}
    
    週間トレンド:
    - 平均睡眠時間: ${healthData.weekTrends?.avgSleepHours ?? '不明'}時間
    - 平均HRV: ${healthData.weekTrends?.avgHrv ?? '不明'}ms
    - 平均歩数: ${healthData.weekTrends?.avgSteps ?? '不明'}歩
  </health_data>

  <environment>
    ${
      weatherData
        ? `
    天気: ${weatherData.condition}
    気温: ${weatherData.tempCurrentC}℃（最高${weatherData.tempMaxC}℃/最低${weatherData.tempMinC}℃）
    湿度: ${weatherData.humidityPercent}%
    気圧: ${weatherData.pressureHpa}hPa
    UV指数: ${weatherData.uvIndex}
    降水確率: ${weatherData.precipitationProbability}%
    `
        : '気象データ: 取得できませんでした'
    }
    
    ${
      airQualityData
        ? `
    AQI: ${airQualityData.aqi}
    PM2.5: ${airQualityData.pm25}μg/m³
    `
        : '大気汚染データ: 取得できませんでした'
    }
  </environment>

  <context>
    現在時刻: ${context.currentTime}
    曜日: ${context.dayOfWeek}
    月曜日: ${context.isMonday ? 'はい' : 'いいえ'}
    過去2週間の今日のトライ: ${context.recentDailyTries.join(', ') || 'なし'}
    先週の今週のトライ: ${context.lastWeeklyTry || 'なし'}
  </context>
</user_data>

上記のデータに基づいて、今日のアドバイスをJSON形式で生成してください。`;
};

export const buildAdditionalAdviceUserPrompt = (params: AdditionalAdviceParams): string => {
  const { mainAdvice, timeSlot, userProfile } = params;

  const timeSlotText = timeSlot === 'midday' ? '昼間' : '夕方';
  const greeting = timeSlot === 'midday' ? 'お疲れ様です' : 'お疲れ様でした';

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
