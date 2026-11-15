// Checks our ciphertext against Toebes's own PDF of the same test, by text.
// Usage: tsx src/check-reference.ts <questions.json> <reference.txt>
// where reference.txt is `pdftotext -layout <toebes.pdf>`. Prints only question numbers and
// pass/fail, never ciphertext, so its output is safe to paste anywhere.

import { readFileSync } from "node:fs";
import type { QuestionsFile } from "./questions.js";

const [questionsPath, referencePath] = process.argv.slice(2);
if (!questionsPath || !referencePath) {
  console.error("Usage: tsx src/check-reference.ts <questions.json> <reference.txt>");
  process.exit(2);
}

// pdftotext splits ciphertext lines with blank lines and table rows in between; collapsing all
// whitespace makes each question's ciphertext one contiguous run of words.
const collapse = (s: string) => s.replace(/\s+/g, " ").trim();
// Some kinds (porta) print one letter per box, which pdftotext spaces apart: compare letters only.
const lettersOnly = (s: string) => s.replace(/[^A-Z]/g, "");
// Nihilist numbers are all two digits or more; the grid headers (1–5) pdftotext interleaves are not.
const numbersOnly = (s: string) => (s.match(/\d{2,}/g) ?? []).join(" ");
// Homophonic values run 1–00, so single digits count; spaces at both ends keep whole numbers.
const allNumbers = (s: string) => ` ${(s.match(/\d+/g) ?? []).join(" ")} `;
// Baconian symbols: pdftotext may compose combining marks, and spaces between cells vary.
const symbolsOnly = (s: string) => s.normalize("NFC").replace(/\s+/g, "");

const { questions }: QuestionsFile = JSON.parse(readFileSync(questionsPath, "utf8"));
const referenceText = readFileSync(referencePath, "utf8");
const reference = collapse(referenceText);
const referenceLetters = lettersOnly(referenceText);
const referenceNumbers = numbersOnly(referenceText);
const referenceSymbols = symbolsOnly(referenceText);
const referenceAllNumbers = allNumbers(referenceText);

// null: nothing to compare (kind without ciphertext, or symbols Toebes printed as images).
function matches(q: QuestionsFile["questions"][number]): boolean | null {
  if ("ciphertext" in q) {
    return (
      reference.includes(collapse(q.ciphertext)) ||
      referenceLetters.includes(lettersOnly(q.ciphertext))
    );
  }
  if (q.kind === "checkerboard") return referenceLetters.includes(lettersOnly(q.lines.flat(2).join("")));
  if (q.kind === "homophonic") return referenceAllNumbers.includes(allNumbers(q.lines.flat(2).join(" ")));
  if (q.kind === "nihilist" && "lines" in q) return referenceNumbers.includes(numbersOnly(q.lines.flat(2).join(" ")));
  if ("words" in q) return referenceNumbers.includes(numbersOnly(q.words.flat().join(" ")));
  if (q.kind === "baconian" && q.mode === "words") return reference.includes(collapse(q.lines.join(" ")));
  if (q.kind === "baconian" && q.mode === "symbols") {
    const symbols = q.lines.flat().map(symbolsOnly);
    if (!symbols.some((s) => s !== "" && referenceSymbols.includes(s))) {
      console.log(`${q.number} (${q.kind}): symbols not in reference text (images?); check by eye`);
      return null;
    }
    return referenceSymbols.includes(symbols.join(""));
  }
  return null;
}

let failed = 0;
for (const q of questions) {
  const ok = matches(q);
  if (ok === null) continue;
  if (!ok) failed++;
  console.log(`${q.timed ? "Timed" : q.number} (${q.kind}): ${ok ? "ok" : "NOT FOUND in reference"}`);
}
console.log(failed === 0 ? "All checked questions match." : `${failed} question(s) differ.`);
process.exit(failed === 0 ? 0 : 1);
