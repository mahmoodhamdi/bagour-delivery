import { z } from "zod";

/**
 * Validated environment schema. Reads only NEXT_PUBLIC_* on the client
 * (Next.js inlines them) and falls back to defaults safely.
 *
 * Throw early at module init if a required var is missing so we never
 * silently call the wrong backend.
 */
const envSchema = z.object({
  NEXT_PUBLIC_API_URL: z.string().url().default("http://localhost:5000"),
  NEXT_PUBLIC_APP_URL: z.string().url().default("http://localhost:3001"),
  NEXT_PUBLIC_DEFAULT_LOCALE: z.enum(["ar", "en"]).default("ar"),
  NEXT_PUBLIC_VAPID_PUBLIC_KEY: z.string().optional(),
  NEXT_PUBLIC_MAP_TILE_URL: z
    .string()
    .url()
    .default("https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
  NEXT_PUBLIC_OSRM_URL: z.string().url().default("https://router.project-osrm.org"),
});

const parsed = envSchema.safeParse({
  NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
  NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
  NEXT_PUBLIC_DEFAULT_LOCALE: process.env.NEXT_PUBLIC_DEFAULT_LOCALE,
  NEXT_PUBLIC_VAPID_PUBLIC_KEY: process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY,
  NEXT_PUBLIC_MAP_TILE_URL: process.env.NEXT_PUBLIC_MAP_TILE_URL,
  NEXT_PUBLIC_OSRM_URL: process.env.NEXT_PUBLIC_OSRM_URL,
});

if (!parsed.success) {
  console.error("[env] invalid environment", parsed.error.flatten().fieldErrors);
  throw new Error("Invalid environment configuration — see logs.");
}

export const env = parsed.data;
export type Env = typeof env;
