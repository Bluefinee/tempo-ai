/**
 * 気圧トレンド計算サービス
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import type { PressureTrend } from '../models/weather';

const PRESSURE_HISTORY_KEY = 'tempo_pressure_history';
const HISTORY_RETENTION_HOURS = 24;
const TREND_COMPARISON_HOURS = 3;
const TREND_THRESHOLD_HPA = 2;

interface PressureRecord {
  value: number;
  timestamp: number;
}

/**
 * 気圧履歴を取得
 */
const getPressureHistory = async (): Promise<PressureRecord[]> => {
  try {
    const data = await AsyncStorage.getItem(PRESSURE_HISTORY_KEY);
    return data ? JSON.parse(data) : [];
  } catch (error) {
    console.warn('Failed to retrieve pressure history:', error);
    return [];
  }
};

/**
 * 気圧履歴を保存
 * @param history 保存する気圧記録の配列
 */
const savePressureHistory = async (history: PressureRecord[]): Promise<void> => {
  try {
    await AsyncStorage.setItem(PRESSURE_HISTORY_KEY, JSON.stringify(history));
  } catch (error) {
    console.warn('Failed to save pressure history:', error);
  }
};

/**
 * 気圧トレンドを計算
 * @param currentPressure 現在の気圧（hPa）
 * @returns 気圧トレンド
 */
export const calculatePressureTrend = async (
  currentPressure: number
): Promise<PressureTrend> => {
  const now = Date.now();
  const history = await getPressureHistory();

  history.push({ value: currentPressure, timestamp: now });

  const retentionMs = HISTORY_RETENTION_HOURS * 60 * 60 * 1000;
  const recentHistory = history.filter((r) => now - r.timestamp < retentionMs);

  await savePressureHistory(recentHistory);

  const comparisonMs = TREND_COMPARISON_HOURS * 60 * 60 * 1000;
  const threeHoursAgo = now - comparisonMs;

  // 時系列順にソートしてから3時間前のデータを取得
  const oldRecords = recentHistory
    .filter((r) => r.timestamp <= threeHoursAgo)
    .sort((a, b) => b.timestamp - a.timestamp);

  if (oldRecords.length === 0) {
    return 'stable';
  }

  const oldRecord = oldRecords[0];
  const diff = currentPressure - oldRecord.value;

  if (diff > TREND_THRESHOLD_HPA) {
    return 'up';
  }
  if (diff < -TREND_THRESHOLD_HPA) {
    return 'down';
  }
  return 'stable';
};

/**
 * 気圧履歴をクリア（テスト用）
 */
export const clearPressureHistory = async (): Promise<void> => {
  try {
    await AsyncStorage.removeItem(PRESSURE_HISTORY_KEY);
  } catch (error) {
    console.error('Failed to clear pressure history:', error);
  }
};

