import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Bagour Driver — كابتن باجور",
    short_name: "Bagour Driver",
    description: "تطبيق سائقي باجور — استلم الطلبات ووصّلها بسرعة وأمان.",
    start_url: "/",
    scope: "/",
    display: "standalone",
    orientation: "portrait",
    background_color: "#fdfaf6",
    theme_color: "#cf6f2c",
    lang: "ar",
    dir: "rtl",
    categories: ["business", "navigation", "productivity"],
    icons: [
      {
        src: "/icons/icon-192.png",
        sizes: "192x192",
        type: "image/png",
        purpose: "any",
      },
      {
        src: "/icons/icon-512.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "any",
      },
      {
        src: "/icons/icon-maskable-512.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "maskable",
      },
    ],
    shortcuts: [
      {
        name: "Active orders",
        url: "/active",
        description: "Jump to your current deliveries",
      },
      {
        name: "Earnings",
        url: "/earnings",
        description: "Today's earnings + recent payouts",
      },
    ],
  };
}
