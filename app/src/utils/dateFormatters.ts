/**
 * Date Formatters - 日付フォーマット関数
 */

/**
 * 時間帯に応じた挨拶を取得（「さん」付き）
 * @param name ユーザー名（省略時は挨拶のみ）
 * @returns "こんにちは太郎さん" 形式
 */
export const getGreeting = (name?: string): string => {
  const hour = new Date().getHours();
  let greeting: string;
  if (hour >= 5 && hour < 12) {
    greeting = "おはようございます";
  } else if (hour >= 12 && hour < 17) {
    greeting = "こんにちは";
  } else if (hour >= 17 && hour < 21) {
    greeting = "こんばんは";
  } else {
    greeting = "お疲れさまです";
  }
  return name ? `${greeting}${name}さん` : greeting;
};

/**
 * 現在時刻を "HH:MM" 形式でフォーマット
 * @param date 日時（省略時は現在日時）
 * @returns "10:42" 形式
 */
export const formatTime = (date: Date = new Date()): string => {
  const hours = date.getHours();
  const minutes = date.getMinutes().toString().padStart(2, "0");
  return `${hours}:${minutes}`;
};

/**
 * 現在時刻を "現在 HH:MM" 形式でフォーマット
 * @param date 日時（省略時は現在日時）
 * @returns "現在 10:42" 形式
 */
export const formatCurrentTime = (date: Date = new Date()): string => {
  return `現在 ${formatTime(date)}`;
};

/**
 * 日付を日本語形式でフォーマット
 * @param date 日付（省略時は現在日時）
 * @returns "1月7日（火）" 形式
 */
export const formatDate = (date: Date = new Date()): string => {
  const weekdays = ["日", "月", "火", "水", "木", "金", "土"];
  const month = date.getMonth() + 1;
  const day = date.getDate();
  const weekday = weekdays[date.getDay()];
  return `${month}月${day}日（${weekday}）`;
};

/**
 * 日付を英語形式でフォーマット（詩的タイトル用）
 * @param date 日付（省略時は現在日時）
 * @returns "Tuesday, January 7" 形式
 */
export const formatDateEnglish = (date: Date = new Date()): string => {
  const days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  return `${days[date.getDay()]}, ${months[date.getMonth()]} ${date.getDate()}`;
};

