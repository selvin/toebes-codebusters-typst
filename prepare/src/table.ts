// Atbash and caesar: Toebes's table encoder. Fixed substitutions, printed one letter per box.

import { encodeSubstitution } from "./aristocrat.js";
import type { ToebesCipher } from "./toebes.js";

export interface TableData {
  kind: "atbash";
  ciphertext: string; // uppercase, spaces and punctuation kept
}

// Returns null for what isn't handled yet (it then stays legacy): `encode` would print the
// plaintext for the student to encode, and only English has been checked.
export function prepareTable(cipher: ToebesCipher): TableData | null {
  if (cipher.cipherType !== "atbash") return null;
  if (cipher.operation !== "decode" || (cipher.curlang ?? "en") !== "en") return null;
  if (!cipher.replacement) return null;
  // `replacement` is the decode table, as for aristocrats; it already holds the reversed alphabet.
  return { kind: cipher.cipherType, ciphertext: encodeSubstitution(cipher.cipherString, cipher.replacement) };
}
