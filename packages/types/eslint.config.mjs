import bagourBase from "@bagour/config-eslint/base.mjs";
import bagourImports from "@bagour/config-eslint/imports.mjs";

export default [
  ...bagourBase,
  ...bagourImports,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
];
