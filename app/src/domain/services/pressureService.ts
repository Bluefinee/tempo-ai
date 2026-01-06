/**
 * 気圧トレンド計算サービス
 * 過去の気圧履歴から上昇・下降・安定を判定
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
  } catch {
    return [];
  }
};

/**
 * 気圧履歴を保存
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
 * @returns 気圧トレンド（'up' | 'stable' | 'down'）
 */
export const calculatePressureTrend = async (
  currentPressure: number
): Promise<PressureTrend> => {
  const now = Date.now();
  const history = await getPressureHistory();

  // 履歴に追加
  history.push({ value: currentPressure, timestamp: now });

  // 24時間以内のデータのみ保持
  const retentionMs = HISTORY_RETENTION_HOURS * 60 * 60 * 1000;
  const recentHistory = history.filter((r) => now - r.timestamp < retentionMs);

  // 履歴を保存
  await savePressureHistory(recentHistory);

  // 3時間前のデータを探す
  const comparisonMs = TREND_COMPARISON_HOURS * 60 * 60 * 1000;
  const threeHoursAgo = now - comparisonMs;

  // 3時間前に最も近いデータを取得
  const oldRecords = recentHistory.filter((r) => r.timestamp <= threeHoursAgo);

  if (oldRecords.length === 0) {
    // 比較データがない場合は安定とする
    return 'stable';
  }

  // 最新の比較対象データ
  const oldRecord = oldRecords[oldRecords.length - 1];
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
    console.warn('Failed to clear pressure history:', error);
  }
};

