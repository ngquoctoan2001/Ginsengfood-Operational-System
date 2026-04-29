import { describe, expect, it } from "vitest";

describe("public trace scaffold", () => {
  it("declares the workspace role", () => {
    expect("@ginsengfood/public-trace").toContain("public-trace");
  });
});
