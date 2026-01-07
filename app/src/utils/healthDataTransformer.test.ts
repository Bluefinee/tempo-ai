/**
 * ヘルスデータ変換ユーティリティのテスト
 */

import {
  toBarChartData,
  toAreaChartData,
  calculateTrendFromSamples,
  getTrendLabel,
  filterByTimeRange,
  timeRangeToDays,
  calculateAverage,
  findMinValue,
  findMaxValue,
  calculateDeviationPercent,
  formatDeviationPercent,
} from "./healthDataTransformer";
import { DailyHealthSample } from "../domain/models/healthHistory";

// テスト用のサンプルデータを生成
const createSamples = (days: number): DailyHealthSample[] => {
  const samples: DailyHealthSample[] = [];
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    samples.push({
      date,
      value: 70 + (i % 10), // 70-79 の範囲で変動
    });
  }
  return samples;
};

describe("healthDataTransformer", () => {
  describe("toBarChartData", () => {
    it("7D の場合、曜日ラベルを返す（日本語）", () => {
      const samples = createSamples(7);
      const result = toBarChartData(samples, "7D", "ja");

      expect(result).toHaveLength(7);
      // 曜日ラベルは日〜土のいずれか
      result.forEach((point) => {
        expect(["日", "月", "火", "水", "木", "金", "土"]).toContain(
          point.label,
        );
      });
    });

    it("7D の場合、曜日ラベルを返す（英語）", () => {
      const samples = createSamples(7);
      const result = toBarChartData(samples, "7D", "en");

      expect(result).toHaveLength(7);
      result.forEach((point) => {
        expect(["S", "M", "T", "W", "T", "F", "S"]).toContain(point.label);
      });
    });

    it("30D の場合、日付番号ラベルを返す", () => {
      const samples = createSamples(30);
      const result = toBarChartData(samples, "30D", "ja");

      expect(result).toHaveLength(30);
      expect(result[0].label).toBe("1");
      expect(result[29].label).toBe("30");
    });

    it("60D の場合、日付番号ラベルを返す", () => {
      const samples = createSamples(60);
      const result = toBarChartData(samples, "60D", "ja");

      expect(result).toHaveLength(60);
      expect(result[0].label).toBe("1");
      expect(result[59].label).toBe("60");
    });

    it("値は整数に丸められる", () => {
      const samples: DailyHealthSample[] = [
        { date: new Date(), value: 70.6 },
        { date: new Date(), value: 70.4 },
      ];
      const result = toBarChartData(samples, "30D", "ja");

      expect(result[0].value).toBe(71);
      expect(result[1].value).toBe(70);
    });
  });

  describe("toAreaChartData", () => {
    it("7D の場合、英語曜日ラベルを返す", () => {
      const samples = createSamples(7);
      const result = toAreaChartData(samples, "7D");

      expect(result).toHaveLength(7);
      result.forEach((point) => {
        expect(["S", "M", "T", "W", "T", "F", "S"]).toContain(point.day);
      });
    });

    it("30D の場合、週ラベルを返す", () => {
      const samples = createSamples(30);
      const result = toAreaChartData(samples, "30D");

      // 30日 / 7日 = 約4-5週
      expect(result.length).toBeGreaterThanOrEqual(4);
      expect(result[result.length - 1].day).toBe("Now");
    });

    it("60D の場合、2週間ラベルを返す", () => {
      const samples = createSamples(60);
      const result = toAreaChartData(samples, "60D");

      // 60日 / 14日 = 約4-5期間
      expect(result.length).toBeGreaterThanOrEqual(4);
      expect(result[result.length - 1].day).toBe("Now");
    });
  });

  describe("calculateTrendFromSamples", () => {
    it("7日未満のデータの場合は stable を返す", () => {
      const samples = createSamples(5);
      expect(calculateTrendFromSamples(samples)).toBe("stable");
    });

    it("直近が前週より 5% 以上高い場合は improving を返す", () => {
      const samples: DailyHealthSample[] = [
        // 前週（低い値）
        ...Array.from({ length: 7 }, (_, i) => ({
          date: new Date(Date.now() - (13 - i) * 24 * 60 * 60 * 1000),
          value: 50,
        })),
        // 今週（高い値）
        ...Array.from({ length: 7 }, (_, i) => ({
          date: new Date(Date.now() - (6 - i) * 24 * 60 * 60 * 1000),
          value: 60,
        })),
      ];
      expect(calculateTrendFromSamples(samples)).toBe("improving");
    });

    it("直近が前週より 5% 以上低い場合は declining を返す", () => {
      const samples: DailyHealthSample[] = [
        // 前週（高い値）
        ...Array.from({ length: 7 }, (_, i) => ({
          date: new Date(Date.now() - (13 - i) * 24 * 60 * 60 * 1000),
          value: 60,
        })),
        // 今週（低い値）
        ...Array.from({ length: 7 }, (_, i) => ({
          date: new Date(Date.now() - (6 - i) * 24 * 60 * 60 * 1000),
          value: 50,
        })),
      ];
      expect(calculateTrendFromSamples(samples)).toBe("declining");
    });
  });

  describe("getTrendLabel", () => {
    it("日本語ラベルを返す", () => {
      expect(getTrendLabel("improving", "ja")).toBe("上昇傾向");
      expect(getTrendLabel("stable", "ja")).toBe("安定");
      expect(getTrendLabel("declining", "ja")).toBe("下降傾向");
    });

    it("英語ラベルを返す", () => {
      expect(getTrendLabel("improving", "en")).toBe("Improving");
      expect(getTrendLabel("stable", "en")).toBe("Stable");
      expect(getTrendLabel("declining", "en")).toBe("Declining");
    });
  });

  describe("filterByTimeRange", () => {
    it("7D の場合、直近 7 日分を返す", () => {
      const samples = createSamples(60);
      const result = filterByTimeRange(samples, "7D");
      expect(result).toHaveLength(7);
    });

    it("30D の場合、直近 30 日分を返す", () => {
      const samples = createSamples(60);
      const result = filterByTimeRange(samples, "30D");
      expect(result).toHaveLength(30);
    });

    it("60D の場合、直近 60 日分を返す", () => {
      const samples = createSamples(60);
      const result = filterByTimeRange(samples, "60D");
      expect(result).toHaveLength(60);
    });
  });

  describe("timeRangeToDays", () => {
    it("7D は 7 を返す", () => {
      expect(timeRangeToDays("7D")).toBe(7);
    });

    it("30D は 30 を返す", () => {
      expect(timeRangeToDays("30D")).toBe(30);
    });

    it("60D は 60 を返す", () => {
      expect(timeRangeToDays("60D")).toBe(60);
    });
  });

  describe("calculateAverage", () => {
    it("平均値を計算する", () => {
      const samples: DailyHealthSample[] = [
        { date: new Date(), value: 60 },
        { date: new Date(), value: 70 },
        { date: new Date(), value: 80 },
      ];
      expect(calculateAverage(samples)).toBe(70);
    });

    it("空配列の場合は 0 を返す", () => {
      expect(calculateAverage([])).toBe(0);
    });

    it("小数点1桁に丸める", () => {
      const samples: DailyHealthSample[] = [
        { date: new Date(), value: 10 },
        { date: new Date(), value: 20 },
        { date: new Date(), value: 30 },
      ];
      expect(calculateAverage(samples)).toBe(20);
    });
  });

  describe("findMinValue", () => {
    it("最小値を返す", () => {
      const samples: DailyHealthSample[] = [
        { date: new Date(), value: 80 },
        { date: new Date(), value: 60 },
        { date: new Date(), value: 70 },
      ];
      expect(findMinValue(samples)).toBe(60);
    });

    it("空配列の場合は 0 を返す", () => {
      expect(findMinValue([])).toBe(0);
    });
  });

  describe("findMaxValue", () => {
    it("最大値を返す", () => {
      const samples: DailyHealthSample[] = [
        { date: new Date(), value: 80 },
        { date: new Date(), value: 60 },
        { date: new Date(), value: 70 },
      ];
      expect(findMaxValue(samples)).toBe(80);
    });

    it("空配列の場合は 0 を返す", () => {
      expect(findMaxValue([])).toBe(0);
    });
  });

  describe("calculateDeviationPercent", () => {
    it("乖離率を計算する", () => {
      expect(calculateDeviationPercent(110, 100)).toBe(10);
      expect(calculateDeviationPercent(90, 100)).toBe(-10);
      expect(calculateDeviationPercent(100, 100)).toBe(0);
    });

    it("ベースラインが 0 の場合は 0 を返す", () => {
      expect(calculateDeviationPercent(100, 0)).toBe(0);
    });
  });

  describe("formatDeviationPercent", () => {
    it("正の値は + 付きで返す", () => {
      expect(formatDeviationPercent(5)).toBe("+5%");
    });

    it("負の値はそのまま返す", () => {
      expect(formatDeviationPercent(-5)).toBe("-5%");
    });

    it('0 は "0%" で返す', () => {
      expect(formatDeviationPercent(0)).toBe("0%");
    });
  });
});
