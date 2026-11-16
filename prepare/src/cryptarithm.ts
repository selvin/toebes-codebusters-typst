// Cryptarithm: an addition in letters, each standing for a digit, which keys the values to decode.
// The paper shows the equation (not an answer), the values and a letter × digit work grid.
// Follows Toebes's ciphercryptarithmencoder.ts (buildSolver, getSolValues).

import type { ToebesCipher } from "./toebes.js";

export interface CryptarithmData {
  kind: "cryptarithm";
  operands: string[]; // top to bottom
  result: string;
  values: string[]; // digits to decode, one string per answer word
  letters: string[]; // work grid rows: the equation's letters, sorted
}

// Only addition (A+B=C, A+B+C=D); other forms stay legacy until a test has one.
const ADDITION = /^[A-Z]+(\+[A-Z]+)+=[A-Z]+$/;

export function prepareCryptarithm(cipher: ToebesCipher): CryptarithmData | null {
  const equation = cipher.cipherString.toUpperCase().replace(/\s+/g, "");
  const mapping = cipher.mapping;
  if (!ADDITION.test(equation) || !cipher.validmapping || !mapping || !cipher.soltext) return null;

  const [sum, result] = equation.split("=");
  const values: string[] = [];
  for (const word of cipher.soltext.toUpperCase().trim().split(/\s+/)) {
    const digits = [...word].map((ch) => mapping[ch]);
    // A letter missing from the key: Toebes prints it as is. Not handled until a test has one.
    if (digits.some((d) => d === undefined)) return null;
    values.push(digits.join(""));
  }

  return {
    kind: "cryptarithm",
    operands: sum.split("+"),
    result,
    values,
    letters: [...new Set(equation.replace(/[^A-Z]/g, ""))].sort(),
  };
}
