// @ts-check
import importPlugin from "eslint-plugin-import";
import tseslint from "typescript-eslint";

/**
 * Opt-in import-order rules. Apply this on top of base.mjs in packages
 * that don't already pull `eslint-plugin-import` through another config
 * (e.g. eslint-config-next ships it for Next.js apps).
 */
export default tseslint.config({
  plugins: {
    import: importPlugin,
  },
  rules: {
    "import/order": [
      "error",
      {
        groups: [
          "builtin",
          "external",
          "internal",
          ["parent", "sibling", "index"],
          "object",
          "type",
        ],
        "newlines-between": "always",
        alphabetize: { order: "asc", caseInsensitive: true },
      },
    ],
    "import/no-duplicates": "error",
    "import/no-self-import": "error",
  },
});
