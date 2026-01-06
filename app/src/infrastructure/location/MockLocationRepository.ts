/**
 * Mock Location Repository
 * Returns mock data for development and testing
 */

import {
  LocationRepository,
  LocationData,
  LocationPermissionStatus,
  Coordinates,
} from './LocationRepository';

// Mock data for Tokyo
const MOCK_LOCATION: LocationData = {
  coordinates: {
    latitude: 35.6762,
    longitude: 139.6503,
  },
  city: 'Tokyo',
  country: 'Japan',
  timestamp: new Date(),
};

export class MockLocationRepository implements LocationRepository {
  private permissionStatus: LocationPermissionStatus = 'undetermined';
  private simulateDelay = true;

  constructor(options?: { simulateDelay?: boolean }) {
    this.simulateDelay = options?.simulateDelay ?? true;
  }

  private async delay(ms: number): Promise<void> {
    if (this.simulateDelay) {
      await new Promise((resolve) => setTimeout(resolve, ms));
    }
  }

  async getPermissionStatus(): Promise<LocationPermissionStatus> {
    return this.permissionStatus;
  }

  async requestPermission(): Promise<LocationPermissionStatus> {
    await this.delay(300);
    this.permissionStatus = 'granted';
    return this.permissionStatus;
  }

  async getCurrentLocation(): Promise<LocationData> {
    await this.delay(200);
    return {
      ...MOCK_LOCATION,
      timestamp: new Date(),
    };
  }

  async getLastKnownLocation(): Promise<LocationData | null> {
    return {
      ...MOCK_LOCATION,
      timestamp: new Date(),
    };
  }

  async reverseGeocode(
    _coordinates: Coordinates
  ): Promise<{ city: string; country: string } | null> {
    await this.delay(100);
    return {
      city: 'Tokyo',
      country: 'Japan',
    };
  }

  async isAvailable(): Promise<boolean> {
    return true;
  }
}

// Singleton instance
export const mockLocationRepository = new MockLocationRepository();
