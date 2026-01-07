/**
 * ヘルス履歴データの型定義
 *
 * HealthKit Statistics Query (HKStatisticsCollectionQuery) のベストプラクティスに基づき、
 * 日次集計データを扱うための型を定義します。
 *
 * @see https://developer.apple.com/documentation/healthkit/hkstatisticscollectionquery
 */

// =============================================================================
// 基本型定義
// =============================================================================

/**
 * HealthKit Statistics Query に対応した日次サンプル型
 *
 * HealthKit の統計クエリは日ごとの集計値（mean/sum）を返します。
 * 60日分でも数十〜数百レコードのため高速に処理可能。
 */
export interface DailyHealthSample {
  /** 日の開始時刻 (00:00:00) */
  date: Date;
  /** 日次集計値（mean/sum depending on metric） */
  value: number;
  /** 集計元のサンプル数（オプション、デバッグ用） */
  sampleCount?: number;
}

/**
 * 時間範囲
 * グラフ表示で使用する期間の指定
 */
export type HealthTimeRange = "7D" | "30D" | "60D";

/**
 * ヘルスメトリクスの種類
 */
export type HealthMetricType =
  | "hrv"
  | "rhr"
  | "respiratory"
  | "spo2"
  | "wristTemp"
  | "recoveryScore"
  | "sleepScore"
  | "rhythmScore"
  | "energyScore";

// =============================================================================
// 履歴データ型
// =============================================================================

/**
 * メトリクス履歴（ベースライン付き）
 *
 * 将来の HealthKit 統合時にそのまま使用可能な構造。
 * ベースラインと典型範囲を含み、トレンド分析をサポート。
 */
export interface HealthMetricHistory {
  metricType: HealthMetricType;
  samples: DailyHealthSample[];
  /** 60日ローリング平均 */
  baseline: number;
  typicalRange: {
    min: number;
    max: number;
    /** 14日以上のデータがあれば 'personal'、なければ 'default' */
    source: "personal" | "default";
  };
  lastUpdated: Date;
}

/**
 * トレンド方向
 * 直近の変化傾向を表す
 */
export type TrendDirection = "improving" | "stable" | "declining";

// =============================================================================
// 更新タイミング別データ型
// =============================================================================

/**
 * 日次スナップショット（朝1回算出、その日は固定）
 *
 * スコアと AI アドバイスは起床時刻連動で朝1回算出し、
 * 1日を通して一貫した値を表示する。
 */
export interface DailySnapshot {
  /** 算出日 (YYYY-MM-DD 形式) */
  date: string;
  /** 算出時刻 */
  calculatedAt: Date;
  /** 各スコア（0-100） */
  scores: {
    recovery: number;
    sleep: number;
    rhythm: number;
    energy: number;
  };
}

/**
 * リアルタイムヘルスメトリック
 * 個々のメトリクスの現在値と更新情報
 */
export interface RealtimeHealthMetric {
  /** 現在値 */
  value: number;
  /** 単位 */
  unit: string;
  /** ベースライン（60日平均） */
  baseline: number;
  /** ベースラインからの乖離率（%） */
  deviationPercent: number;
  /** 最終更新時刻 */
  lastUpdated: Date;
}

/**
 * リアルタイムメトリクス（アプリ起動ごとに更新）
 *
 * 現在の身体状態をリアルタイムで把握するため、
 * アプリを開くたびに最新データを取得する。
 */
export interface RealtimeMetrics {
  hrv: RealtimeHealthMetric;
  rhr: RealtimeHealthMetric;
  respiratory: RealtimeHealthMetric;
  spo2: RealtimeHealthMetric;
  wristTemp: RealtimeHealthMetric;
}

// =============================================================================
// グラフ表示用型（UI レイヤー）
// =============================================================================

/**
 * BarChart 用データポイント
 * 既存の BarChart コンポーネントとの互換性を維持
 */
export interface BarChartDataPoint {
  label: string;
  value: number;
}

/**
 * AreaChart 用データポイント
 * 既存の HealthAreaChart コンポーネントとの互換性を維持
 */
export interface AreaChartDataPoint {
  day: string;
  value: number;
}

// =============================================================================
// デフォルト値
// =============================================================================

/**
 * メトリクス種別ごとのデフォルト典型範囲
 * 個人データが 14 日未満の場合に使用
 */
export const DEFAULT_TYPICAL_RANGES: Record<
  HealthMetricType,
  { min: number; max: number }
> = {
  hrv: { min: 20, max: 100 },
  rhr: { min: 50, max: 80 },
  respiratory: { min: 10, max: 16 },
  spo2: { min: 95, max: 100 },
  wristTemp: { min: 35.5, max: 37.0 },
  recoveryScore: { min: 0, max: 100 },
  sleepScore: { min: 0, max: 100 },
  rhythmScore: { min: 0, max: 100 },
  energyScore: { min: 0, max: 100 },
};

/**
 * メトリクス種別ごとの単位
 */
export const METRIC_UNITS: Record<HealthMetricType, string> = {
  hrv: "ms",
  rhr: "bpm",
  respiratory: "rpm",
  spo2: "%",
  wristTemp: "°C",
  recoveryScore: "",
  sleepScore: "",
  rhythmScore: "",
  energyScore: "",
};
