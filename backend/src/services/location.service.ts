import axios from 'axios';
import config from '@config/index';
import { logger } from '@utils/logger';

interface Coordinates {
  lat: number;
  lng: number;
}

interface GeocodeResult {
  lat: number;
  lng: number;
  displayName: string;
  address?: {
    road?: string;
    suburb?: string;
    city?: string;
    state?: string;
    country?: string;
  };
}

interface ReverseGeocodeResult {
  displayName: string;
  address?: {
    road?: string;
    suburb?: string;
    city?: string;
    state?: string;
    country?: string;
  };
}

interface RouteResult {
  distance: number; // meters
  duration: number; // seconds
  geometry?: {
    type: string;
    coordinates: [number, number][];
  };
}

interface DistanceMatrixResult {
  distance: number; // meters
  duration: number; // seconds
}

/**
 * Location Service using FREE OpenStreetMap APIs
 * - Nominatim for geocoding/reverse geocoding
 * - OSRM for routing and distance calculations
 *
 * Cost savings: ~$220/month vs Google Maps for typical usage
 */
class LocationService {
  private nominatimUrl: string;
  private osrmUrl: string;

  constructor() {
    this.nominatimUrl = config.nominatimBaseUrl;
    this.osrmUrl = config.osrmBaseUrl;
  }

  /**
   * Geocode an address to coordinates using Nominatim
   */
  async geocode(address: string): Promise<GeocodeResult | null> {
    try {
      const response = await axios.get(`${this.nominatimUrl}/search`, {
        params: {
          q: address,
          format: 'json',
          limit: 1,
          countrycodes: 'eg', // Egypt
          addressdetails: 1,
        },
        headers: {
          'User-Agent': 'BagourDelivery/1.0',
          'Accept-Language': 'ar,en',
        },
      });

      if (response.data && response.data.length > 0) {
        const result = response.data[0];
        return {
          lat: parseFloat(result.lat),
          lng: parseFloat(result.lon),
          displayName: result.display_name,
          address: result.address,
        };
      }
      return null;
    } catch (error) {
      logger.error('Geocoding error:', error);
      return null;
    }
  }

  /**
   * Reverse geocode coordinates to address using Nominatim
   */
  async reverseGeocode(lat: number, lng: number): Promise<ReverseGeocodeResult | null> {
    try {
      const response = await axios.get(`${this.nominatimUrl}/reverse`, {
        params: {
          lat,
          lon: lng,
          format: 'json',
          addressdetails: 1,
        },
        headers: {
          'User-Agent': 'BagourDelivery/1.0',
          'Accept-Language': 'ar,en',
        },
      });

      if (response.data && response.data.display_name) {
        return {
          displayName: response.data.display_name,
          address: response.data.address,
        };
      }
      return null;
    } catch (error) {
      logger.error('Reverse geocoding error:', error);
      return null;
    }
  }

  /**
   * Get route between two points using OSRM
   */
  async getRoute(origin: Coordinates, destination: Coordinates): Promise<RouteResult | null> {
    try {
      const response = await axios.get(
        `${this.osrmUrl}/route/v1/driving/${origin.lng},${origin.lat};${destination.lng},${destination.lat}`,
        {
          params: {
            overview: 'full',
            geometries: 'geojson',
          },
        }
      );

      if (response.data && response.data.routes && response.data.routes.length > 0) {
        const route = response.data.routes[0];
        return {
          distance: route.distance,
          duration: route.duration,
          geometry: route.geometry,
        };
      }
      return null;
    } catch (error) {
      logger.error('Routing error:', error);
      return null;
    }
  }

  /**
   * Get distance and duration between two points using OSRM
   */
  async getDistance(origin: Coordinates, destination: Coordinates): Promise<DistanceMatrixResult | null> {
    try {
      const response = await axios.get(
        `${this.osrmUrl}/route/v1/driving/${origin.lng},${origin.lat};${destination.lng},${destination.lat}`,
        {
          params: {
            overview: 'false',
          },
        }
      );

      if (response.data && response.data.routes && response.data.routes.length > 0) {
        const route = response.data.routes[0];
        return {
          distance: route.distance,
          duration: route.duration,
        };
      }
      return null;
    } catch (error) {
      logger.error('Distance calculation error:', error);
      return null;
    }
  }

