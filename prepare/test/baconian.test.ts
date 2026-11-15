import { describe, expect, it } from "vitest";
import {
  baconCode,
  encodeBaconianSymbols,
  encodeBaconianWords,
  prepareBaconian,
  symbolSet,
} from "../src/baconian.js";
import type { ToebesCipher } from "../src/toebes.js";

// Vowels are A, consonants B.
const VOWELS_A = [..."ABCDEFGHIJKLMNOPQRSTUVWXYZ"].map((ch) => ("AEIOU".includes(ch) ? "A" : "B")).join("");

describe("baconian", () => {
  it("uses the 24-letter table", () => {
    expect(baconCode("A")).toBe("AAAAA");
    expect(baconCode("J")).toBe(baconCode("I"));
    expect(baconCode("V")).toBe(baconCode("U"));
    expect(baconCode("Z")).toBe("BABBB");
  });

  it("lays out words with punctuation carried to the next word", () => {
    // H = AABBB, I = ABAAA
    expect(encodeBaconianWords("Hi", ["AIRST,", "ADIEU"], VOWELS_A)).toEqual(["AIRST, ADIEU"]);
  });

  it("starts a new line after a lone period, and prints non-breaking spaces as spaces", () => {
    expect(encodeBaconianWords("H.I", ["AI RST.", "ADIEU"], VOWELS_A)).toEqual(["AI RST.", "ADIEU"]);
  });

  it("wraps words lines before 53 characters", () => {
    const lines = encodeBaconianWords("HHHHHHHHHH", Array(10).fill("AIRST"), VOWELS_A);
    expect(lines.map((l) => l.length)).toEqual([53, 5]);
  });

  it("rejects a word that doesn't spell its letter", () => {
    expect(() => encodeBaconianWords("A", ["BBBBB"], VOWELS_A)).toThrow();
  });

  it("splits sets into graphemes, keeping combining marks and trailing spaces", () => {
    expect(symbolSet("<p>x̃y z</p>")).toEqual(["x̃", "y ", "z"]);
  });

  it("shares one position across both sets in sequence mode", () => {
    // B = AAAAB
    expect(encodeBaconianSymbols("B", ["a", "b", "c"], ["X", "Y", "Z"], true)).toEqual(["a", "b", "c", "a", "Y"]);
  });

  it("keeps a position per set in let4let mode", () => {
    // D = AAABB
    expect(encodeBaconianSymbols("D", ["a", "b"], ["X", "Y", "Z"], false)).toEqual(["a", "b", "a", "X", "Y"]);
  });

  it("prepares symbol lines and nothing else", () => {
    const cipher: ToebesCipher = {
      cipherType: "baconian",
      cipherString: "Bb",
      points: 100,
      operation: "let4let",
      texta: "<p>a</p>",
      textb: "<p>X</p>",
      linewidth: 4,
    };
    expect(prepareBaconian(cipher)).toEqual({
      kind: "baconian",
      mode: "symbols",
      lines: [["a", "a", "a", "a"], ["X", "a", "a", "a"], ["a", "X"]],
    });
  });
});
