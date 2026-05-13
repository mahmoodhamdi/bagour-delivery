import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Bagour Delivery — باجور ديليفري",
    short_name: "Bagour",
    description: "Local food delivery for Bagour, Monufia — order in Arabic or English.",
    start_url: "/",
    scope: "/",
    display: "standalone",
    orientation: "portrait",
    background_color: "#fdfaf6",
    theme_color: "#cf6f2c",
    lang: "ar",
    dir: "rtl",
    categories: ["food", "lifestyle", "shopping"],
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
        name: "Browse restaurants",
        url: "/restaurants",
        description: "Open the restaurant list",
      },
      {
        name: "My orders",
        url: "/orders",
        description: "Track your recent orders",
      },
    ],
  };
}
