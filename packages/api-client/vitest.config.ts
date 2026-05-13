import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "@bagour/api-client",
    environment: "node",
    include: ["src/**/*.test.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov"],
      include: ["src/**/*.ts"],
      exclude: ["src/**/*.test.ts", "src/test/**", "src/**/*.d.ts"],
    },
  },
});
