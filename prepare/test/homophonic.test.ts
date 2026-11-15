import { describe, expect, it } from "vitest";
import { encodeHomophonic, homophonicValue, prepareHomophonic } from "../src/homophonic.js";
import type { ToebesCipher } from "../src/toebes.js";

// Keyword BIRD: ranges start at B (1), I (26), R (51), D (76).
describe("homophonic", () => {
  it("numbers each range from its keyword letter, skipping J", () => {
    expect(homophonicValue("BIRD", "B", 0)).toBe("1");
    expect(homophonicValue("BIRD", "A", 0)).toBe("25");
    expect(homophonicValue("BIRD", "K", 1)).toBe("27"); // I, K: no J between
    expect(homophonicValue("BIRD", "J", 1)).toBe("26");
    expect(homophonicValue("BIRD", "R", 2)).toBe("51");
    expect(homophonicValue("BIRD", "C", 3)).toBe("00"); // 100
  });

  it("pads a short keyword with A", () => {
    expect(homophonicValue("BI", "A", 3)).toBe("76");
  });

  it("takes each letter's range from its slot", () => {
    expect(encodeHomophonic("Bb, b.", "BIRD", [0, 1, 2], 0)).toEqual([[["1", "44", ","], ["61", "."]]]);
  });

  it("keeps letters only, in blocks, when blocksize is set", () => {
    expect(encodeHomophonic("Bb, b.", "BIRD", [0, 0, 0], 2)).toEqual([[["1", "1"], ["1"]]]);
  });

  it("breaks lines at 25 tokens after the last space: four blocks of five", () => {
    const lines = encodeHomophonic("B".repeat(45), "BIRD", Array(45).fill(0), 5);
    expect(lines.map((l) => l.length)).toEqual([4, 4, 1]);
    expect(lines.flat(2)).toHaveLength(45);
  });

  it("breaks mid-word when a line has no space", () => {
    const lines = encodeHomophonic("B".repeat(26), "BIRD", Array(26).fill(0), 0);
    expect(lines.map((l) => l.flat().length)).toEqual([25, 1]);
  });

  it("fails when a letter has no slot", () => {
    expect(() => encodeHomophonic("BB", "BIRD", [0], 0)).toThrow();
  });

  it("prepares values and the help table header, nothing else", () => {
    const cipher: ToebesCipher = {
      cipherType: "homophonic",
      cipherString: "Bb",
      points: 100,
      operation: "decode",
      blocksize: 5,
      keyword: "bird",
      randomSlot: [0, 3],
    };
    expect(prepareHomophonic(cipher)).toEqual({ kind: "homophonic", header: "numbers", lines: [[["1", "99"]]] });
    expect(prepareHomophonic({ ...cipher, operation: "crypt" })?.header).toBe("letters");
    expect(prepareHomophonic({ ...cipher, operation: "encode" })).toBeNull();
  });
});
