import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  // The driver app is internal — keep it out of search results entirely.
  return {
    rules: [
      {
        userAgent: "*",
        disallow: "/",
      },
    ],
  };
}
