// Fractionated morse: the plaintext in morse, cut into triples, each triple a keyword-alphabet
// letter. Follows Toebes's CipherFractionatedMorseEncoder.makeReplacement.

import type { ToebesCipher } from "./toebes.js";

export interface FractionatedMorseData {
  kind: "fractionatedmorse";
  lines: string[][]; // lines → cipher letters
}

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const MAX_ENCODE_WIDTH = 53; // Toebes's maxEncodeWidth

// O dot, - dash.
const MORSE: Record<string, string> = {
  A: "O-", B: "-OOO", C: "-O-O", D: "-OO", E: "O", F: "OO-O", G: "--O", H: "OOOO", I: "OO",
  J: "O---", K: "-O-", L: "O-OO", M: "--", N: "-O", O: "---", P: "O--O", Q: "--O-", R: "O-O",
  S: "OOO", T: "-", U: "OO-", V: "OOO-", W: "O--", X: "-OO-", Y: "-O--", Z: "--OO",
};

// Toebes's fixed triple order (morseReplaces); the paper prints it under the cipher letters.
export const FRACTIONS = [
  "OOO", "OO-", "OOX", "O-O", "O--", "O-X", "OXO", "OX-", "OXX", "-OO", "-O-", "-OX", "--O",
  "---", "--X", "-XO", "-X-", "-XX", "XOO", "XO-", "XOX", "X-O", "X--", "X-X", "XXO", "XX-",
];

// Toebes's genKstring with offset 0: keyword letters, duplicates dropped, then the rest of A–Z.
export function keywordAlphabet(keyword: string): string {
  let unassigned = ALPHABET;
  let repl = "";
  for (const ch of keyword.toUpperCase()) {
    if (!unassigned.includes(ch)) continue;
    repl += ch;
    unassigned = unassigned.replace(ch, "");
  }
  return repl + unassigned;
}

// A port of makeReplacement's cipher line only. Each cipher letter is " c " in the line string;
// after each letter the padded last triple is dropped and redone with the next letter's morse.
// Lines break at the last word break once the line string reaches 53, and like Toebes the
// last-split marker isn't reset after a split.
export function encodeFractionatedMorse(plaintext: string, keyword: string): string[][] {
  const alphabet = keywordAlphabet(keyword);
  const result: string[] = [];
  let encodeline = "";
  let lastsplit = -1;
  let partialMorse = "";
  let stashedMorse = "";
  let extraFraction = "";
  let spaceextra = "";
  let makeupMorse = 0;
  for (const t of plaintext.toUpperCase()) {
    if (/[0-9]/.test(t)) throw new Error("fractionatedmorse: digits not handled");
    if (!ALPHABET.includes(t)) {
      extraFraction = spaceextra;
      lastsplit = encodeline.length;
    } else {
      if (makeupMorse > 0) encodeline = encodeline.substring(0, encodeline.length - 3);
      partialMorse += stashedMorse + extraFraction + MORSE[t];
      extraFraction = "X";
      stashedMorse = partialMorse.substring(3 * Math.floor(partialMorse.length / 3));
      makeupMorse = (3 - (partialMorse.length % 3)) % 3;
      partialMorse += "X".repeat(makeupMorse);
      for (; partialMorse.length > 2; partialMorse = partialMorse.substring(3)) {
        const y = FRACTIONS.indexOf(partialMorse.substring(0, 3));
        if (y < 0) throw new Error("fractionatedmorse: XXX triple (Toebes can't encode it)");
        encodeline += ` ${alphabet[y]} `;
      }
      spaceextra = "XX";
    }
    if (encodeline.length >= MAX_ENCODE_WIDTH) {
      const at = lastsplit === -1 ? encodeline.length : lastsplit;
      result.push(encodeline.substring(0, at));
      encodeline = encodeline.substring(at);
    }
  }
  if (encodeline.length > 0) result.push(encodeline);
  return result.map((line) => line.replace(/ /g, "").split("")).filter((l) => l.length > 0);
}

export function prepareFractionatedMorse(cipher: ToebesCipher): FractionatedMorseData | null {
  if (!cipher.keyword) return null;
  return { kind: "fractionatedmorse", lines: encodeFractionatedMorse(cipher.cipherString, cipher.keyword) };
}
