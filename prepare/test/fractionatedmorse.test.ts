import { describe, expect, it } from "vitest";
import { encodeFractionatedMorse, keywordAlphabet, prepareFractionatedMorse } from "../src/fractionatedmorse.js";
import type { ToebesCipher } from "../src/toebes.js";

// With no keyword the alphabet is A–Z, so triple number n (Toebes's order) encodes as letter n.
describe("fractionated morse", () => {
  it("builds the keyword alphabet: keyword letters once, then the rest", () => {
    expect(keywordAlphabet("zebra")).toBe("ZEBRACDFGHIJKLMNOPQSTUVWXY");
    expect(keywordAlphabet("BOOK")).toBe("BOKACDEFGHIJLMNPQRSTUVWXYZ");
  });

  it("separates letters with X and pads to a triple", () => {
    // A T: O- X - XX → O-X (5, F), -XX (17, R)
    expect(encodeFractionatedMorse("AT", "")).toEqual([["F", "R"]]);
  });

  it("separates words with XX, whatever the punctuation", () => {
    // O- XX - X → O-X, X-X (23, X)
    expect(encodeFractionatedMorse("A T", "")).toEqual([["F", "X"]]);
    expect(encodeFractionatedMorse("A, T", "")).toEqual([["F", "X"]]);
  });

  it("ignores punctuation before the first letter", () => {
    expect(encodeFractionatedMorse(", A", "")).toEqual([["F"]]);
  });

  it("maps triples through the keyword alphabet", () => {
    // E: O XX → OXX (8)
    expect(encodeFractionatedMorse("E", "zebra")).toEqual([["G"]]);
  });

  it("breaks lines at the last word break once the line holds 18 letters", () => {
    const quote = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG AND KEEPS ON RUNNING FAR AWAY";
    const lines = encodeFractionatedMorse(quote, "");
    expect(lines.length).toBeGreaterThan(1);
    for (const line of lines) expect(line.length).toBeLessThanOrEqual(18);
  });

  it("repeats the padded letter when a word outruns the line, as Toebes does", () => {
    // 60 E: 119 morse characters, 40 triples; each of the two splits adds one.
    expect(encodeFractionatedMorse("E".repeat(60), "").map((l) => l.length)).toEqual([18, 18, 6]);
  });

  it("fails on digits", () => {
    expect(() => encodeFractionatedMorse("A1", "")).toThrow();
  });

  it("prepares the cipher letters, nothing else", () => {
    const cipher: ToebesCipher = {
      cipherType: "fractionatedmorse",
      cipherString: "At",
      points: 100,
      operation: "crypt",
      keyword: "zebra",
    };
    expect(prepareFractionatedMorse(cipher)).toEqual({ kind: "fractionatedmorse", lines: [["C", "P"]] });
    expect(prepareFractionatedMorse({ ...cipher, keyword: "" })).toBeNull();
  });
});
