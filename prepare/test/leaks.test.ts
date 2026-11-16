import { describe, expect, it } from "vitest";
import { leaks } from "../src/leaks.js";

describe("leaks", () => {
  const plaintext = "Pack my box with five dozen liquor jugs.";

  it("finds a run across line breaks, case and punctuation", () => {
    expect(leaks(plaintext, "1. Solve this.\nWITH FIVE\ndozen, liquor! jugs", 15)).toBe(true);
  });

  it("ignores a run shorter than the minimum, like a crib", () => {
    expect(leaks(plaintext, "The crib is DOZEN LIQUOR.", 15)).toBe(false);
  });

  it("strips accents on both sides", () => {
    expect(leaks("El niño comió más", "EL NINO COMIO MAS", 10)).toBe(true);
  });

  it("is false for plaintext shorter than the minimum", () => {
    expect(leaks("Short", "SHORT", 15)).toBe(false);
  });
});
