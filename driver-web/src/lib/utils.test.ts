import { describe, expect, it } from "vitest";

import { cn } from "./utils";

describe("cn()", () => {
  it("merges class names", () => {
    expect(cn("a", "b")).toBe("a b");
  });

  it("resolves Tailwind conflicts (last wins)", () => {
    expect(cn("p-2", "p-4")).toBe("p-4");
  });

  it("ignores falsy entries", () => {
    const skip = false as boolean;
    expect(cn("a", skip && "b", null, undefined, "c")).toBe("a c");
  });
});
