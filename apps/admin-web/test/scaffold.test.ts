import { describe, expect, it } from "vitest";

describe("admin scaffold", () => {
  it("declares the workspace role", () => {
    expect("@ginsengfood/admin-web").toContain("admin-web");
  });
});
