// Homophonic: each letter becomes one of four numbers, one per keyword letter's range of 25.
// Follows Toebes's CipherHomophonicEncoder.

import { chunk, toBlocks } from "./chunk.js";
import type { ToebesCipher } from "./toebes.js";

export interface HomophonicData {
  kind: "homophonic";
  header: "numbers" | "letters"; // help table header: 1–00 (decode) or the 25 letters (crypt)
  lines: string[][][]; // lines → blocks (words when blocksize is 0) → tokens: a value or punctuation
}

const CHARSET = "ABCDEFGHIKLMNOPQRSTUVWXYZ"; // no J: J encodes as I
const RANGES = 4;

// Value of letter `ch` in range `slot`: 1 + 25·slot + (pos(ch) − pos(keyword[slot])) mod 25.
// 100 prints as 00.
export function homophonicValue(keyword: string, ch: string, slot: number): string {
  const key = keyword.toUpperCase().replace(/[^A-Z]/g, "").padEnd(RANGES, "A").replace(/J/g, "I");
  const k = CHARSET.indexOf(key[slot]);
  const c = CHARSET.indexOf(ch.toUpperCase().replace("J", "I"));
  const value = 1 + slot * CHARSET.length + ((c - k + CHARSET.length) % CHARSET.length);
  return value === 100 ? "00" : String(value);
}

// Toebes's buildReplacementHomophonic (width 25): once a line reaches 25 tokens, it breaks after
// the last non-letter, or right there when there is none. Like Toebes, the last-split marker isn't
// reset after a split at it.
function breakLines(text: string, encode: (ch: string, index: number) => string): string[][] {
  const lines: string[][] = [];
  let line: string[] = [];
  let lastSplit = -1;
  let index = 0;
  for (const raw of text) {
    const ch = raw.toUpperCase();
    if (!CHARSET.includes(ch.replace("J", "I"))) {
      line.push(ch);
      lastSplit = line.length;
      continue;
    }
    line.push(encode(ch, index++));
    if (line.length < 25) continue;
    if (lastSplit === -1) {
      lines.push(line);
      line = [];
    } else {
      lines.push(line.slice(0, lastSplit));
      line = line.slice(lastSplit);
    }
  }
  if (line.length > 0) lines.push(line);
  return lines;
}

export function encodeHomophonic(plaintext: string, keyword: string, slots: number[], blocksize: number): string[][][] {
  const encode = (ch: string, i: number) => {
    const slot = slots[i];
    // Toebes picks at random when a slot is missing; we can't reproduce that.
    if (slot === undefined || slot < 0 || slot >= RANGES) throw new Error(`homophonic: no slot for letter ${i}`);
    return homophonicValue(keyword, ch, slot);
  };
  return breakLines(chunk(plaintext, blocksize), encode).map(toBlocks).filter((l) => l.length > 0);
}

export function prepareHomophonic(cipher: ToebesCipher): HomophonicData | null {
  if (cipher.operation !== "decode" && cipher.operation !== "crypt") return null;
  return {
    kind: "homophonic",
    header: cipher.operation === "decode" ? "numbers" : "letters",
    lines: encodeHomophonic(cipher.cipherString, cipher.keyword ?? "", cipher.randomSlot ?? [], cipher.blocksize ?? 0),
  };
}
