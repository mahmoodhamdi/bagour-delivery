'use client';

import { useEffect, useRef, useState } from 'react';
import dynamic from 'next/dynamic';

// Bagour city center coordinates
const BAGOUR_CENTER = { lat: 30.4167, lng: 30.9667 };
const DEFAULT_ZOOM = 13;

interface OrderLocation {
  id: string;
  orderNumber: string;
  status: string;
  restaurantName: string;
  customerAddress: string;
  restaurantLocation: { lat: number; lng: number };
  deliveryLocation: { lat: number; lng: number };
  driverLocation?: { lat: number; lng: number };
}

interface DriverLocation {
  id: string;
  name: string;
  phone: string;
  isOnline: boolean;
  isAvailable: boolean;
  location: { lat: number; lng: number };
  currentOrderId?: string;
}

interface LiveOrdersMapProps {
  orders?: OrderLocation[];
  drivers?: DriverLocation[];
  onOrderClick?: (orderId: string) => void;
  onDriverClick?: (driverId: string) => void;
  showDrivers?: boolean;
  showOrders?: boolean;
  height?: string;
}

function LiveOrdersMapComponent({
  orders = [],
  drivers = [],
  onOrderClick,
  onDriverClick,
  showDrivers = true,
  showOrders = true,
  height = '500px',
}: LiveOrdersMapProps) {
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
      if (layer instanceof L.Marker || layer instanceof L.Polyline) {
        map.removeLayer(layer);
      }
    });

    // Re-add tile layer if removed
    const hasBaseLayer = Array.from(Object.values(map._layers || {})).some(
      (layer) => layer instanceof L.TileLayer
    );
    if (!hasBaseLayer) {
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap'
      }).addTo(map);
    }

    // Add order markers
    if (showOrders) {
      orders.forEach((order) => {
        // Restaurant marker
        const restaurantIcon = L.divIcon({
          className: 'custom-marker',
          html: `<div style="
            background: #f97316;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 3px solid white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            font-size: 16px;
          ">🍔</div>`,
          iconSize: [32, 32],
          iconAnchor: [16, 16],
        });

        const restaurantMarker = L.marker(
          [order.restaurantLocation.lat, order.restaurantLocation.lng],
          { icon: restaurantIcon }
        ).addTo(map);

        restaurantMarker.bindPopup(`
          <div style="text-align: right; direction: rtl; min-width: 150px;">
            <strong>🍔 ${order.restaurantName}</strong><br/>
            <span style="color: #666;">طلب: ${order.orderNumber}</span>
          </div>
        `);

        // Delivery location marker
        const deliveryIcon = L.divIcon({
          className: 'custom-marker',
          html: `<div style="
            background: #22c55e;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 3px solid white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            font-size: 16px;
          ">📍</div>`,
          iconSize: [32, 32],
          iconAnchor: [16, 16],
        });

        const deliveryMarker = L.marker(
          [order.deliveryLocation.lat, order.deliveryLocation.lng],
          { icon: deliveryIcon }
        ).addTo(map);

        deliveryMarker.bindPopup(`
          <div style="text-align: right; direction: rtl; min-width: 150px;">
            <strong>📍 عنوان التوصيل</strong><br/>
            <span style="color: #666;">${order.customerAddress}</span><br/>
            <small>طلب: ${order.orderNumber}</small>
          </div>
        `);

        if (onOrderClick) {
          restaurantMarker.on('click', () => onOrderClick(order.id));
          deliveryMarker.on('click', () => onOrderClick(order.id));
        }

        // Draw route line between restaurant and delivery
        L.polyline(
          [
            [order.restaurantLocation.lat, order.restaurantLocation.lng],
            [order.deliveryLocation.lat, order.deliveryLocation.lng],
          ],
          { color: '#3b82f6', weight: 2, dashArray: '5, 10', opacity: 0.6 }
        ).addTo(map);

        // Driver location marker (if available)
        if (order.driverLocation) {
          const driverIcon = L.divIcon({
            className: 'custom-marker',
            html: `<div style="
              background: #3b82f6;
              width: 36px;
              height: 36px;
              border-radius: 50%;
              display: flex;
              align-items: center;
              justify-content: center;
              border: 3px solid white;
              box-shadow: 0 2px 8px rgba(0,0,0,0.4);
              font-size: 18px;
            ">🛵</div>`,
            iconSize: [36, 36],
            iconAnchor: [18, 18],
          });

          const driverMarker = L.marker(
            [order.driverLocation.lat, order.driverLocation.lng],
            { icon: driverIcon }
          ).addTo(map);

          driverMarker.bindPopup(`
            <div style="text-align: right; direction: rtl;">
              <strong>🛵 السائق</strong><br/>
              <span>جاري توصيل طلب ${order.orderNumber}</span>
            </div>
          `);
        }
      });
    }

    // Add driver markers
    if (showDrivers) {
      drivers.forEach((driver) => {
        const driverIcon = L.divIcon({
          className: 'custom-marker',
          html: `<div style="
            background: ${driver.isOnline ? (driver.isAvailable ? '#22c55e' : '#f97316') : '#9ca3af'};
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 3px solid white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.4);
            font-size: 18px;
          ">🛵</div>`,
          iconSize: [36, 36],
          iconAnchor: [18, 18],
        });

        const driverMarker = L.marker(
          [driver.location.lat, driver.location.lng],
          { icon: driverIcon }
        ).addTo(map);

        const statusText = driver.isOnline
          ? (driver.isAvailable ? 'متاح' : 'في توصيل')
          : 'غير متصل';

        driverMarker.bindPopup(`
          <div style="text-align: right; direction: rtl; min-width: 150px;">
            <strong>🛵 ${driver.name}</strong><br/>
            <span style="color: ${driver.isOnline ? (driver.isAvailable ? '#22c55e' : '#f97316') : '#9ca3af'};">
              ${statusText}
            </span><br/>
            <small>📱 ${driver.phone}</small>
          </div>
        `);

        if (onDriverClick) {
          driverMarker.on('click', () => onDriverClick(driver.id));
        }
      });
    }

    // Fit bounds to show all markers
    const allPoints: [number, number][] = [];
    orders.forEach((o) => {
      allPoints.push([o.restaurantLocation.lat, o.restaurantLocation.lng]);
      allPoints.push([o.deliveryLocation.lat, o.deliveryLocation.lng]);
      if (o.driverLocation) {
        allPoints.push([o.driverLocation.lat, o.driverLocation.lng]);
      }
    });
    drivers.forEach((d) => {
      allPoints.push([d.location.lat, d.location.lng]);
    });

    if (allPoints.length > 0) {
      const bounds = L.latLngBounds(allPoints);
      map.fitBounds(bounds, { padding: [50, 50] });
    }
  }, [isMapReady, orders, drivers, showOrders, showDrivers, L, onOrderClick, onDriverClick]);

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
        <p className="font-medium mb-2 text-right">دليل الرموز:</p>
        <div className="space-y-1 text-right">
          {showOrders && (
            <>
              <div className="flex items-center justify-end gap-2">
                <span>مطعم</span>
                <span>🍔</span>
              </div>
              <div className="flex items-center justify-end gap-2">
                <span>عنوان التوصيل</span>
                <span>📍</span>
              </div>
            </>
          )}
          {showDrivers && (
            <>
              <div className="flex items-center justify-end gap-2">
                <span>سائق متاح</span>
                <span className="w-3 h-3 rounded-full bg-green-500"></span>
              </div>
              <div className="flex items-center justify-end gap-2">
                <span>سائق في توصيل</span>
                <span className="w-3 h-3 rounded-full bg-orange-500"></span>
              </div>
              <div className="flex items-center justify-end gap-2">
                <span>سائق غير متصل</span>
                <span className="w-3 h-3 rounded-full bg-gray-400"></span>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default dynamic(() => Promise.resolve(LiveOrdersMapComponent), {
  ssr: false,
  loading: () => (
    <div className="h-[500px] w-full rounded-lg border bg-muted flex items-center justify-center">
      <div className="text-muted-foreground">جاري تحميل الخريطة...</div>
    </div>
  ),
});
