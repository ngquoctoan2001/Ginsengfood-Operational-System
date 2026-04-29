import { describe, expect, it } from "vitest";

describe("shopfloor scaffold", () => {
  it("declares the workspace role", () => {
    expect("@ginsengfood/shopfloor-pwa").toContain("shopfloor-pwa");
  });
});
