// @ts-check
import react from "./react.mjs";
import tseslint from "typescript-eslint";

/**
 * Shared ESLint config for Next.js apps in the monorepo.
 *
 * Note: this config intentionally does NOT pull in `eslint-config-next`
 * itself because next.js's built-in plugin needs to be wired through the
 * app's own `eslint.config.mjs` (since it depends on `next` being resolved
 * from the app's `node_modules`). Each app should:
 *
 *   import nextVitals from "eslint-config-next/core-web-vitals";
 *   import nextTs from "eslint-config-next/typescript";
 *   import bagourNext from "@bagour/config-eslint/next.mjs";
 *
 *   export default [...nextVitals, ...nextTs, ...bagourNext, { ... }];
 */
export default tseslint.config(...react, {
  files: ["**/*.{ts,tsx}"],
  rules: {
    // Next.js-specific opinions:
    "react/jsx-key": "error",
    "no-restricted-imports": [
      "error",
      {
        patterns: [
          {
            group: ["next/router"],
            message: "Use `next/navigation` in the App Router.",
          },
        ],
      },
    ],
  },
});
