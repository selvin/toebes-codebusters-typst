import { describe, expect, it } from "vitest";
import { encodeSubstitution, letterFrequencies, prepareAristocrat } from "../src/aristocrat.js";
import type { ToebesCipher } from "../src/toebes.js";

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
// Decode table shifting by one: ciphertext A → plaintext B … Z → A, so encoding shifts back
const shift1 = Object.fromEntries([...ALPHABET].map((c, i) => [c, ALPHABET[(i + 1) % 26]]));

const cipher = (extra: Partial<ToebesCipher> = {}): ToebesCipher => ({
  cipherType: "aristocrat",
  cipherString: "Hello, zebra!",
  points: 100,
  encodeType: "random",
  curlang: "en",
  alphabetSource: ALPHABET,
  replacement: shift1,
  ...extra,
});

describe("aristocrat", () => {
  it("encodes uppercase, keeping spaces and punctuation", () => {
    expect(encodeSubstitution("Hello, zebra!", shift1)).toBe("GDKKN, YDAQZ!");
  });

  it("counts letters per alphabet position", () => {
    const f = letterFrequencies("GDKKN, YDAQZ!", ALPHABET);
    expect(f[ALPHABET.indexOf("K")]).toBe(2);
    expect(f[ALPHABET.indexOf("D")]).toBe(2);
    expect(f[ALPHABET.indexOf("B")]).toBe(0);
    expect(f.reduce((a, b) => a + b)).toBe(10);
  });

  it("prepares random and K1, and leaves other variants alone", () => {
    expect(prepareAristocrat(cipher())?.ciphertext).toBe("GDKKN, YDAQZ!");
    expect(prepareAristocrat(cipher({ encodeType: "k1" }))?.keyType).toBe("k1");
    expect(prepareAristocrat(cipher({ encodeType: "k2" }))).toBeNull();
    expect(prepareAristocrat(cipher({ curlang: "es" }))).toBeNull();
  });

  it("encodes a patristocrat's letters only, in blocks of five", () => {
    expect(prepareAristocrat(cipher({ cipherType: "patristocrat" }))?.ciphertext).toBe("GDKKN YDAQZ");
    expect(prepareAristocrat(cipher({ cipherType: "patristocrat", cipherString: "Hello, zebras!" }))?.ciphertext).toBe(
      "GDKKN YDAQZ R",
    );
  });
});
