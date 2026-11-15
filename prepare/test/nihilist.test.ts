import { describe, expect, it } from "vitest";
import { encodeNihilistLines, polybiusValues, prepareNihilist } from "../src/nihilist.js";
import type { ToebesCipher } from "../src/toebes.js";

// Square for KEY: K E Y A B / C D F G H / I L M N O / P Q R S T / U V W X Z
describe("nihilist", () => {
  it("builds the Polybius square from the key, J merged into I", () => {
    const sq = polybiusValues("Key");
    expect(sq.get("K")).toBe(11);
    expect(sq.get("A")).toBe(14);
    expect(sq.get("C")).toBe(21);
    expect(sq.get("Z")).toBe(55);
    expect(sq.has("J")).toBe(false);
  });

  it("adds keyword values over letters only, keeping words and punctuation", () => {
    // Keyword CAB = 21 14 15. H 25+21, I 31+14, A 14+15, B 15+21
    expect(encodeNihilistLines("Hi, ab.", "KEY", "CAB", 0)).toEqual([[["46", "45", ","], ["29", "36", "."]]]);
  });

  it("encodes J as I", () => {
    expect(encodeNihilistLines("J", "KEY", "K", 0)).toEqual(encodeNihilistLines("I", "KEY", "K", 0));
  });

  it("prepares decode as lines of words, and nothing else", () => {
    const cipher: ToebesCipher = {
      cipherType: "nihilistsub",
      cipherString: "Hi, ab.",
      points: 100,
      operation: "decode",
      blocksize: 0,
      keyword: "CAB",
      polybiusKey: "KEY",
    };
    expect(prepareNihilist(cipher)).toEqual({ kind: "nihilist", lines: [[["46", "45", ","], ["29", "36", "."]]] });
    expect(prepareNihilist({ ...cipher, operation: "encode" })).toBeNull();
  });

  it("keeps letters only, in blocks, when blocksize is set", () => {
    expect(encodeNihilistLines("Hi, ab.", "KEY", "CAB", 2)).toEqual([[["46", "45"], ["29", "36"]]]);
  });

  it("breaks the first three lines at 13 tokens and later ones at 24, after the last space", () => {
    const lines = encodeNihilistLines("A".repeat(60), "KEY", "CAB", 4);
    expect(lines.map((l) => l.length)).toEqual([2, 2, 2, 4, 4, 1]);
    expect(lines.flat(2)).toHaveLength(60);
  });

  it("prepares crypt, and decode with blocks, as lines", () => {
    const cipher: ToebesCipher = {
      cipherType: "nihilistsub",
      cipherString: "Hi, ab.",
      points: 100,
      operation: "crypt",
      blocksize: 2,
      keyword: "CAB",
      polybiusKey: "KEY",
    };
    const expected = { kind: "nihilist", lines: [[["46", "45"], ["29", "36"]]] };
    expect(prepareNihilist(cipher)).toEqual(expected);
    expect(prepareNihilist({ ...cipher, operation: "decode" })).toEqual(expected);
  });
});
