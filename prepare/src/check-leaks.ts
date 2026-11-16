// Fails when our question paper prints plaintext from the export (the leak-check launch gate).
// Usage: tsx src/check-leaks.ts <toebes-export.json> <paper.txt>
// where paper.txt is `pdftotext <our.pdf>`. Prints only question numbers and kinds, never text, so
// its output is safe to paste anywhere.

import { readFileSync } from "node:fs";
import { leaks, MIN_LEAK_RUN } from "./leaks.js";
import type { ToebesExport } from "./toebes.js";

const [exportPath, paperPath] = process.argv.slice(2);
if (!exportPath || !paperPath) {
  console.error("Usage: tsx src/check-leaks.ts <toebes-export.json> <paper.txt>");
  process.exit(2);
}

const exported: ToebesExport = JSON.parse(readFileSync(exportPath, "utf8"));
const paper = readFileSync(paperPath, "utf8");
const test = exported["TEST.0"];
const ids = test.timed >= 0 ? [test.timed, ...test.questions] : test.questions;
const firstNumber = test.timed >= 0 ? 0 : 1;

let leaked = 0;
ids.forEach((id, i) => {
  const cipher = exported[`CIPHER.${id}`];
  // A cryptarithm's cipherString is its equation, which the paper prints.
  if (cipher.cipherType === "cryptarithm") return;
  if (leaks(cipher.cipherString, paper)) {
    leaked++;
    const number = firstNumber + i;
    console.log(`${number === 0 ? "Timed" : number} (${cipher.cipherType}): plaintext on the paper`);
  }
});
console.log(
  leaked === 0
    ? `Leak check: no plaintext run of ${MIN_LEAK_RUN}+ letters on the paper.`
    : `Leak check FAILED: ${leaked} question(s) print plaintext.`,
);
process.exit(leaked === 0 ? 0 : 1);
