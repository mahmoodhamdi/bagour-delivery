# @bagour/config-eslint

Shared ESLint flat configurations (ESLint 9+) for the Bagour Delivery web apps and shared packages.

## Available configs

| Export                            | Use for                                        |
| --------------------------------- | ---------------------------------------------- |
| `@bagour/config-eslint/base.mjs`  | Pure TypeScript libraries (no React).          |
| `@bagour/config-eslint/react.mjs` | React component libraries (e.g. `@bagour/ui`). |
| `@bagour/config-eslint/next.mjs`  | Next.js apps (`customer-web`, `driver-web`).   |

## Usage in a Next.js app

```js
// eslint.config.mjs
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";
import bagourNext from "@bagour/config-eslint/next.mjs";

export default [
  ...nextVitals,
  ...nextTs,
  ...bagourNext,
  {
    rules: {
      // app-specific overrides here
    },
  },
];
```

## Design notes

- Type-checked rules require a `tsconfig.json` accessible to ESLint via `parserOptions.projectService: true` (handled in `base.mjs`).
- We accept the small CI cost of type-checked linting because it catches real correctness bugs (no-floating-promises, no-misused-promises).
- Security plugin is included with sensible defaults (eval, unsafe-regex, etc.). The noisy `detect-object-injection` rule is disabled.
- Prettier compatibility is enabled by `eslint-config-prettier`. Run `prettier --write` for formatting; ESLint won't fight it.
