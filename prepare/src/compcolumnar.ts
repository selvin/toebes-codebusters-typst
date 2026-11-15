// Complete columnar transposition: letters written in rows, read out column by column in key order.
// Follows Toebes's CompleteColumnarSolver.

import { toBlocks } from "./porta.js";
import type { ToebesCipher } from "./toebes.js";

export interface CompColumnarData {
  kind: "compcolumnar";
  ciphertext: string; // uppercase letters, blocks of 5 joined by one space
}

// Column indexes in reading order: the key (cut or padded with "~" to `columns`) sorted by code
// unit, ties left to right.
export function columnOrder(key: string, columns: number): number[] {
  const chars = [...key.replace(/\s/g, "").toUpperCase().padEnd(columns, "~").slice(0, columns)];
  return chars
    .map((ch, i) => ({ ch, i }))
    .sort((a, b) => (a.ch < b.ch ? -1 : a.ch > b.ch ? 1 : a.i - b.i))
    .map(({ i }) => i);
}

export function encodeCompColumnar(plaintext: string, key: string, columns: number): string {
  const letters = plaintext.toUpperCase().replace(/[^A-Z]/g, "");
  const padded = letters.padEnd(Math.ceil(letters.length / columns) * columns, "X");
  return columnOrder(key, columns)
    .map((col) => [...padded].filter((_, j) => j % columns === col).join(""))
    .join("");
}

export function prepareCompColumnar(cipher: ToebesCipher): CompColumnarData | null {
  if (cipher.operation !== "decode" || !cipher.columns || cipher.keyword === undefined) return null;
  return {
    kind: "compcolumnar",
    ciphertext: toBlocks(encodeCompColumnar(cipher.cipherString, cipher.keyword, cipher.columns), 5),
  };
}
