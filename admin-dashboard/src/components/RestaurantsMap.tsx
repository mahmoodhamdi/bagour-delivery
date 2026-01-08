'use client';

import { useEffect, useRef, useState } from 'react';
import dynamic from 'next/dynamic';

// Bagour city center coordinates
const BAGOUR_CENTER = { lat: 30.4167, lng: 30.9667 };
const DEFAULT_ZOOM = 13;

interface Restaurant {
  id: string;
  name: string;
  nameAr: string;
  address: string;
  isActive: boolean;
  isOpen: boolean;
  rating: number;
  location: { lat: number; lng: number };
}

interface RestaurantsMapProps {
  restaurants: Restaurant[];
  onRestaurantClick?: (restaurantId: string) => void;
  selectedRestaurantId?: string;
  height?: string;
}

function RestaurantsMapComponent({
  restaurants = [],
  onRestaurantClick,
  selectedRestaurantId,
  height = '400px',
}: RestaurantsMapProps) {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<L.Map | null>(null);
  const [isMapReady, setIsMapReady] = useState(false);
  const [L, setL] = useState<typeof import('leaflet') | null>(null);

  useEffect(() => {
    import('leaflet').then((leaflet) => {
      setL(leaflet.default);
    });
  }, []);

  useEffect(() => {
    if (!L || !mapRef.current || mapInstanceRef.current) return;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    delete (L.Icon.Default.prototype as any)._getIconUrl;
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
      iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
      shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
    });

    const map = L.map(mapRef.current).setView([BAGOUR_CENTER.lat, BAGOUR_CENTER.lng], DEFAULT_ZOOM);

    // OpenStreetMap tiles (FREE)
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);

    mapInstanceRef.current = map;
    setIsMapReady(true);

    return () => {
      map.remove();
      mapInstanceRef.current = null;
    };
  }, [L]);

  useEffect(() => {
    if (!isMapReady || !mapInstanceRef.current || !L) return;

    const map = mapInstanceRef.current;

    // Clear existing markers
    map.eachLayer((layer) => {
      if (layer instanceof L.Marker) {
        map.removeLayer(layer);
      }
    });

    // Add restaurant markers
    restaurants.forEach((restaurant) => {
      const isSelected = selectedRestaurantId === restaurant.id;

      // Determine color based on status
      let bgColor = '#22c55e'; // Active and open
      if (!restaurant.isActive) {
        bgColor = '#9ca3af'; // Inactive
      } else if (!restaurant.isOpen) {
        bgColor = '#f97316'; // Active but closed
      }

      const restaurantIcon = L.divIcon({
        className: 'custom-marker',
        html: `<div style="
          background: ${bgColor};
          width: ${isSelected ? '40px' : '32px'};
          height: ${isSelected ? '40px' : '32px'};
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          border: ${isSelected ? '4px' : '3px'} solid white;
          box-shadow: 0 2px 8px rgba(0,0,0,${isSelected ? '0.5' : '0.3'});
          font-size: ${isSelected ? '20px' : '16px'};
          transition: all 0.2s;
        ">🍽️</div>`,
        iconSize: [isSelected ? 40 : 32, isSelected ? 40 : 32],
        iconAnchor: [isSelected ? 20 : 16, isSelected ? 20 : 16],
      });

      const marker = L.marker(
        [restaurant.location.lat, restaurant.location.lng],
        { icon: restaurantIcon }
      ).addTo(map);

      const statusText = !restaurant.isActive
        ? 'غير نشط'
        : restaurant.isOpen
          ? 'مفتوح'
          : 'مغلق';

      const statusColor = !restaurant.isActive
        ? '#9ca3af'
        : restaurant.isOpen
          ? '#22c55e'
          : '#f97316';

      marker.bindPopup(`
        <div style="text-align: right; direction: rtl; min-width: 180px;">
          <strong style="font-size: 14px;">🍽️ ${restaurant.nameAr}</strong><br/>
          <span style="color: #666; font-size: 12px;">${restaurant.address}</span><br/>
          <div style="margin-top: 8px; display: flex; justify-content: space-between; align-items: center;">
            <span style="color: ${statusColor}; font-weight: 500;">${statusText}</span>
            <span style="color: #f59e0b;">⭐ ${restaurant.rating.toFixed(1)}</span>
          </div>
        </div>
      `);

      if (onRestaurantClick) {
        marker.on('click', () => onRestaurantClick(restaurant.id));
      }

      // If selected, open popup automatically
      if (isSelected) {
        marker.openPopup();
      }
    });

    // Fit bounds to show all restaurants
    if (restaurants.length > 0) {
      const points: [number, number][] = restaurants.map((r) => [r.location.lat, r.location.lng]);
      const bounds = L.latLngBounds(points);
      map.fitBounds(bounds, { padding: [50, 50] });
    }
  }, [isMapReady, restaurants, selectedRestaurantId, L, onRestaurantClick]);

  return (
    <div className="relative">
      <link
        rel="stylesheet"
        href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
        crossOrigin=""
      />
      <div ref={mapRef} style={{ height }} className="w-full rounded-lg border" />
      {!isMapReady && (
        <div className="absolute inset-0 flex items-center justify-center bg-muted rounded-lg">
          <div className="text-muted-foreground">جاري تحميل الخريطة...</div>
        </div>
      )}

      {/* Legend */}
      <div className="absolute bottom-4 right-4 bg-background/95 backdrop-blur-sm p-3 rounded-lg text-xs z-[1000] shadow-lg">
        <p className="font-medium mb-2 text-right">حالة المطاعم:</p>
        <div className="space-y-1 text-right">
          <div className="flex items-center justify-end gap-2">
            <span>مفتوح</span>
            <span className="w-3 h-3 rounded-full bg-green-500"></span>
          </div>
          <div className="flex items-center justify-end gap-2">
            <span>مغلق</span>
            <span className="w-3 h-3 rounded-full bg-orange-500"></span>
          </div>
          <div className="flex items-center justify-end gap-2">
            <span>غير نشط</span>
            <span className="w-3 h-3 rounded-full bg-gray-400"></span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default dynamic(() => Promise.resolve(RestaurantsMapComponent), {
  ssr: false,
  loading: () => (
    <div className="h-[400px] w-full rounded-lg border bg-muted flex items-center justify-center">
      <div className="text-muted-foreground">جاري تحميل الخريطة...</div>
    </div>
  ),
});
