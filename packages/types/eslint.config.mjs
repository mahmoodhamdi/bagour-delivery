import bagourBase from "@bagour/config-eslint/base.mjs";

export default [
  ...bagourBase,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
];
