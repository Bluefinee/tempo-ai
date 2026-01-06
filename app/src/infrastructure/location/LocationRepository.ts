/**
 * Location Repository Interface
 * Abstracts location services access
 */

export interface Coordinates {
  latitude: number;
  longitude: number;
}

export interface LocationData {
  coordinates: Coordinates;
  city?: string;
  country?: string;
  timestamp: Date;
}

export type LocationPermissionStatus =
  | 'granted'
  | 'denied'
  | 'undetermined'
  | 'restricted';

export interface LocationRepository {
  /**
   * Get current permission status
   */
  getPermissionStatus(): Promise<LocationPermissionStatus>;

  /**
   * Request location permission
   * @returns the resulting permission status
   */
  requestPermission(): Promise<LocationPermissionStatus>;

  /**
   * Get current location
   */
  getCurrentLocation(): Promise<LocationData>;

  /**
   * Get last known location (may be cached)
   */
  getLastKnownLocation(): Promise<LocationData | null>;

  /**
   * Reverse geocode coordinates to get city name
   */
  reverseGeocode(coordinates: Coordinates): Promise<{ city: string; country: string } | null>;

  /**
   * Check if location services are available
   */
  isAvailable(): Promise<boolean>;
}
