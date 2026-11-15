// Aristocrat: monoalphabetic substitution with spaces and punctuation kept.
// Patristocrat: the same, on the letters only, in blocks of five.
// Xenocrypt: an aristocrat in Spanish, over a 27-letter alphabet with Ñ; accents fold away first.

import { chunk } from "./chunk.js";
import type { ToebesCipher } from "./toebes.js";

export interface AristocratData {
  kind: "aristocrat" | "patristocrat";
  keyType: "random" | "k1";
  alphabet: string;
  ciphertext: string;
  frequencies: number[];
}

// Toebes's `replacement` is the decode table: ciphertext letter → plaintext letter (the row a
// student fills in). Encoding goes the other way.
export function encodeSubstitution(
  plaintext: string,
  replacement: Record<string, string>,
  fold: Record<string, string> = {},
): string {
  const encode = new Map(Object.entries(replacement).map(([cipher, plain]) => [plain, cipher]));
  return [...plaintext.toUpperCase()].map((ch) => fold[ch] ?? ch).map((ch) => encode.get(ch) ?? ch).join("");
}

// Toebes's `langreplace`: accented letters that encode as their plain letter. Ñ is a letter of
// its own in the Spanish alphabet, so it isn't folded. Languages not here stay legacy.
const LANGUAGE_FOLDS: Record<string, Record<string, string>> = {
  en: {},
  es: { Á: "A", É: "E", Í: "I", Ó: "O", Ú: "U", Ü: "U", Ý: "Y" },
};

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
  const fold = LANGUAGE_FOLDS[cipher.curlang ?? "en"];
  if (!fold) return null;
  // chunk keeps A–Z only, so it would drop accented letters and Ñ: no Spanish patristocrat yet.
  if (cipher.cipherType === "patristocrat" && cipher.curlang && cipher.curlang !== "en") return null;
  if (!cipher.replacement || !cipher.alphabetSource) return null;

  const plaintext = cipher.cipherType === "patristocrat" ? chunk(cipher.cipherString, 5) : cipher.cipherString;
  const ciphertext = encodeSubstitution(plaintext, cipher.replacement, fold);
  return {
    kind: cipher.cipherType === "patristocrat" ? "patristocrat" : "aristocrat",
    keyType,
    alphabet: cipher.alphabetSource,
    ciphertext,
    frequencies: letterFrequencies(ciphertext, cipher.alphabetSource),
  };
}
