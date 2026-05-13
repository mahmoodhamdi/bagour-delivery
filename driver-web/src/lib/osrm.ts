import { env } from "./env";

export interface OsrmRoute {
  /** GeoJSON LineString. */
  geometry: { type: "LineString"; coordinates: [number, number][] };
  /** Meters. */
  distance: number;
  /** Seconds. */
  duration: number;
}

/**
 * Fetch a driving route between two coordinates from OSRM. Coordinates
 * are `[lng, lat]` to match GeoJSON convention.
 */
export async function fetchOsrmRoute(
  from: [number, number],
  to: [number, number],
  signal?: AbortSignal,
): Promise<OsrmRoute | null> {
  const base = env.NEXT_PUBLIC_OSRM_URL.replace(/\/$/, "");
  const url = `${base}/route/v1/driving/${from[0]},${from[1]};${to[0]},${to[1]}?overview=full&geometries=geojson`;

  const res = await fetch(url, { signal });
  if (!res.ok) return null;

  const json = (await res.json()) as {
    code: string;
    routes?: { geometry: OsrmRoute["geometry"]; distance: number; duration: number }[];
  };
  if (json.code !== "Ok" || !json.routes?.[0]) return null;

  const r = json.routes[0];
  return { geometry: r.geometry, distance: r.distance, duration: r.duration };
}
