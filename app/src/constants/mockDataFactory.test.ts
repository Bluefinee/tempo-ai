/**
 * モックデータファクトリのテスト
 */

import {
	calculateBaseline,
	calculateTrend,
	calculateTypicalRange,
	formatDateString,
	generateDailySamples,
	generateDateRange,
	getMockMetricHistory,
	seededRandom,
} from "./mockDataFactory";

describe("mockDataFactory", () => {
	describe("generateDateRange", () => {
		it("指定した日数分の Date 配列を返す", () => {
			const dates = generateDateRange(7);
			expect(dates).toHaveLength(7);
		});

		it("古い日付から新しい日付の順に並ぶ", () => {
			const dates = generateDateRange(7);
			for (let i = 1; i < dates.length; i++) {
				expect(dates[i].getTime()).toBeGreaterThan(dates[i - 1].getTime());
			}
		});

		it("最後の日付は今日である", () => {
			const dates = generateDateRange(7);
			const today = new Date();
			today.setHours(0, 0, 0, 0);
			expect(dates[dates.length - 1].getTime()).toBe(today.getTime());
		});
	});

	describe("formatDateString", () => {
		it("YYYY-MM-DD 形式の文字列を返す", () => {
			const date = new Date(2026, 0, 7); // 2026-01-07
			expect(formatDateString(date)).toBe("2026-01-07");
		});

		it("月と日が1桁の場合はゼロパディングする", () => {
			const date = new Date(2026, 0, 1); // 2026-01-01
			expect(formatDateString(date)).toBe("2026-01-01");
		});
	});

	describe("seededRandom", () => {
		it("同じシードで同じ結果を返す", () => {
			const result1 = seededRandom(42);
			const result2 = seededRandom(42);
			expect(result1).toBe(result2);
		});

		it("0-1 の間の数値を返す", () => {
			for (let seed = 0; seed < 100; seed++) {
				const result = seededRandom(seed);
				expect(result).toBeGreaterThanOrEqual(0);
				expect(result).toBeLessThan(1);
			}
		});

		it("異なるシードで異なる結果を返す", () => {
			const result1 = seededRandom(42);
			const result2 = seededRandom(43);
			expect(result1).not.toBe(result2);
		});
	});

	describe("generateDailySamples", () => {
		it("指定した日数分のサンプルを返す", () => {
			const samples = generateDailySamples(70, 10, 7, 42);
			expect(samples).toHaveLength(7);
		});

		it("各サンプルは Date と value を持つ", () => {
			const samples = generateDailySamples(70, 10, 7, 42);
			samples.forEach((sample) => {
				expect(sample.date).toBeInstanceOf(Date);
				expect(typeof sample.value).toBe("number");
			});
		});

		it("同じパラメータで同じ結果を返す（再現性）", () => {
			const samples1 = generateDailySamples(70, 10, 7, 42);
			const samples2 = generateDailySamples(70, 10, 7, 42);

			samples1.forEach((sample, index) => {
				expect(sample.value).toBe(samples2[index].value);
			});
		});

		it("値は基準値 ± 分散の範囲内", () => {
			const baseValue = 70;
			const variance = 10;
			const samples = generateDailySamples(baseValue, variance, 100, 42);

			samples.forEach((sample) => {
				expect(sample.value).toBeGreaterThanOrEqual(baseValue - variance);
				expect(sample.value).toBeLessThanOrEqual(baseValue + variance);
			});
		});

		it("負の値にならない", () => {
			const samples = generateDailySamples(5, 10, 100, 42);
			samples.forEach((sample) => {
				expect(sample.value).toBeGreaterThanOrEqual(0);
			});
		});
	});

	describe("calculateBaseline", () => {
		it("直近 N 日の平均を返す", () => {
			const samples = [
				{ date: new Date(), value: 60 },
				{ date: new Date(), value: 70 },
				{ date: new Date(), value: 80 },
			];
			expect(calculateBaseline(samples, 3)).toBe(70);
		});

		it("サンプル数が N より少ない場合は全データの平均を返す", () => {
			const samples = [
				{ date: new Date(), value: 60 },
				{ date: new Date(), value: 80 },
			];
			expect(calculateBaseline(samples, 30)).toBe(70);
		});

		it("空配列の場合は 0 を返す", () => {
			expect(calculateBaseline([], 30)).toBe(0);
		});
	});

	describe("calculateTypicalRange", () => {
		it("14日以上のデータがある場合は personal ソースを返す", () => {
			const samples = Array.from({ length: 20 }, (_, i) => ({
				date: new Date(),
				value: 50 + i * 2, // 50, 52, 54, ..., 88
			}));
			const result = calculateTypicalRange(samples, { min: 0, max: 100 });
			expect(result.source).toBe("personal");
		});

		it("14日未満のデータの場合は default ソースを返す", () => {
			const samples = Array.from({ length: 10 }, () => ({
				date: new Date(),
				value: 70,
			}));
			const result = calculateTypicalRange(samples, { min: 20, max: 100 });
			expect(result.source).toBe("default");
			expect(result.min).toBe(20);
			expect(result.max).toBe(100);
		});
	});

	describe("calculateTrend", () => {
		it("7日未満のデータの場合は stable を返す", () => {
			const samples = Array.from({ length: 5 }, () => ({
				date: new Date(),
				value: 70,
			}));
			expect(calculateTrend(samples)).toBe("stable");
		});

		it("直近が前週より 5% 以上高い場合は improving を返す", () => {
			const samples = [
				// 前週（低い値）
				...Array.from({ length: 7 }, () => ({ date: new Date(), value: 50 })),
				// 今週（高い値）
				...Array.from({ length: 7 }, () => ({ date: new Date(), value: 60 })),
			];
			expect(calculateTrend(samples)).toBe("improving");
		});

		it("直近が前週より 5% 以上低い場合は declining を返す", () => {
			const samples = [
				// 前週（高い値）
				...Array.from({ length: 7 }, () => ({ date: new Date(), value: 60 })),
				// 今週（低い値）
				...Array.from({ length: 7 }, () => ({ date: new Date(), value: 50 })),
			];
			expect(calculateTrend(samples)).toBe("declining");
		});

		it("変化が 5% 未満の場合は stable を返す", () => {
			const samples = [
				// 前週
				...Array.from({ length: 7 }, () => ({ date: new Date(), value: 70 })),
				// 今週（ほぼ同じ）
				...Array.from({ length: 7 }, () => ({ date: new Date(), value: 72 })),
			];
			expect(calculateTrend(samples)).toBe("stable");
		});
	});

	describe("getMockMetricHistory", () => {
		it("指定したメトリクス種別の履歴を返す", () => {
			const history = getMockMetricHistory("hrv", "30D");
			expect(history.metricType).toBe("hrv");
			expect(history.samples).toHaveLength(30);
		});

		it("7D を指定すると 7 日分のデータを返す", () => {
			const history = getMockMetricHistory("hrv", "7D");
			expect(history.samples).toHaveLength(7);
		});

		it("60D を指定すると 60 日分のデータを返す", () => {
			const history = getMockMetricHistory("hrv", "60D");
			expect(history.samples).toHaveLength(60);
		});

		it("ベースラインが計算される", () => {
			const history = getMockMetricHistory("hrv", "60D");
			expect(typeof history.baseline).toBe("number");
			expect(history.baseline).toBeGreaterThan(0);
		});

		it("典型範囲が計算される", () => {
			const history = getMockMetricHistory("hrv", "60D");
			expect(history.typicalRange.min).toBeLessThan(history.typicalRange.max);
		});

		it("lastUpdated が Date である", () => {
			const history = getMockMetricHistory("hrv", "60D");
			expect(history.lastUpdated).toBeInstanceOf(Date);
		});

		it("不明なメトリクス種別でエラーを投げる", () => {
			// @ts-expect-error - テスト用に不正な値を渡す
			expect(() => getMockMetricHistory("unknown")).toThrow();
		});
	});
});
