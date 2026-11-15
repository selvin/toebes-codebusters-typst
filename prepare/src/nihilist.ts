// Nihilist substitution: Polybius-square values of plaintext and keyword letters, added.

import { chunk, toBlocks } from "./chunk.js";
import type { ToebesCipher } from "./toebes.js";

export type NihilistData =
  | { kind: "nihilist"; words: string[][] } // words → tokens: a number, or a punctuation mark
  | { kind: "nihilist"; lines: string[][][] }; // lines → blocks → tokens, as Toebes breaks them

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

// Toebes's buildNihilistSequenceSets (width 24, extra 11): the first three lines break at
// 13 tokens, later ones at 24, after the last non-letter when there is one. Spaces count as
// tokens. Like Toebes, the last-split marker isn't reset after a split at it.
function breakLines(text: string, encode: (ch: string) => string): string[][] {
  const lines: string[][] = [];
  let width = 24 - 11;
  let line: string[] = [];
  let lastSplit = -1;
  for (const raw of text) {
    const ch = raw.toUpperCase();
    if (!(ch >= "A" && ch <= "Z")) {
      line.push(ch);
      lastSplit = line.length;
      continue;
    }
    line.push(encode(ch));
    if (line.length < width) continue;
    if (lastSplit === -1) {
      lines.push(line);
      line = [];
    } else {
      lines.push(line.slice(0, lastSplit));
      line = line.slice(lastSplit);
    }
    if (lines.length === 3) width = 24;
  }
  if (line.length > 0) lines.push(line);
  return lines;
}

// Toebes's line layout: letters only in blocks of `blocksize` (0 keeps words and punctuation).
export function encodeNihilistLines(
  plaintext: string,
  polybiusKey: string,
  keyword: string,
  blocksize: number,
): string[][][] {
  const square = polybiusValues(polybiusKey);
  const value = (ch: string) => square.get(ch === "J" ? "I" : ch)!;
  const key = [...keyword.toUpperCase()].filter((ch) => ch >= "A" && ch <= "Z").map(value);
  let k = 0;
  const encode = (ch: string) => String(value(ch) + key[k++ % key.length]);
  return breakLines(chunk(plaintext, blocksize), encode).map(toBlocks).filter((l) => l.length > 0);
}

export function prepareNihilist(cipher: ToebesCipher): NihilistData | null {
  if (cipher.operation !== "decode" && cipher.operation !== "crypt") return null;
  if (!cipher.keyword || !cipher.polybiusKey) return null;
  const blocksize = cipher.blocksize ?? 0;
  if (cipher.operation === "decode" && blocksize === 0) {
    return { kind: "nihilist", words: encodeNihilist(cipher.cipherString, cipher.polybiusKey, cipher.keyword) };
  }
  return {
    kind: "nihilist",
    lines: encodeNihilistLines(cipher.cipherString, cipher.polybiusKey, cipher.keyword, blocksize),
  };
}
