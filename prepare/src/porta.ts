// Porta: a reciprocal polyalphabetic cipher. The paper shows letters only, in fixed-size blocks.

import type { ToebesCipher } from "./toebes.js";

export interface PortaData {
  kind: "porta";
  ciphertext: string; // uppercase letters, blocks joined by one space
}

const A = "A".charCodeAt(0);

// Standard Porta tableau: key letters pair up (AB → 0 … YZ → 12). A–M map into N–Z and back.
export function encodePorta(plaintext: string, keyword: string): string {
  const shifts = [...keyword.toUpperCase()].map((k) => Math.floor((k.charCodeAt(0) - A) / 2));
  const letters = [...plaintext.toUpperCase()].filter((ch) => ch >= "A" && ch <= "Z");
  return letters
    .map((ch, i) => {
      const p = ch.charCodeAt(0) - A;
      const s = shifts[i % shifts.length];
      const c = p < 13 ? 13 + ((p + s) % 13) : (((p - 13 - s) % 13) + 13) % 13;
      return String.fromCharCode(A + c);
    })
    .join("");
}

export function toBlocks(letters: string, size: number): string {
  const blocks: string[] = [];
  for (let i = 0; i < letters.length; i += size) blocks.push(letters.slice(i, i + size));
  return blocks.join(" ");
}

export function preparePorta(cipher: ToebesCipher): PortaData | null {
  if (!cipher.keyword || !cipher.blocksize) return null;
  return {
    kind: "porta",
    ciphertext: toBlocks(encodePorta(cipher.cipherString, cipher.keyword), cipher.blocksize),
  };
}
