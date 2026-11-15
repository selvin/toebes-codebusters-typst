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

const { questions }: QuestionsFile = JSON.parse(readFileSync(questionsPath, "utf8"));
const referenceText = readFileSync(referencePath, "utf8");
const reference = collapse(referenceText);
const referenceLetters = lettersOnly(referenceText);
const referenceNumbers = numbersOnly(referenceText);

function matches(q: QuestionsFile["questions"][number]): boolean | null {
  if ("ciphertext" in q) {
    return (
      reference.includes(collapse(q.ciphertext)) ||
      referenceLetters.includes(lettersOnly(q.ciphertext))
    );
  }
  if ("words" in q) return referenceNumbers.includes(numbersOnly(q.words.flat().join(" ")));
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
