"use client";

import maplibregl from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";
import { useEffect, useRef } from "react";

import { env } from "@/lib/env";

interface RouteMapProps {
  /** Driver position — `[lng, lat]`. */
  from: [number, number] | null;
  /** Destination — `[lng, lat]`. */
  to: [number, number] | null;
  /** Pre-computed OSRM polyline. */
  route?: { type: "LineString"; coordinates: [number, number][] } | null;
  /** Fixed height in CSS units. */
  height?: string;
  /** Aria label for the map region. */
  ariaLabel: string;
}

/**
 * Lightweight MapLibre wrapper that draws driver → destination markers
 * + an OSRM polyline. Uses public OSM raster tiles by default; swap
 * `NEXT_PUBLIC_MAP_TILE_URL` for a self-hosted/vector source in prod.
 */
export function RouteMap({ from, to, route, height = "16rem", ariaLabel }: RouteMapProps) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<maplibregl.Map | null>(null);
  const driverMarkerRef = useRef<maplibregl.Marker | null>(null);
  const destMarkerRef = useRef<maplibregl.Marker | null>(null);

  // Init map once.
  useEffect(() => {
    if (!containerRef.current || mapRef.current) return undefined;

    const map = new maplibregl.Map({
      container: containerRef.current,
      style: {
        version: 8,
        sources: {
          osm: {
            type: "raster",
            tiles: [env.NEXT_PUBLIC_MAP_TILE_URL],
            tileSize: 256,
            attribution: '© <a href="https://openstreetmap.org/copyright">OpenStreetMap</a>',
          },
        },
        layers: [{ id: "osm", type: "raster", source: "osm" }],
      },
      center: from ?? to ?? [30.95, 30.45],
      zoom: 13,
    });

    map.addControl(new maplibregl.NavigationControl({ showCompass: false }), "top-right");
    mapRef.current = map;

    return () => {
      map.remove();
      mapRef.current = null;
      driverMarkerRef.current = null;
      destMarkerRef.current = null;
    };
  }, [from, to]);

  // Update markers + polyline whenever inputs change.
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    const sync = () => {
      // Driver marker.
      if (from) {
        if (!driverMarkerRef.current) {
          driverMarkerRef.current = new maplibregl.Marker({ color: "#cf6f2c" })
            .setLngLat(from)
            .addTo(map);
        } else {
          driverMarkerRef.current.setLngLat(from);
        }
      }

      // Destination marker.
      if (to) {
        if (!destMarkerRef.current) {
          destMarkerRef.current = new maplibregl.Marker({ color: "#0f766e" })
            .setLngLat(to)
            .addTo(map);
        } else {
          destMarkerRef.current.setLngLat(to);
        }
      }

      // Polyline source.
      if (route) {
        const data = {
          type: "Feature" as const,
          geometry: route,
          properties: {},
        };
        const src = map.getSource("route");
        if (src?.type === "geojson") {
          (src as maplibregl.GeoJSONSource).setData(data);
        } else {
          map.addSource("route", { type: "geojson", data });
          map.addLayer({
            id: "route-line",
            type: "line",
            source: "route",
            layout: { "line-cap": "round", "line-join": "round" },
            paint: { "line-color": "#cf6f2c", "line-width": 4 },
          });
        }
      }

      // Fit bounds.
      if (from && to) {
        const bounds = new maplibregl.LngLatBounds().extend(from).extend(to);
        map.fitBounds(bounds, { padding: 60, duration: 0 });
      }
    };

    if (map.isStyleLoaded()) {
      sync();
    } else {
      // `once("load", ...)` returns the map for chaining; the lint rule sees
      // it as a floating promise even though it isn't. Cast it to void.
      void map.once("load", sync);
    }
  }, [from, to, route]);

  return (
    <div
      ref={containerRef}
      role="region"
      aria-label={ariaLabel}
      className="overflow-hidden rounded-2xl border bg-muted"
      style={{ height }}
      data-testid="route-map"
    />
  );
}
