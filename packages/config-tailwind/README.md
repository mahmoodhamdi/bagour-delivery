# @bagour/config-tailwind

Shared Tailwind v4 preset for Bagour Delivery web apps. Provides brand colors, radius scale, font tokens, and dark-mode mapping.

## Usage

In an app's `globals.css`:

```css
@import "tailwindcss";
@import "@bagour/config-tailwind/fonts.css";
@import "@bagour/config-tailwind/brand.css";
@import "@bagour/config-tailwind/theme.css";
```

Order matters: `tailwindcss` first, then brand tokens, then the `@theme inline` bridge.

## Customizing for a downstream client

To rebrand without forking, override the CSS variables in your app's own globals.css **after** importing `brand.css`:

```css
@import "@bagour/config-tailwind/brand.css";

:root {
  --brand-primary: oklch(0.65 0.2 250); /* swap to a cool blue */
  --brand-accent: oklch(0.75 0.18 180);
}

@import "@bagour/config-tailwind/theme.css";
```

The `@theme inline` block reads through `var(--brand-primary)` so the override flows everywhere — buttons, badges, focus rings.

## Why CSS-only, no JS preset?

Tailwind v4's primary configuration surface is CSS (`@theme`). A JS preset would have to be re-evaluated by every app — not worth the complexity. Keeping it as plain CSS imports makes it trivially debuggable in DevTools.
