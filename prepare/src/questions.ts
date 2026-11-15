// Builds questions.json: everything the question paper may show, and nothing it may not.

import { htmlToParagraphs, type Paragraph } from "./html.js";
import type { ToebesCipher, ToebesExport } from "./toebes.js";

interface LegacyData {
  kind: "legacy";
}

type KindData = LegacyData;

export type Question = {
  number: number;
  timed: boolean;
  toebesId: number;
  points: number;
  specialBonus: boolean;
  text: Paragraph[];
} & KindData;

export interface QuestionsFile {
  test: { title: string; count: number };
  questions: Question[];
}

function prepareKind(_cipher: ToebesCipher): KindData {
  return { kind: "legacy" };
}

export function prepareQuestions(exp: ToebesExport): QuestionsFile {
  const test = exp["TEST.0"];
  const order: { id: number; timed: boolean }[] = [];
  if (test.timed >= 0) order.push({ id: test.timed, timed: true });
  for (const id of test.questions) order.push({ id, timed: false });

  const questions = order.map(({ id, timed }, i): Question => {
    const cipher = exp[`CIPHER.${id}`];
    if (!cipher) throw new Error(`Export has no CIPHER.${id}`);
    return {
      number: test.timed >= 0 ? i : i + 1,
      timed,
      toebesId: id,
      points: cipher.points,
      specialBonus: cipher.specialbonus ?? false,
      text: htmlToParagraphs(cipher.question ?? ""),
      ...prepareKind(cipher),
    };
  });

  return { test: { title: test.title, count: test.questions.length }, questions };
}
