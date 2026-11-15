// Aristocrat: monoalphabetic substitution with spaces and punctuation kept.

import type { ToebesCipher } from "./toebes.js";

export interface AristocratData {
  kind: "aristocrat";
  keyType: "random" | "k1";
  alphabet: string;
  ciphertext: string;
  frequencies: number[];
}

// Toebes's `replacement` is the decode table: ciphertext letter → plaintext letter (the row a
// student fills in). Encoding goes the other way.
export function encodeSubstitution(plaintext: string, replacement: Record<string, string>): string {
  const encode = new Map(Object.entries(replacement).map(([cipher, plain]) => [plain, cipher]));
  return [...plaintext.toUpperCase()].map((ch) => encode.get(ch) ?? ch).join("");
}

export function letterFrequencies(ciphertext: string, alphabet: string): number[] {
  const letters = [...alphabet];
  const counts = letters.map(() => 0);
  for (const ch of ciphertext) {
    const i = letters.indexOf(ch);
    if (i >= 0) counts[i]++;
  }
  return counts;
}

// Returns null when this aristocrat isn't one Stage 1 handles (it then stays legacy).
export function prepareAristocrat(cipher: ToebesCipher): AristocratData | null {
  const keyType = cipher.encodeType;
  if (keyType !== "random" && keyType !== "k1") return null;
  if ((cipher.curlang ?? "en") !== "en") return null;
  if (!cipher.replacement || !cipher.alphabetSource) return null;

  const ciphertext = encodeSubstitution(cipher.cipherString, cipher.replacement);
  return {
    kind: "aristocrat",
    keyType,
    alphabet: cipher.alphabetSource,
    ciphertext,
    frequencies: letterFrequencies(ciphertext, cipher.alphabetSource),
  };
}
