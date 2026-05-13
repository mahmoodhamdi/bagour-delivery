import type { MetadataRoute } from "next";

const APP_URL = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();
  const publicRoutes = ["", "/restaurants", "/login", "/register"];

  return publicRoutes.flatMap((route) => [
    {
      url: `${APP_URL}/ar${route}`,
      lastModified: now,
      alternates: { languages: { en: `${APP_URL}/en${route}` } },
    },
    {
      url: `${APP_URL}/en${route}`,
      lastModified: now,
      alternates: { languages: { ar: `${APP_URL}/ar${route}` } },
    },
  ]);
}
