// The parts of a Toebes export that prepare reads. Exports carry many more fields; anything not
// listed here is ignored. `cipherString` is the plaintext, never the ciphertext.

export interface ToebesTest {
  title: string;
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
  blocksize?: number;
  polybiusKey?: string;
  operation?: string;
}

export interface ToebesExport {
  "TEST.0": ToebesTest;
  [key: `CIPHER.${number}`]: ToebesCipher;
}
