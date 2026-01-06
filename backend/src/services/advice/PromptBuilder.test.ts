import { describe, expect, it } from 'vitest';
import { PromptBuilder } from './PromptBuilder';
import type { AdviceRequest } from './types';

describe('PromptBuilder', () => {
  describe('buildSystemPrompt', () => {
    it('should return a non-empty system prompt', () => {
      const prompt = PromptBuilder.buildSystemPrompt();
      expect(prompt.length).toBeGreaterThan(0);
    });

    it('should contain role section', () => {
      const prompt = PromptBuilder.buildSystemPrompt();
      expect(prompt).toContain('<role>');
      expect(prompt).toContain('</role>');
      expect(prompt).toContain('Tempo');
    });

    it('should contain character section', () => {
      const prompt = PromptBuilder.buildSystemPrompt();
      expect(prompt).toContain('<character>');
      expect(prompt).toContain('</character>');
    });

    it('should contain scientific_knowledge section', () => {
      const prompt = PromptBuilder.buildSystemPrompt();
      expect(prompt).toContain('<scientific_knowledge>');
      expect(prompt).toContain('</scientific_knowledge>');
      expect(prompt).toContain('サーカディアンリズム');
      expect(prompt).toContain('HRV');
    });

    it('should contain output_format section with JSON structure', () => {
      const prompt = PromptBuilder.buildSystemPrompt();
      expect(prompt).toContain('<output_format>');
      expect(prompt).toContain('</output_format>');
      expect(prompt).toContain('"summary"');
      expect(prompt).toContain('"insight"');
      expect(prompt).toContain('"greeting"');
      expect(prompt).toContain('"condition"');
      expect(prompt).toContain('"sleep"');
      expect(prompt).toContain('"rhythm"');
      expect(prompt).toContain('"environment"');
      expect(prompt).toContain('"advice"');
      expect(prompt).toContain('"closing"');
      expect(prompt).toContain('"recommended_action"');
    });

    it('should contain personalization_rules section', () => {
      const prompt = PromptBuilder.buildSystemPrompt();
      expect(prompt).toContain('<personalization_rules>');
      expect(prompt).toContain('</personalization_rules>');
      expect(prompt).toContain('職業別');
      expect(prompt).toContain('クロノタイプ別');
      expect(prompt).toContain('今日のモード別');
    });

    it('should contain constraints section', () => {
      const prompt = PromptBuilder.buildSystemPrompt();
      expect(prompt).toContain('<constraints>');
      expect(prompt).toContain('</constraints>');
      expect(prompt).toContain('医学的診断');
    });

    it('should be stable (consistent output)', () => {
      const prompt1 = PromptBuilder.buildSystemPrompt();
      const prompt2 = PromptBuilder.buildSystemPrompt();
      expect(prompt1).toBe(prompt2);
    });
  });

  describe('buildUserDataXml', () => {
    const createMinimalRequest = (): AdviceRequest => ({
      profile: {
        nickname: 'マサ',
        age: 28,
        gender: 'male',
        chronotype: 'morning',
        targetBedtime: '23:00',
      },
      healthData: {
        scores: {
          autonomic: 85,
          sleep: 78,
          rhythm: 88,
          activity: 68,
        },
        rhythmAnalysis: {
          bedtimeStddevMinutes: 22,
          wakeTimeStddevMinutes: 18,
          consecutiveStableDays: 5,
          status: 'stable',
        },
      },
      location: {
        latitude: 35.6762,
        longitude: 139.6503,
        city: 'Tokyo',
      },
      context: {
        currentTime: '07:15',
        dayOfWeek: '水曜日',
        todayMode: 'normal',
      },
    });

    it('should return valid XML structure', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<user_data>');
      expect(xml).toContain('</user_data>');
    });

    it('should include profile section', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<profile>');
      expect(xml).toContain('</profile>');
      expect(xml).toContain('<nickname>マサ</nickname>');
      expect(xml).toContain('<age>28</age>');
      expect(xml).toContain('<gender>男性</gender>');
      expect(xml).toContain('<chronotype>朝型</chronotype>');
      expect(xml).toContain('<target_bedtime>23:00</target_bedtime>');
    });

    it('should include optional profile fields when present', () => {
      const request = createMinimalRequest();
      request.profile.occupation = 'deskWork';
      request.profile.exerciseFrequency = 'twiceWeek';

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<occupation>デスクワーク</occupation>');
      expect(xml).toContain('<exercise_frequency>週2回</exercise_frequency>');
    });

    it('should not include optional profile fields when absent', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).not.toContain('<occupation>');
      expect(xml).not.toContain('<exercise_frequency>');
    });

    it('should include health section with scores', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<health');
      expect(xml).toContain('</health>');
      expect(xml).toContain('<scores>');
      expect(xml).toContain('<autonomic>85</autonomic>');
      expect(xml).toContain('<sleep>78</sleep>');
      expect(xml).toContain('<rhythm>88</rhythm>');
      expect(xml).toContain('<activity>68</activity>');
    });

    it('should include rhythm section', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<rhythm>');
      expect(xml).toContain('<bedtime_stddev_minutes>22</bedtime_stddev_minutes>');
      expect(xml).toContain('<waketime_stddev_minutes>18</waketime_stddev_minutes>');
      expect(xml).toContain('<consecutive_stable_days>5</consecutive_stable_days>');
      expect(xml).toContain('<stability_status>安定</stability_status>');
    });

    it('should include sleep section when present', () => {
      const request = createMinimalRequest();
      request.healthData.sleep = {
        bedtime: '23:15',
        wakeTime: '06:45',
        durationHours: 7.5,
        deepSleepMinutes: 105,
        remSleepMinutes: 95,
        deepSleepRatio: 0.23,
      };

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<sleep>');
      expect(xml).toContain('<bedtime>23:15</bedtime>');
      expect(xml).toContain('<wake_time>06:45</wake_time>');
      expect(xml).toContain('<duration_hours>7.5</duration_hours>');
      expect(xml).toContain('<deep_sleep_minutes>105</deep_sleep_minutes>');
      expect(xml).toContain('<rem_sleep_minutes>95</rem_sleep_minutes>');
      expect(xml).toContain('<deep_sleep_ratio>0.23</deep_sleep_ratio>');
    });

    it('should include HRV section when present', () => {
      const request = createMinimalRequest();
      request.healthData.hrv = {
        value: 68,
        baseline30d: 62,
        deviationPercent: 9.7,
      };

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<hrv>');
      expect(xml).toContain('<value_ms>68</value_ms>');
      expect(xml).toContain('<baseline_30d_ms>62</baseline_30d_ms>');
      expect(xml).toContain('<deviation_percent>+9.7</deviation_percent>');
    });

    it('should include negative HRV deviation without plus sign', () => {
      const request = createMinimalRequest();
      request.healthData.hrv = {
        value: 55,
        baseline30d: 62,
        deviationPercent: -11.3,
      };

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<deviation_percent>-11.3</deviation_percent>');
    });

    it('should include activity section when present', () => {
      const request = createMinimalRequest();
      request.healthData.activity = {
        stepsYesterday: 8200,
        activeMinutesYesterday: 35,
      };

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<activity>');
      expect(xml).toContain('<steps_yesterday>8200</steps_yesterday>');
      expect(xml).toContain('<active_minutes_yesterday>35</active_minutes_yesterday>');
    });

    it('should include auxiliary data when present', () => {
      const request = createMinimalRequest();
      request.healthData.auxiliary = {
        daylightMinutesYesterday: 45,
        wristTemperatureDeviation: 0.1,
      };

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<daylight>');
      expect(xml).toContain('<minutes_yesterday>45</minutes_yesterday>');
      expect(xml).toContain('<wrist_temperature>');
      expect(xml).toContain('<deviation_celsius>+0.1</deviation_celsius>');
    });

    it('should include environment section when weather is present', () => {
      const request = createMinimalRequest();
      request.weather = {
        temperature: 20.5,
        humidity: 65,
        pressure: 1013.25,
        weatherCode: 0,
        uvIndexMax: 5.2,
      };

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<environment>');
      expect(xml).toContain('<location>Tokyo</location>');
      expect(xml).toContain('<temperature_celsius>21</temperature_celsius>');
      expect(xml).toContain('<humidity_percent>65</humidity_percent>');
      expect(xml).toContain('<pressure_hpa>1013</pressure_hpa>');
      expect(xml).toContain('<uv_index>5</uv_index>');
    });

    it('should not include environment section when weather is absent', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).not.toContain('<environment>');
    });

    it('should include context section', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<context>');
      expect(xml).toContain('<current_time>07:15</current_time>');
      expect(xml).toContain('<today_mode>normal</today_mode>');
    });

    it('should include mood when present', () => {
      const request = createMinimalRequest();
      request.context.mood = 4;

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<mood>4</mood>');
    });

    it('should not include mood when absent', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).not.toContain('<mood>');
    });

    it('should escape XML special characters in nickname', () => {
      const request = createMinimalRequest();
      request.profile.nickname = '<マサ&"友人">';

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('&lt;マサ&amp;&quot;友人&quot;&gt;');
    });

    it('should escape XML special characters in city', () => {
      const request = createMinimalRequest();
      request.weather = {
        temperature: 20,
        humidity: 65,
        pressure: 1013,
        weatherCode: 0,
        uvIndexMax: 5,
      };
      request.location.city = 'Tokyo <東京>';

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('Tokyo &lt;東京&gt;');
    });

    it('should format ISO8601 time correctly', () => {
      const request = createMinimalRequest();
      request.healthData.sleep = {
        bedtime: '2025-01-01T23:15:00+09:00',
        wakeTime: '2025-01-02T06:45:00+09:00',
        durationHours: 7.5,
        deepSleepMinutes: 105,
        remSleepMinutes: 95,
        deepSleepRatio: 0.23,
      };

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<bedtime>23:15</bedtime>');
      expect(xml).toContain('<wake_time>06:45</wake_time>');
    });

    it('should map gender correctly', () => {
      const genderTests = [
        { input: 'male', expected: '男性' },
        { input: 'female', expected: '女性' },
        { input: 'other', expected: 'その他' },
        { input: 'preferNotToSay', expected: '回答しない' },
      ] as const;

      for (const { input, expected } of genderTests) {
        const request = createMinimalRequest();
        request.profile.gender = input;
        const xml = PromptBuilder.buildUserDataXml(request);
        expect(xml).toContain(`<gender>${expected}</gender>`);
      }
    });

    it('should map chronotype correctly', () => {
      const chronotypeTests = [
        { input: 'morning', expected: '朝型' },
        { input: 'intermediate', expected: '中間型' },
        { input: 'evening', expected: '夜型' },
      ] as const;

      for (const { input, expected } of chronotypeTests) {
        const request = createMinimalRequest();
        request.profile.chronotype = input;
        const xml = PromptBuilder.buildUserDataXml(request);
        expect(xml).toContain(`<chronotype>${expected}</chronotype>`);
      }
    });

    it('should map occupation correctly', () => {
      const occupationTests = [
        { input: 'deskWork', expected: 'デスクワーク' },
        { input: 'standingWork', expected: '立ち仕事' },
        { input: 'physicalWork', expected: '肉体労働' },
        { input: 'hybrid', expected: 'ハイブリッド' },
        { input: 'other', expected: 'その他' },
      ] as const;

      for (const { input, expected } of occupationTests) {
        const request = createMinimalRequest();
        request.profile.occupation = input;
        const xml = PromptBuilder.buildUserDataXml(request);
        expect(xml).toContain(`<occupation>${expected}</occupation>`);
      }
    });

    it('should map exercise frequency correctly', () => {
      const frequencyTests = [
        { input: 'rarely', expected: 'ほとんどしない' },
        { input: 'onceWeek', expected: '週1回' },
        { input: 'twiceWeek', expected: '週2回' },
        { input: 'threeOrMore', expected: '週3回以上' },
        { input: 'daily', expected: '毎日' },
      ] as const;

      for (const { input, expected } of frequencyTests) {
        const request = createMinimalRequest();
        request.profile.exerciseFrequency = input;
        const xml = PromptBuilder.buildUserDataXml(request);
        expect(xml).toContain(`<exercise_frequency>${expected}</exercise_frequency>`);
      }
    });

    it('should map rhythm status correctly', () => {
      const statusTests = [
        { input: 'stable', expected: '安定' },
        { input: 'recovering', expected: '回復中' },
        { input: 'unstable', expected: '乱れ気味' },
      ] as const;

      for (const { input, expected } of statusTests) {
        const request = createMinimalRequest();
        request.healthData.rhythmAnalysis.status = input;
        const xml = PromptBuilder.buildUserDataXml(request);
        expect(xml).toContain(`<stability_status>${expected}</stability_status>`);
      }
    });
  });
});
