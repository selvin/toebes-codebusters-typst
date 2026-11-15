// Builds questions.json: everything the question paper may show, and nothing it may not.

import { prepareAristocrat, type AristocratData } from "./aristocrat.js";
import { prepareBaconian, type BaconianData } from "./baconian.js";
import { prepareCheckerboard, type CheckerboardData } from "./checkerboard.js";
import { prepareCompColumnar, type CompColumnarData } from "./compcolumnar.js";
import { prepareFractionatedMorse, type FractionatedMorseData } from "./fractionatedmorse.js";
import { prepareHomophonic, type HomophonicData } from "./homophonic.js";
import { htmlToParagraphs, type Paragraph } from "./html.js";
import { prepareNihilist, type NihilistData } from "./nihilist.js";
import { preparePorta, type PortaData } from "./porta.js";
import { prepareTable, type TableData } from "./table.js";
import type { ToebesCipher, ToebesExport } from "./toebes.js";

interface LegacyData {
  kind: "legacy";
}

type KindData =
  | AristocratData
  | BaconianData
  | CheckerboardData
  | CompColumnarData
  | FractionatedMorseData
  | HomophonicData
  | NihilistData
  | PortaData
  | TableData
  | LegacyData;

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

function prepareKind(cipher: ToebesCipher): KindData {
  if (cipher.cipherType === "aristocrat" || cipher.cipherType === "patristocrat") {
    const data = prepareAristocrat(cipher);
    if (data) return data;
  }
  if (cipher.cipherType === "baconian") {
    const data = prepareBaconian(cipher);
    if (data) return data;
  }
  if (cipher.cipherType === "checkerboard") {
    const data = prepareCheckerboard(cipher);
    if (data) return data;
  }
  if (cipher.cipherType === "compcolumnar") {
    const data = prepareCompColumnar(cipher);
    if (data) return data;
  }
  if (cipher.cipherType === "fractionatedmorse") {
    const data = prepareFractionatedMorse(cipher);
    if (data) return data;
  }
  if (cipher.cipherType === "homophonic") {
    const data = prepareHomophonic(cipher);
    if (data) return data;
  }
  if (cipher.cipherType === "nihilistsub") {
    const data = prepareNihilist(cipher);
    if (data) return data;
  }
  if (cipher.cipherType === "porta") {
    const data = preparePorta(cipher);
    if (data) return data;
  }
  if (cipher.cipherType === "atbash" || cipher.cipherType === "caesar") {
    const data = prepareTable(cipher);
    if (data) return data;
  }
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
