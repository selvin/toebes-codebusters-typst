// Builds answers.json: the answer key's only input. Holds every answer in plaintext, so the
// question paper is never given it.

import { lettersOnly } from "./leaks.js";
import { division, paperOrder } from "./questions.js";
import type { ToebesExport } from "./toebes.js";

// Kinds the rules allow no errors on, by division
const ZERO_ERRORS: Record<string, string[]> = { B: ["cryptarithm"] };

export interface Answer {
  number: number;
  timed: boolean;
  kind: string; // Toebes's cipherType
  points: number;
  specialBonus: boolean;
  zeroErrors: boolean;
  answer: string; // as written in the export (case and punctuation kept)
  letters: number; // letters only, an accented letter counting as one; a tiebreaker
}

export interface AnswersFile {
  test: { title: string; division: string };
  answers: Answer[];
}

export function prepareAnswers(exp: ToebesExport): AnswersFile {
  const test = exp["TEST.0"];
  const div = division(test.testtype);
  const answers = paperOrder(exp).map(({ number, timed, cipher }): Answer => {
    // A cryptarithm's cipherString is its equation; its answer is soltext
    const answer = cipher.cipherType === "cryptarithm" ? (cipher.soltext ?? "") : cipher.cipherString;
    return {
      number,
      timed,
      kind: cipher.cipherType,
      points: cipher.points,
      specialBonus: cipher.specialbonus ?? false,
      zeroErrors: ZERO_ERRORS[div]?.includes(cipher.cipherType) ?? false,
      answer,
      letters: lettersOnly(answer).length,
    };
  });
  return { test: { title: test.title, division: div }, answers };
}
