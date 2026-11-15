import { describe, expect, it } from "vitest";
import { columnOrder, encodeCompColumnar, prepareCompColumnar } from "../src/compcolumnar.js";
import type { ToebesCipher } from "../src/toebes.js";

describe("compcolumnar", () => {
  it("reads columns in sorted key order, ties left to right", () => {
    expect(columnOrder("312", 3)).toEqual([1, 2, 0]);
    expect(columnOrder("BAB", 3)).toEqual([1, 0, 2]);
  });

  it("pads a short key with ~ and cuts a long one", () => {
    expect(columnOrder("2", 3)).toEqual([0, 1, 2]);
    expect(columnOrder("4321", 3)).toEqual([2, 1, 0]);
  });

  it("pads the text with X and reads each column top to bottom", () => {
    // Rows: SEC / RET / MEE / TAT / NOO / NXX
    expect(encodeCompColumnar("Secret: meet at noon", "213", 3)).toBe("EEEAOXSRMTNNCTETOX");
  });

  it("prepares 5-letter blocks and nothing else", () => {
    const cipher: ToebesCipher = {
      cipherType: "compcolumnar",
      cipherString: "Secret: meet at noon",
      points: 100,
      operation: "decode",
      keyword: "213",
      columns: 3,
    };
    expect(prepareCompColumnar(cipher)).toEqual({ kind: "compcolumnar", ciphertext: "EEEAO XSRMT NNCTE TOX" });
  });
});
