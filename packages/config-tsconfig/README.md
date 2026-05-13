# @bagour/config-tsconfig

Shared TypeScript configurations used by the Bagour Delivery web apps and shared packages.

## Available configs

| File                 | Use for                                                |
| -------------------- | ------------------------------------------------------ |
| `base.json`          | Anything — sensible strict defaults.                   |
| `nextjs.json`        | Next.js apps (`customer-web`, `driver-web`).           |
| `node.json`          | Pure-Node libraries (CLI tools, server-side packages). |
| `react-library.json` | React component or hook libraries (e.g. `@bagour/ui`). |

## Usage

```jsonc
// tsconfig.json
{
  "extends": "@bagour/config-tsconfig/nextjs.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] },
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"],
}
```

## Design notes

- `strict: true` + `noUncheckedIndexedAccess: true` are non-negotiable for the web apps. They've already caught real bugs.
- `noImplicitOverride`, `noUnusedLocals`, `noUnusedParameters` are on to keep code clean. CI fails on violations.
- `verbatimModuleSyntax` is off so we don't force `import type` everywhere (annoying mid-refactor) — we lint for it instead via `@typescript-eslint/consistent-type-imports`.
