// The parts of a Toebes export that prepare reads. Exports carry many more fields; anything not
// listed here is ignored. `cipherString` is the plaintext, never the ciphertext.

export interface ToebesTest {
  title: string;
  testtype?: string; // division then level, e.g. "cregional"
  timed: number; // CIPHER id, or -1 when there is no timed question
  count: number;
  questions: number[]; // CIPHER ids in paper order
}

export interface ToebesCipher {
  cipherType: string;
  cipherString: string;
  points: number;
  question?: string; // HTML
  specialbonus?: boolean;
  encodeType?: string;
  curlang?: string;
  alphabetSource?: string;
  replacement?: Record<string, string>;
  keyword?: string;
  keyword2?: string; // checkerboard: column keyword (keyword is the row keyword)
  blocksize?: number;
  polybiusKey?: string;
  operation?: string;
  offset?: number; // caesar shift (not read: `replacement` already holds it)
  words?: string[]; // baconian words mode: one cipher word per plaintext letter
  abMapping?: string; // baconian: alphabet position → A or B
  texta?: string; // baconian: A symbol set (HTML)
  textb?: string;
  linewidth?: number | string; // some exports store it as a string ("55")
  columns?: number; // compcolumnar
  randomSlot?: number[]; // homophonic: range (0–3) for each plaintext letter
}

export interface ToebesExport {
  "TEST.0": ToebesTest;
  [key: `CIPHER.${number}`]: ToebesCipher;
}
