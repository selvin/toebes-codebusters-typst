// Baconian: each plaintext letter becomes five A/B bits, shown as cipher words (words mode) or as
// symbols from two sets (sequence, let4let). Follows Toebes's cipherbaconianencoder.ts.

import { decodeEntities } from "./html.js";
import type { ToebesCipher } from "./toebes.js";

export type BaconianData =
  | { kind: "baconian"; mode: "words"; lines: string[] }
  | { kind: "baconian"; mode: "symbols"; lines: string[][] };

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
// Toebes's maxEncodeWidth: words-mode lines wrap before this many characters.
const WORDS_LINE_WIDTH = 53;

// The 24-letter Bacon table: I = J and U = V share a code.
export function baconCode(letter: string): string {
  const index = "ABCDEFGHIKLMNOPQRSTUWXYZ".indexOf(letter === "J" ? "I" : letter === "V" ? "U" : letter);
  return index.toString(2).padStart(5, "0").replace(/0/g, "A").replace(/1/g, "B");
}

const plaintextLetters = (s: string) => [...s.toUpperCase()].filter((ch) => ALPHABET.includes(ch));

// Words mode: one export word per plaintext letter; a word's trailing punctuation goes before the
// next word, and "." alone starts a new line.
export function encodeBaconianWords(plaintext: string, words: string[], abMapping: string): string[] {
  const ab = (word: string) =>
    [...word].map((ch) => abMapping[ALPHABET.indexOf(ch)] ?? "").join("");
  const lines: string[] = [];
  let line = "";
  let prefix = "";
  plaintextLetters(plaintext).forEach((letter, i) => {
    let word = (words[i] ?? "").replace(/ /g, " ");
    let punctuation = word.slice(-1);
    if (ALPHABET.includes(punctuation.toUpperCase())) punctuation = "";
    else word = word.slice(0, -1);
    if (ab(word) !== baconCode(letter)) {
      throw new Error(`Baconian word ${i + 1} doesn't match its letter's code (check abMapping and words)`);
    }
    if (prefix === "." || line.length + word.length + prefix.length > WORDS_LINE_WIDTH) {
      lines.push((line + prefix).trimEnd());
      line = word;
    } else {
      line += prefix + word;
    }
    prefix = punctuation === "." || punctuation === "-" ? punctuation : punctuation + " ";
  });
  if (line !== "") lines.push(line + prefix.trimEnd());
  return lines;
}

// An A/B set's HTML → its symbols: graphemes (combining marks stay on their letter), whitespace
// collapsed, and a space kept with the symbol before it.
export function symbolSet(html: string): string[] {
  if (/<(?!\/?(p|br)\b)[a-z]/i.test(html)) {
    throw new Error("Baconian A/B sets with formatting aren't supported yet");
  }
  const text = decodeEntities(html.replace(/<[^>]*>/g, "")).replace(/\s+/g, " ");
  const symbols: string[] = [];
  for (const { segment } of new Intl.Segmenter(undefined, { granularity: "grapheme" }).segment(text)) {
    if (segment === " " && symbols.length > 0) symbols[symbols.length - 1] += segment;
    else symbols.push(segment);
  }
  return symbols.length > 0 ? symbols : [" "];
}

// Sequence: one position shared by both sets. Let4let: each set keeps its own position.
export function encodeBaconianSymbols(
  plaintext: string,
  aSet: string[],
  bSet: string[],
  shared: boolean,
): string[] {
  const pos = { A: 0, B: 0 };
  let sharedPos = 0;
  const out: string[] = [];
  for (const letter of plaintextLetters(plaintext)) {
    for (const bit of baconCode(letter) as Iterable<"A" | "B">) {
      const set = bit === "A" ? aSet : bSet;
      let p = shared ? sharedPos : pos[bit];
      if (p >= set.length) p = 0;
      out.push(set[p]);
      if (shared) sharedPos = p + 1;
      else pos[bit] = p + 1;
    }
  }
  return out;
}

export function prepareBaconian(cipher: ToebesCipher): BaconianData | null {
  const { operation, cipherString } = cipher;
  if (operation === "words") {
    if (!cipher.words || !cipher.abMapping) return null;
    return { kind: "baconian", mode: "words", lines: encodeBaconianWords(cipherString, cipher.words, cipher.abMapping) };
  }
  if (operation === "sequence" || operation === "let4let") {
    const width = Number(cipher.linewidth);
    if (cipher.texta === undefined || cipher.textb === undefined || !(width > 0)) return null;
    const symbols = encodeBaconianSymbols(
      cipherString,
      symbolSet(cipher.texta),
      symbolSet(cipher.textb),
      operation === "sequence",
    );
    const lines: string[][] = [];
    for (let i = 0; i < symbols.length; i += width) lines.push(symbols.slice(i, i + width));
    return { kind: "baconian", mode: "symbols", lines };
  }
  return null;
}
