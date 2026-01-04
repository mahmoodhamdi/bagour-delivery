'use client';

import { useEffect, useRef, useState } from 'react';
import dynamic from 'next/dynamic';
import type { Zone as ApiZone } from '@/services/api';

// Bagour city center coordinates
const BAGOUR_CENTER = { lat: 30.4167, lng: 30.9667 };
const DEFAULT_ZOOM = 13;

// Re-export the Zone type from API for use in the component
type Zone = ApiZone;

interface ZoneMapProps {
  zones: Zone[];
  selectedZone?: Zone | null;
  onZoneSelect?: (zone: Zone) => void;
  editable?: boolean;
  onPolygonChange?: (polygon: [number, number][]) => void;
}

// Simple map component without react-leaflet for SSR compatibility
function ZoneMapComponent({ zones, selectedZone, onZoneSelect, editable, onPolygonChange }: ZoneMapProps) {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<L.Map | null>(null);
  const [isMapReady, setIsMapReady] = useState(false);
  const [L, setL] = useState<typeof import('leaflet') | null>(null);

  useEffect(() => {
    // Dynamically import leaflet on client side only
    import('leaflet').then((leaflet) => {
      setL(leaflet.default);
    });
  }, []);

  useEffect(() => {
    if (!L || !mapRef.current || mapInstanceRef.current) return;

    // Fix for default markers
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    delete (L.Icon.Default.prototype as any)._getIconUrl;
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
      iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
      shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
    });

    // Initialize map
    const map = L.map(mapRef.current).setView([BAGOUR_CENTER.lat, BAGOUR_CENTER.lng], DEFAULT_ZOOM);

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
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

    // Clear existing layers
    map.eachLayer((layer) => {
      if (layer instanceof L.Polygon || layer instanceof L.Circle || layer instanceof L.Marker) {
        map.removeLayer(layer);
      }
    });

    // Add zones to map
    zones.forEach((zone) => {
      // Check if zone has GeoJSON polygon coordinates
      if (zone.coordinates && zone.coordinates.type === 'Polygon' && zone.coordinates.coordinates.length > 0) {
        // Convert GeoJSON coordinates [lng, lat] to Leaflet format [lat, lng]
        const polygonCoords: [number, number][] = zone.coordinates.coordinates[0].map(
          (coord: number[]) => [coord[1], coord[0]] as [number, number]
        );

        const polygon = L.polygon(polygonCoords, {
          color: zone.isActive ? '#22c55e' : '#9ca3af',
          fillColor: zone.isActive ? '#22c55e' : '#9ca3af',
          fillOpacity: selectedZone?._id === zone._id ? 0.4 : 0.2,
          weight: selectedZone?._id === zone._id ? 3 : 1,
        }).addTo(map);

        polygon.bindPopup(`
          <div style="text-align: right; direction: rtl;">
            <strong>${zone.nameAr}</strong><br/>
            رسوم التوصيل: ${zone.deliveryFee} ج.م<br/>
            الحالة: ${zone.isActive ? 'نشط' : 'غير نشط'}
          </div>
        `);

        if (onZoneSelect) {
          polygon.on('click', () => onZoneSelect(zone));
        }
      } else {
        // Add marker at default position with offset based on index for zones without coordinates
        const index = zones.indexOf(zone);
        const offsetLat = (index % 3 - 1) * 0.02;
        const offsetLng = (Math.floor(index / 3) - 1) * 0.02;

        const marker = L.marker([BAGOUR_CENTER.lat + offsetLat, BAGOUR_CENTER.lng + offsetLng]).addTo(map);
        marker.bindPopup(`
          <div style="text-align: right; direction: rtl;">
            <strong>${zone.nameAr}</strong><br/>
            رسوم التوصيل: ${zone.deliveryFee} ج.م<br/>
            الحالة: ${zone.isActive ? 'نشط' : 'غير نشط'}
          </div>
        `);

        if (onZoneSelect) {
          marker.on('click', () => onZoneSelect(zone));
        }
      }
    });

    // Add drawing controls if editable
    if (editable) {
      let drawingPolygon: L.LatLng[] = [];
      let tempMarkers: L.Marker[] = [];
      let tempPolyline: L.Polyline | null = null;

      const handleMapClick = (e: L.LeafletMouseEvent) => {
        drawingPolygon.push(e.latlng);

        // Add marker at click point
        const marker = L.marker(e.latlng, {
          icon: L.divIcon({
            className: 'drawing-point',
            html: `<div style="width: 12px; height: 12px; background: #3b82f6; border-radius: 50%; border: 2px solid white;"></div>`,
            iconSize: [12, 12],
          }),
        }).addTo(map);
        tempMarkers.push(marker);

        // Update polyline
        if (tempPolyline) map.removeLayer(tempPolyline);
        if (drawingPolygon.length > 1) {
          tempPolyline = L.polyline(drawingPolygon, { color: '#3b82f6', dashArray: '5, 10' }).addTo(map);
        }

        // If we have 3+ points, notify parent
        if (drawingPolygon.length >= 3 && onPolygonChange) {
          onPolygonChange(drawingPolygon.map(latlng => [latlng.lat, latlng.lng]));
        }
      };

      map.on('click', handleMapClick);

      // Double-click to finish
      map.on('dblclick', () => {
        if (drawingPolygon.length >= 3) {
          // Clean up temp markers and lines
          tempMarkers.forEach(m => map.removeLayer(m));
          if (tempPolyline) map.removeLayer(tempPolyline);

          // Draw final polygon
          L.polygon(drawingPolygon, {
            color: '#3b82f6',
            fillColor: '#3b82f6',
            fillOpacity: 0.3,
          }).addTo(map);

          if (onPolygonChange) {
            onPolygonChange(drawingPolygon.map(latlng => [latlng.lat, latlng.lng]));
          }

          drawingPolygon = [];
          tempMarkers = [];
          tempPolyline = null;
        }
      });
    }
  }, [isMapReady, zones, selectedZone, editable, L, onZoneSelect, onPolygonChange]);

  return (
    <div className="relative">
      <link
        rel="stylesheet"
        href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
        crossOrigin=""
      />
      <div ref={mapRef} className="h-[400px] w-full rounded-lg border" />
      {!isMapReady && (
        <div className="absolute inset-0 flex items-center justify-center bg-muted rounded-lg">
          <div className="text-muted-foreground">جاري تحميل الخريطة...</div>
        </div>
      )}
      {editable && (
        <div className="absolute bottom-4 left-4 bg-background/90 backdrop-blur-sm p-3 rounded-lg text-sm z-[1000]">
          <p className="font-medium mb-1">رسم منطقة جديدة:</p>
          <ul className="text-muted-foreground text-xs">
            <li>• انقر لإضافة نقاط</li>
            <li>• انقر مرتين للإنهاء</li>
          </ul>
        </div>
      )}
    </div>
  );
}

// Export with dynamic import to prevent SSR issues
export default dynamic(() => Promise.resolve(ZoneMapComponent), {
  ssr: false,
  loading: () => (
    <div className="h-[400px] w-full rounded-lg border bg-muted flex items-center justify-center">
      <div className="text-muted-foreground">جاري تحميل الخريطة...</div>
    </div>
  ),
});