  /**
   * Calculate delivery fee based on distance
   */
  async calculateDeliveryFee(
    restaurantLocation: Coordinates,
    deliveryLocation: Coordinates
  ): Promise<{ fee: number; distance: number; duration: number } | null> {
    const result = await this.getDistance(restaurantLocation, deliveryLocation);

    if (!result) {
      return null;
    }

    const distanceKm = result.distance / 1000;
    const fee = Math.ceil(distanceKm * config.deliveryFeePerKm);

    return {
      fee: Math.max(fee, config.serviceFee), // Minimum fee
      distance: result.distance,
      duration: result.duration,
    };
  }

  /**
   * Check if delivery address is within service area
   */
  async isWithinDeliveryRange(
    restaurantLocation: Coordinates,
    deliveryLocation: Coordinates
  ): Promise<boolean> {
    const result = await this.getDistance(restaurantLocation, deliveryLocation);

    if (!result) {
      return false;
    }

    const distanceKm = result.distance / 1000;
    return distanceKm <= config.maxDeliveryDistance;
  }

  /**
   * Find nearby restaurants using MongoDB geospatial queries
   * This leverages MongoDB's $geoNear instead of Google Places
   */
  async findNearbyRestaurants(
    location: Coordinates,
    radiusKm: number = 5,
    limit: number = 50
  ): Promise<any[]> {
    try {
      // This should be imported from models but keeping it simple
      const Restaurant = require('@models/Restaurant').default;

      const restaurants = await Restaurant.find({
        isActive: true,
        'location.coordinates': {
          $near: {
            $geometry: {
              type: 'Point',
              coordinates: [location.lng, location.lat],
            },
            $maxDistance: radiusKm * 1000, // Convert to meters
          },
        },
      }).limit(limit);

      return restaurants;
    } catch (error) {
      logger.error('Find nearby restaurants error:', error);
      return [];
    }
  }

  /**
   * Find nearby available drivers using MongoDB geospatial queries
   */
  async findNearbyDrivers(
    location: Coordinates,
    radiusKm: number = 10,
    limit: number = 20
  ): Promise<any[]> {
    try {
      const Driver = require('@models/Driver').default;

      const drivers = await Driver.find({
        isOnline: true,
        isAvailable: true,
        'currentLocation.coordinates': {
          $near: {
            $geometry: {
              type: 'Point',
              coordinates: [location.lng, location.lat],
            },
            $maxDistance: radiusKm * 1000,
          },
        },
      }).limit(limit);

      return drivers;
    } catch (error) {
      logger.error('Find nearby drivers error:', error);
      return [];
    }
  }

  /**
   * Format distance for display in Arabic
   */
  formatDistance(meters: number): string {
    if (meters >= 1000) {
      return `${(meters / 1000).toFixed(1)} كم`;
    }
    return `${Math.round(meters)} م`;
  }

  /**
   * Format duration for display in Arabic
   */
  formatDuration(seconds: number): string {
    const minutes = Math.round(seconds / 60);
    if (minutes >= 60) {
      const hours = Math.floor(minutes / 60);
      const remainingMinutes = minutes % 60;
      if (remainingMinutes === 0) {
        return `${hours} س`;
      }
      return `${hours} س ${remainingMinutes} د`;
    }
    return `${minutes} د`;
  }

  /**
   * Calculate straight-line distance between two points (Haversine formula)
   * Useful for quick distance estimates without API calls
   */
  calculateHaversineDistance(origin: Coordinates, destination: Coordinates): number {
    const R = 6371000; // Earth's radius in meters
    const lat1Rad = (origin.lat * Math.PI) / 180;
    const lat2Rad = (destination.lat * Math.PI) / 180;
    const deltaLat = ((destination.lat - origin.lat) * Math.PI) / 180;
    const deltaLng = ((destination.lng - origin.lng) * Math.PI) / 180;

    const a =
      Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
      Math.cos(lat1Rad) * Math.cos(lat2Rad) * Math.sin(deltaLng / 2) * Math.sin(deltaLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance in meters
  }
}

export const locationService = new LocationService();
export default LocationService;
