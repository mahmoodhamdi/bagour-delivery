import { describe, expect, it } from "vitest";

import { __test__ } from "./status-timeline";

describe("status timeline ORDER", () => {
  it("preserves linear progression through stages", () => {
    const { ORDER } = __test__;
    expect(ORDER.pending).toBeLessThan(ORDER.confirmed);
    expect(ORDER.confirmed).toBeLessThan(ORDER.preparing);
    expect(ORDER.preparing).toBeLessThan(ORDER.ready);
    expect(ORDER.ready).toBeLessThan(ORDER.picked_up);
    expect(ORDER.picked_up).toBeLessThan(ORDER.on_the_way);
    expect(ORDER.on_the_way).toBeLessThan(ORDER.delivered);
  });

  it("cancelled is at a separate path", () => {
    const { ORDER } = __test__;
    expect(ORDER.cancelled).toBeGreaterThan(ORDER.delivered);
  });

  it("exposes exactly 6 visible stages", () => {
    expect(__test__.STAGES).toHaveLength(6);
  });
});
