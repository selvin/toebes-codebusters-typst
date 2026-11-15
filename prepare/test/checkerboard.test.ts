import { describe, expect, it } from "vitest";
import { checkerboardUnits, encodeCheckerboard, prepareCheckerboard } from "../src/checkerboard.js";
import type { ToebesCipher } from "../src/toebes.js";

// Square for KEY: K E Y A B / C D F G H / I L M N O / P Q R S T / U V W X Z
// Row keyword ABCDE, column keyword VWXYZ.
describe("checkerboard", () => {
  it("writes each letter as row keyword letter then column keyword letter", () => {
    const units = checkerboardUnits("KEY", "ABCDE", "VWXYZ");
    expect(units.get("K")).toBe("AV");
    expect(units.get("A")).toBe("AY");
    expect(units.get("C")).toBe("BV");
    expect(units.get("T")).toBe("DZ");
    expect(units.get("Z")).toBe("EZ");
    expect(units.get("J")).toBe(units.get("I"));
  });

  it("keeps words and punctuation when blocksize is 0", () => {
    expect(encodeCheckerboard("Hi, ab.", "KEY", "ABCDE", "VWXYZ", 0)).toEqual([
      [["BZ", "CV", ","], ["AY", "AZ", "."]],
    ]);
  });

  it("keeps letters only, in blocks, when blocksize is set", () => {
    expect(encodeCheckerboard("Hi, ab.", "KEY", "ABCDE", "VWXYZ", 2)).toEqual([[["BZ", "CV"], ["AY", "AZ"]]]);
  });

  it("breaks the first three lines at 13 tokens and later ones at 24, at the last space", () => {
    const lines = encodeCheckerboard("A".repeat(60), "KEY", "ABCDE", "VWXYZ", 5);
    expect(lines.map((l) => l.length)).toEqual([2, 2, 2, 4, 2]);
    expect(lines.flat(2)).toHaveLength(60);
  });

  it("breaks mid-word when a line has no space", () => {
    const lines = encodeCheckerboard("A".repeat(14), "KEY", "ABCDE", "VWXYZ", 0);
    expect(lines.map((l) => l.flat().length)).toEqual([13, 1]);
  });

  it("prepares the cipher units and nothing else, for decode and crypt", () => {
    const cipher: ToebesCipher = {
      cipherType: "checkerboard",
      cipherString: "Hi, ab.",
      points: 100,
      operation: "decode",
      blocksize: 2,
      keyword: "abcde",
      keyword2: "VWXYZ",
      polybiusKey: "Key",
    };
    const expected = { kind: "checkerboard", lines: [[["BZ", "CV"], ["AY", "AZ"]]] };
    expect(prepareCheckerboard(cipher)).toEqual(expected);
    expect(prepareCheckerboard({ ...cipher, operation: "crypt" })).toEqual(expected);
    expect(prepareCheckerboard({ ...cipher, operation: "encode" })).toBeNull();
    expect(prepareCheckerboard({ ...cipher, keyword2: "VWXY" })).toBeNull();
  });
});
