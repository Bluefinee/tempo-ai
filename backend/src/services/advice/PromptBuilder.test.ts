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
      expect(prompt).toContain('"todayInsight"');
      expect(prompt).toContain('"todayOneThing"');
      expect(prompt).toContain('"relatedInsight"');
      expect(prompt).toContain('"whyThisMatters"');
      expect(prompt).toContain('"whatThisMeansForToday"');
    });

    it('should contain personalization_rules section', () => {
      const prompt = PromptBuilder.buildSystemPrompt();
      expect(prompt).toContain('<personalization_rules>');
      expect(prompt).toContain('</personalization_rules>');
      expect(prompt).toContain('better_sleep');
      expect(prompt).toContain('more_energy');
      expect(prompt).toContain('less_stress');
      expect(prompt).toContain('peak_performance');
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
      user: {
        goals: ['better_sleep'],
        wakeUpTime: '07:00',
        windDownTime: '23:00',
      },
      scores: {
        recovery: 70,
        sleep: 85,
        rhythm: 92,
        energy: 78,
      },
      healthMetrics: {
        hrv: {
          current: 82,
          baseline: 77,
          deviation: 6,
        },
        rhr: {
          current: 59,
          baseline: 59,
        },
        sleep: {
          durationMinutes: 428,
          deepSleepMinutes: 105,
          deepSleepPercent: 23,
          remSleepMinutes: 95,
          remSleepPercent: 22,
          bedtime: '23:15',
          wakeTime: '06:45',
          vsTargetBedtime: '+15min',
        },
      },
      weather: {
        temperature: 8,
        pressure: 1018,
        pressureTrend: 'stable',
        sunrise: '06:50',
        sunset: '16:48',
        description: '晴れ',
        location: 'Tokyo',
      },
      rhythmPhases: {
        peakFocus: {
          start: '09:00',
          end: '12:00',
        },
        afternoonDip: {
          start: '14:00',
          end: '16:00',
        },
        secondWind: {
          start: '17:00',
          end: '20:00',
        },
        windDown: {
          start: '21:00',
          end: '23:00',
        },
      },
      locale: 'ja',
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
      expect(xml).toContain('<goals>better_sleep</goals>');
      expect(xml).toContain('<wake_up_time>07:00</wake_up_time>');
      expect(xml).toContain('<wind_down_time>23:00</wind_down_time>');
    });

    it('should include scores section', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<scores');
      expect(xml).toContain('<recovery value="70"');
      expect(xml).toContain('<sleep value="85"');
      expect(xml).toContain('<rhythm value="92"');
      expect(xml).toContain('<energy value="78"');
    });

    it('should include health section with metrics', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<health>');
      expect(xml).toContain('</health>');
      expect(xml).toContain('<hrv current_ms="82"');
      expect(xml).toContain('baseline_ms="77"');
      expect(xml).toContain('<rhr current_bpm="59"');
      expect(xml).toContain('baseline_bpm="59"');
      expect(xml).toContain('<sleep>');
      expect(xml).toContain('<duration_minutes>428</duration_minutes>');
      expect(xml).toContain('<deep_sleep_percent>23</deep_sleep_percent>');
      expect(xml).toContain('<rem_sleep_percent>22</rem_sleep_percent>');
    });

    it('should include sleep section with bedtime/wakeTime', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<sleep>');
      expect(xml).toContain('<bedtime>23:15</bedtime>');
      expect(xml).toContain('<wake_time>06:45</wake_time>');
      expect(xml).toContain('<vs_target_bedtime>+15min</vs_target_bedtime>');
    });

    it('should include rhythm_phases section', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<rhythm_phases>');
      expect(xml).toContain('<peak_focus start="09:00" end="12:00"');
      expect(xml).toContain('<afternoon_dip start="14:00" end="16:00"');
    });

    it('should include environment section with weather data', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<environment>');
      expect(xml).toContain('<location>Tokyo</location>');
      expect(xml).toContain('<weather>晴れ</weather>');
      expect(xml).toContain('<temperature_celsius>8</temperature_celsius>');
      expect(xml).toContain('<pressure_hpa>1018</pressure_hpa>');
      expect(xml).toContain('<pressure_trend>stable</pressure_trend>');
      expect(xml).toContain('<sunrise>06:50</sunrise>');
      expect(xml).toContain('<sunset>16:48</sunset>');
    });

    it('should include context section with current time and day', () => {
      const request = createMinimalRequest();
      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('<context>');
      expect(xml).toContain('<current_time>');
      expect(xml).toContain('<day_of_week>');
    });

    it('should escape XML special characters in location', () => {
      const request = createMinimalRequest();
      request.weather.location = 'Tokyo <東京>';

      const xml = PromptBuilder.buildUserDataXml(request);

      expect(xml).toContain('Tokyo &lt;東京&gt;');
    });
  });
});
