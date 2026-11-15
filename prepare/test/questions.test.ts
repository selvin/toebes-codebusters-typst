import { describe, expect, it } from "vitest";
import { prepareQuestions } from "../src/questions.js";
import type { ToebesExport } from "../src/toebes.js";

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const shift1 = Object.fromEntries([...ALPHABET].map((c, i) => [c, ALPHABET[(i + 1) % 26]]));
const PLAINTEXT = "A made up quote for testing only";

const exp = {
  "TEST.0": { title: "Practice Test", timed: 7, count: 2, questions: [9, 3] },
  "CIPHER.3": { cipherType: "atbash", cipherString: "Another made up line", points: 30, question: "<p>Third</p>" },
  "CIPHER.7": {
    cipherType: "aristocrat",
    cipherString: PLAINTEXT,
    points: 100,
    question: "<p>Timed</p>",
    encodeType: "random",
    curlang: "en",
    alphabetSource: ALPHABET,
    replacement: shift1,
    keyword: "SECRET",
    hint: PLAINTEXT,
  },
  "CIPHER.9": { cipherType: "caesar", cipherString: "One more made up line", points: 50, specialbonus: true },
} as unknown as ToebesExport;

describe("prepareQuestions", () => {
  const result = prepareQuestions(exp);

  it("puts the timed question first as 0, then numbers in TEST.0 order", () => {
    expect(result.questions.map((q) => [q.number, q.toebesId, q.timed])).toEqual([
      [0, 7, true],
      [1, 9, false],
      [2, 3, false],
    ]);
    expect(result.test).toEqual({ title: "Practice Test", count: 2 });
  });

  it("carries points, bonus flag and kind", () => {
    expect(result.questions.map((q) => [q.points, q.specialBonus, q.kind])).toEqual([
      [100, false, "legacy"],
      [50, true, "legacy"],
      [30, false, "legacy"],
    ]);
  });

  it("numbers from 1 when there is no timed question", () => {
    const noTimed = { ...exp, "TEST.0": { ...exp["TEST.0"], timed: -1 } } as ToebesExport;
    expect(prepareQuestions(noTimed).questions.map((q) => q.number)).toEqual([1, 2]);
  });

  it("never writes plaintext, keys or answer fields", () => {
    const json = JSON.stringify(result);
    expect(json).not.toContain(PLAINTEXT.toUpperCase());
    expect(json).not.toContain(PLAINTEXT);
    expect(json).not.toContain("SECRET");
    for (const field of ["cipherString", "replacement", "alphabetDest", "keyword", "hint"]) {
      expect(json).not.toContain(`"${field}"`);
    }
  });
});
