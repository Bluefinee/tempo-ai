/**
 * Mock User Data
 * User profile related mock data
 */

import type { UserProfile } from "../../domain/models";

/**
 * MOCK USER PROFILE
 */
export const MOCK_USER: UserProfile = {
	id: "mock_user_1",
	nickname: "John",
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
