import { describe, expect, it } from "vitest";
import { htmlToParagraphs } from "../src/html.js";

const plain = (text: string) => ({ text, bold: false, italic: false, mono: false });

describe("htmlToParagraphs", () => {
  it("splits paragraphs and keeps styles", () => {
    const html =
      "<p>Solve <b>this</b> quote by <i>Nobody</i>.</p>" +
      "<p>It starts with <span style=\"font-family:'Courier New', Courier, monospace;\"><strong>THE</strong></span>&nbsp;now.</p>";
    expect(htmlToParagraphs(html)).toEqual([
      [plain("Solve "), { ...plain("this"), bold: true }, plain(" quote by "), { ...plain("Nobody"), italic: true }, plain(".")],
      [plain("It starts with "), { ...plain("THE"), bold: true, mono: true }, plain(" now.")],
    ]);
  });

  it("drops empty paragraphs and unknown tags, decodes entities", () => {
    expect(htmlToParagraphs("<p></p><p><u>A &amp; B</u></p>")).toEqual([[plain("A & B")]]);
  });
});
