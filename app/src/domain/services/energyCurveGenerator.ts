export interface EnergyCurvePoint {
  time: string; // "HH:MM"
  energy: number; // 0-100
}

/**
 * サーカディアンリズムに基づくエネルギーカーブ生成
 */
export const generateEnergyCurve = (
  wakeUpTime: Date,
  bedtime: Date,
  recoveryScore: number // その日のRecoveryスコアで全体調整
): EnergyCurvePoint[] => {
  const baseEnergy = recoveryScore * 0.8;
  const points: EnergyCurvePoint[] = [];

  // 24時間を30分刻みで計算
  for (let hour = 0; hour < 24; hour += 0.5) {
    const time = new Date(wakeUpTime);
    time.setHours(Math.floor(hour), (hour % 1) * 60, 0, 0);

    const hoursSinceWake =
      (time.getTime() - wakeUpTime.getTime()) / (1000 * 60 * 60);

    let energy: number;

    if (hoursSinceWake < 0) {
      // 就寝中（深夜）
      energy = 20 + Math.random() * 5;
    } else if (hoursSinceWake < 2) {
      // Wake Window: 緩やかに上昇
      energy = 40 + hoursSinceWake * 10;
    } else if (hoursSinceWake < 5) {
      // Peak Focus: 最高値（サイン波）
      const t = (hoursSinceWake - 2) / 3;
      energy = 80 + Math.sin(t * Math.PI) * 15;
    } else if (hoursSinceWake < 7) {
      // Midday: 緩やかに低下
      energy = 75 - (hoursSinceWake - 5) * 5;
    } else if (hoursSinceWake < 9) {
      // Afternoon Dip: 最低値
      const t = (hoursSinceWake - 7) / 2;
      energy = 50 - Math.sin(t * Math.PI) * 5;
    } else if (hoursSinceWake < 13) {
      // Second Wind: 回復
      energy = 50 + (hoursSinceWake - 9) * 5;
    } else {
      // Wind Down: 就寝に向けて低下
      const hoursToBedtime =
        (bedtime.getTime() - time.getTime()) / (1000 * 60 * 60);
      energy = Math.max(30, 70 - Math.max(0, 13 - hoursSinceWake) * 3);
    }

    // Recoveryスコアで全体調整
    energy = energy * (baseEnergy / 70);

    points.push({
      time: formatTime(time),
      energy: clamp(energy, 0, 100),
    });
  }

  return points;
};

const formatTime = (date: Date): string => {
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  return `${hours}:${minutes}`;
};

const clamp = (value: number, min: number, max: number): number => {
  return Math.min(Math.max(value, min), max);
};

