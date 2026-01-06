/**
 * Expo Location Repository
 * Implementation using expo-location
 */

import * as Location from 'expo-location';
import {
  LocationRepository,
  LocationData,
  LocationPermissionStatus,
  Coordinates,
} from './LocationRepository';

export class ExpoLocationRepository implements LocationRepository {
  private lastLocation: LocationData | null = null;

  async getPermissionStatus(): Promise<LocationPermissionStatus> {
    const { status } = await Location.getForegroundPermissionsAsync();
    return this.mapExpoStatus(status);
  }

  async requestPermission(): Promise<LocationPermissionStatus> {
    const { status } = await Location.requestForegroundPermissionsAsync();
    return this.mapExpoStatus(status);
  }

  async getCurrentLocation(): Promise<LocationData> {
    const location = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.Balanced,
    });

    const locationData: LocationData = {
      coordinates: {
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
      },
      timestamp: new Date(location.timestamp),
    };

    // Try to get city name
    const geocodeResult = await this.reverseGeocode(locationData.coordinates);
    if (geocodeResult) {
      locationData.city = geocodeResult.city;
      locationData.country = geocodeResult.country;
    }

    this.lastLocation = locationData;
    return locationData;
  }

  async getLastKnownLocation(): Promise<LocationData | null> {
    if (this.lastLocation) {
      return this.lastLocation;
    }

    const location = await Location.getLastKnownPositionAsync();
    if (!location) {
      return null;
    }

    const locationData: LocationData = {
      coordinates: {
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
      },
      timestamp: new Date(location.timestamp),
    };

    this.lastLocation = locationData;
    return locationData;
  }

  async reverseGeocode(
    coordinates: Coordinates
  ): Promise<{ city: string; country: string } | null> {
    try {
      const results = await Location.reverseGeocodeAsync(coordinates);
      if (results.length > 0) {
        const result = results[0];
        return {
          city: result.city || result.district || result.subregion || 'Unknown',
          country: result.country || 'Unknown',
        };
      }
      return null;
    } catch {
      return null;
    }
  }

  async isAvailable(): Promise<boolean> {
    return await Location.hasServicesEnabledAsync();
  }

  private mapExpoStatus(
    status: Location.PermissionStatus
  ): LocationPermissionStatus {
    switch (status) {
      case Location.PermissionStatus.GRANTED:
        return 'granted';
      case Location.PermissionStatus.DENIED:
        return 'denied';
      case Location.PermissionStatus.UNDETERMINED:
        return 'undetermined';
      default:
        return 'undetermined';
    }
  }
}

// Singleton instance
export const expoLocationRepository = new ExpoLocationRepository();
