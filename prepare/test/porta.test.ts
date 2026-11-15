import { describe, expect, it } from "vitest";
import { encodePorta, preparePorta, toBlocks } from "../src/porta.js";
import type { ToebesCipher } from "../src/toebes.js";

describe("porta", () => {
  it("encodes with the standard tableau, over letters only", () => {
    // A (shift 0): H→U, T→G, E→R. Z (shift 12): I→U, H→T, R→F
    expect(encodePorta("Hi, there", "AZ")).toBe("UUGTRFR");
  });

  it("is reciprocal", () => {
    const ct = encodePorta("Pack my box with five dozen liquor jugs", "KEYWORD");
    expect(encodePorta(ct, "KEYWORD")).toBe("PACKMYBOXWITHFIVEDOZENLIQUORJUGS");
  });

  it("splits into blocks", () => {
    expect(toBlocks("UUGTRFR", 3)).toBe("UUG TRF R");
  });

  it("prepares ciphertext blocks and nothing else", () => {
    const cipher: ToebesCipher = {
      cipherType: "porta",
      cipherString: "Hi, there",
      points: 100,
      keyword: "AZ",
      blocksize: 3,
    };
    expect(preparePorta(cipher)).toEqual({ kind: "porta", ciphertext: "UUG TRF R" });
  });
});
