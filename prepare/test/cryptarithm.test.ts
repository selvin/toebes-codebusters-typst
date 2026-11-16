import { describe, expect, it } from "vitest";
import { prepareCryptarithm } from "../src/cryptarithm.js";
import type { ToebesCipher } from "../src/toebes.js";

// SEND + MORE = MONEY: S9 E5 N6 D7 M1 O0 R8 Y2
const cipher: ToebesCipher = {
  cipherType: "cryptarithm",
  cipherString: "SEND+MORE=MONEY",
  points: 100,
  soltext: "dome  nose ",
  mapping: { S: 9, E: 5, N: 6, D: 7, M: 1, O: 0, R: 8, Y: 2 },
  validmapping: true,
};

describe("cryptarithm", () => {
  it("prepares the equation, values and work grid letters, and nothing else", () => {
    expect(prepareCryptarithm(cipher)).toEqual({
      kind: "cryptarithm",
      operands: ["SEND", "MORE"],
      result: "MONEY",
      values: ["7015", "6095"],
      letters: ["D", "E", "M", "N", "O", "R", "S", "Y"],
    });
  });

  it("takes three operands and spaces in the equation", () => {
    expect(prepareCryptarithm({ ...cipher, cipherString: "SEND + MORE + MORE = MONEY" })?.operands)
      .toEqual(["SEND", "MORE", "MORE"]);
  });

  it("leaves other forms, invalid keys and unmapped answer letters legacy", () => {
    expect(prepareCryptarithm({ ...cipher, cipherString: "MONEY-MORE=SEND" })).toBeNull();
    expect(prepareCryptarithm({ ...cipher, validmapping: false })).toBeNull();
    expect(prepareCryptarithm({ ...cipher, soltext: "dome nosy x" })).toBeNull();
  });
});
