/**
 * Mock User Data
 * ユーザープロファイル関連のモックデータ
 */

import type { UserProfile } from "../../domain/models";

/**
 * MOCK USER PROFILE
 */
export const MOCK_USER: UserProfile = {
  id: "mock_user_1",
  nickname: "太郎",
  age: 30,
  gender: "male",
  heightCm: 175,
  weightKg: 70,
  chronotype: "morning",
  targetBedtime: "23:00",
  occupation: "deskWork",
  exerciseFrequency: "twiceWeek",
  calibrationDaysCompleted: 7,
  createdAt: new Date(),
  updatedAt: new Date(),
};
