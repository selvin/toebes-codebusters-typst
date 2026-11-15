// Checkerboard: each letter becomes its Polybius square position, written as a row keyword letter
// and a column keyword letter. Follows Toebes's CipherCheckerboardEncoder.

import { chunk, toBlocks } from "./chunk.js";
import type { ToebesCipher } from "./toebes.js";

export interface CheckerboardData {
  kind: "checkerboard";
  lines: string[][][]; // lines → blocks (words when blocksize is 0) → tokens: a cipher unit or punctuation
}

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

// Letter → cipher unit. Square: key letters, then the alphabet, J merged into I, row by row.
export function checkerboardUnits(polybiusKey: string, rowKeyword: string, colKeyword: string): Map<string, string> {
  const letters = [...new Set(`${polybiusKey}${ALPHABET}`.toUpperCase().replace(/J/g, "I"))]
    .filter((ch) => ALPHABET.includes(ch));
  const units = new Map(letters.map((ch, i) => [ch, rowKeyword[Math.floor(i / 5)] + colKeyword[i % 5]]));
  units.set("J", units.get("I")!);
  return units;
}

// Toebes's buildCheckerboardSequenceSets (width 24, extra 11): the first three lines break at
// 13 tokens, later ones at 24, at the last space when there is one. Spaces count as tokens.
function breakLines(text: string, units: Map<string, string>): string[][] {
  const lines: string[][] = [];
  let width = 24 - 11;
  let line: string[] = [];
  let lastSplit = -1;
  for (const raw of text) {
    const ch = raw.toUpperCase();
    if (!ALPHABET.includes(ch)) {
      line.push(ch);
      if (ch.trim() === "") lastSplit = line.length;
      continue;
    }
    line.push(units.get(ch)!);
    if (line.length < width) continue;
    if (lastSplit === -1) {
      lines.push(line);
      line = [];
    } else {
      lines.push(line.slice(0, lastSplit));
      line = line.slice(lastSplit);
      lastSplit = -1;
    }
    if (lines.length === 3) width = 24;
  }
  if (line.length > 0) lines.push(line);
  return lines;
}

export function encodeCheckerboard(
  plaintext: string,
  polybiusKey: string,
  rowKeyword: string,
  colKeyword: string,
  blocksize: number,
): string[][][] {
  const units = checkerboardUnits(polybiusKey, rowKeyword, colKeyword);
  return breakLines(chunk(plaintext, blocksize), units).map(toBlocks).filter((l) => l.length > 0);
}

const lettersOf = (s: string | undefined) => (s ?? "").toUpperCase().replace(/[^A-Z]/g, "");

export function prepareCheckerboard(cipher: ToebesCipher): CheckerboardData | null {
  if (cipher.operation !== "decode" && cipher.operation !== "crypt") return null;
  const row = lettersOf(cipher.keyword);
  const col = lettersOf(cipher.keyword2);
  if (row.length !== 5 || col.length !== 5 || lettersOf(cipher.polybiusKey) === "") return null;
  return {
    kind: "checkerboard",
    lines: encodeCheckerboard(cipher.cipherString, lettersOf(cipher.polybiusKey), row, col, cipher.blocksize ?? 0),
  };
}
