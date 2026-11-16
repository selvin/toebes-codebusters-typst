import { describe, expect, it } from "vitest";
import { prepareAnswers } from "../src/answers.js";
import type { ToebesExport } from "../src/toebes.js";

const exp = {
  "TEST.0": { title: "Practice Test", testtype: "bregional", timed: 7, count: 2, questions: [9, 3] },
  "CIPHER.3": { cipherType: "cryptarithm", cipherString: "SEND+MORE=MONEY", soltext: "MY DEN", points: 30 },
  "CIPHER.7": { cipherType: "aristocrat", cipherString: "A made-up quote, año 2026!", points: 100 },
  "CIPHER.9": { cipherType: "caesar", cipherString: "One more line", points: 50, specialbonus: true },
} as unknown as ToebesExport;

describe("prepareAnswers", () => {
  const result = prepareAnswers(exp);

  it("numbers in paper order with the timed question as 0", () => {
    expect(result.answers.map((a) => [a.number, a.timed, a.kind])).toEqual([
      [0, true, "aristocrat"],
      [1, false, "caesar"],
      [2, false, "cryptarithm"],
    ]);
    expect(result.test).toEqual({ title: "Practice Test", division: "B" });
  });

  it("keeps the answer as written and counts its letters only, ñ as one", () => {
    expect(result.answers[0].answer).toBe("A made-up quote, año 2026!");
    expect(result.answers[0].letters).toBe(15);
  });

  it("takes a cryptarithm's answer from soltext", () => {
    expect(result.answers[2]).toMatchObject({ answer: "MY DEN", letters: 5 });
  });

  it("carries points and the bonus flag", () => {
    expect(result.answers.map((a) => [a.points, a.specialBonus])).toEqual([
      [100, false],
      [50, true],
      [30, false],
    ]);
  });

  it("allows no errors on cryptarithms in Division B only", () => {
    expect(result.answers.map((a) => a.zeroErrors)).toEqual([false, false, true]);
    const divC = { ...exp, "TEST.0": { ...exp["TEST.0"], testtype: "cregional" } } as ToebesExport;
    expect(prepareAnswers(divC).answers.some((a) => a.zeroErrors)).toBe(false);
  });
});
