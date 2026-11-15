// Nihilist substitution: Polybius-square values of plaintext and keyword letters, added.

import type { ToebesCipher } from "./toebes.js";

export interface NihilistData {
  kind: "nihilist";
  words: string[][]; // words → tokens: a number, or a punctuation mark
}

// Polybius square as letter → row × 10 + column (1-based): key letters first, then the rest of
// the alphabet, with J merged into I.
export function polybiusValues(key: string): Map<string, number> {
  const letters = [...new Set([...`${key}ABCDEFGHIKLMNOPQRSTUVWXYZ`.toUpperCase().replace(/J/g, "I")])]
    .filter((ch) => ch >= "A" && ch <= "Z");
  return new Map(letters.map((ch, i) => [ch, (Math.floor(i / 5) + 1) * 10 + (i % 5) + 1]));
}

// Keeps word breaks and punctuation (Toebes's layout when blocksize is 0).
export function encodeNihilist(plaintext: string, polybiusKey: string, keyword: string): string[][] {
  const square = polybiusValues(polybiusKey);
  const value = (ch: string) => square.get(ch === "J" ? "I" : ch)!;
  const key = [...keyword.toUpperCase()].map(value);
  let k = 0;
  return plaintext
    .toUpperCase()
    .split(/\s+/)
    .filter((w) => w !== "")
    .map((word) =>
      [...word].map((ch) => (ch >= "A" && ch <= "Z" ? String(value(ch) + key[k++ % key.length]) : ch)),
    );
}

export function prepareNihilist(cipher: ToebesCipher): NihilistData | null {
  if (cipher.operation !== "decode" || cipher.blocksize !== 0) return null;
  if (!cipher.keyword || !cipher.polybiusKey) return null;
  return { kind: "nihilist", words: encodeNihilist(cipher.cipherString, cipher.polybiusKey, cipher.keyword) };
}
