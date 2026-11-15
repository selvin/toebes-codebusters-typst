import { describe, expect, it } from "vitest";
import { encodeNihilist, polybiusValues, prepareNihilist } from "../src/nihilist.js";
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
    expect(encodeNihilist("Hi, ab.", "KEY", "CAB")).toEqual([["46", "45", ","], ["29", "36", "."]]);
  });

  it("encodes J as I", () => {
    expect(encodeNihilist("J", "KEY", "K")).toEqual(encodeNihilist("I", "KEY", "K"));
  });

  it("prepares decode with word breaks and nothing else", () => {
    const cipher: ToebesCipher = {
      cipherType: "nihilistsub",
      cipherString: "Hi, ab.",
      points: 100,
      operation: "decode",
      blocksize: 0,
      keyword: "CAB",
      polybiusKey: "KEY",
    };
    expect(prepareNihilist(cipher)).toEqual({ kind: "nihilist", words: [["46", "45", ","], ["29", "36", "."]] });
    expect(prepareNihilist({ ...cipher, operation: "crypt" })).toBeNull();
    expect(prepareNihilist({ ...cipher, blocksize: 4 })).toBeNull();
  });
});
