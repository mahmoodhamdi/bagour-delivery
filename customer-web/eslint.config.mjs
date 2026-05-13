import bagourBase from "@bagour/config-eslint/base.mjs";
import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";
import tseslint from "typescript-eslint";

/**
 * customer-web ESLint config.
 *
 * eslint-config-next already pulls in `eslint-plugin-import`,
 * `eslint-plugin-react`, `eslint-plugin-react-hooks`, and
 * `eslint-plugin-jsx-a11y` — so we only add @bagour/config-eslint/base
 * (typescript-eslint type-checked rules + security plugin) on top to
 * avoid "Cannot redefine plugin" errors.
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
    // Config files live outside src/ and aren't in tsconfig include, so
    // turn off the type-checked rules for them. Plain syntax checks still
    // apply.
    files: ["*.{js,mjs,cjs,ts,mts}", "*.config.{js,mjs,cjs,ts,mts}"],
    ...tseslint.configs.disableTypeChecked,
  },
]);
