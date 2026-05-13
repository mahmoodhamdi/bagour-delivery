import bagourBase from "@bagour/config-eslint/base.mjs";
import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";
import tseslint from "typescript-eslint";

/**
 * driver-web ESLint config — mirrors customer-web. eslint-config-next pulls
 * in import/react/react-hooks/jsx-a11y; we add @bagour/config-eslint/base
 * (typescript-eslint type-checked + security) on top.
 */
export default defineConfig([
  globalIgnores([
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
    "playwright-report/**",
    "test-results/**",
    "coverage/**",
    "public/sw.js",
    "public/sw.js.map",
  ]),
  ...nextVitals,
  ...nextTs,
  ...bagourBase,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
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
  },
  {
    files: ["e2e/**/*.ts", "**/*.test.ts", "**/*.test.tsx"],
    rules: {
      "@typescript-eslint/no-floating-promises": "off",
    },
  },
  {
    files: ["*.{js,mjs,cjs,ts,mts}", "*.config.{js,mjs,cjs,ts,mts}"],
    ...tseslint.configs.disableTypeChecked,
  },
]);
