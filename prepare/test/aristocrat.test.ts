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
    expect(prepareAristocrat(cipher({ curlang: "fr" }))).toBeNull();
    expect(prepareAristocrat(cipher({ cipherType: "patristocrat", curlang: "es" }))).toBeNull();
  });

  it("encodes a patristocrat's letters only, in blocks of five", () => {
    expect(prepareAristocrat(cipher({ cipherType: "patristocrat" }))?.ciphertext).toBe("GDKKN YDAQZ");
    expect(prepareAristocrat(cipher({ cipherType: "patristocrat", cipherString: "Hello, zebras!" }))?.ciphertext).toBe(
      "GDKKN YDAQZ R",
    );
  });

  it("encodes Spanish over 27 letters, folding accents but keeping Ñ", () => {
    const es = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ";
    const shiftEs = Object.fromEntries([...es].map((c, i) => [c, es[(i + 1) % 27]]));
    const q = prepareAristocrat(
      cipher({ curlang: "es", alphabetSource: es, replacement: shiftEs, cipherString: "¿Qué año? ¡Ningún!" }),
    );
    // É → E → D, Ñ → N, O → Ñ, Ú → U → T; ¿ and ¡ kept
    expect(q?.ciphertext).toBe("¿PTD ZNÑ? ¡MHMFTM!");
    expect(q?.alphabet).toBe(es);
    expect(q?.frequencies).toHaveLength(27);
    expect(q?.frequencies[es.indexOf("Ñ")]).toBe(1);
    expect(q?.frequencies[es.indexOf("M")]).toBe(3);
  });
});
