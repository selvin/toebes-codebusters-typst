import { describe, expect, it } from "vitest";
import { prepareTable } from "../src/table.js";
import type { ToebesCipher } from "../src/toebes.js";

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const reversed = Object.fromEntries([...ALPHABET].map((c, i) => [c, ALPHABET[25 - i]]));

const cipher = (extra: Partial<ToebesCipher> = {}): ToebesCipher => ({
  cipherType: "atbash",
  cipherString: "Hello, zebra.",
  points: 100,
  operation: "decode",
  curlang: "en",
  replacement: reversed,
  ...extra,
});

describe("atbash", () => {
  it("encodes uppercase with the reversed alphabet, keeping spaces and punctuation", () => {
    expect(prepareTable(cipher())).toEqual({ kind: "atbash", ciphertext: "SVOOL, AVYIZ." });
  });

  it("leaves encode and other languages legacy", () => {
    expect(prepareTable(cipher({ operation: "encode" }))).toBeNull();
    expect(prepareTable(cipher({ curlang: "es" }))).toBeNull();
  });
});

describe("caesar", () => {
  // Decode table for offset 3: ciphertext D → plaintext A, so encoding shifts forward by 3
  const offset3 = Object.fromEntries([...ALPHABET].map((c, i) => [ALPHABET[(i + 3) % 26], c]));

  it("encodes with the rotated alphabet, wrapping past Z", () => {
    expect(prepareTable(cipher({ cipherType: "caesar", offset: 3, replacement: offset3 }))).toEqual({
      kind: "caesar",
      ciphertext: "KHOOR, CHEUD.",
    });
  });
});
