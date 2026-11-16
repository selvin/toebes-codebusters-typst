// Usage: tsx src/cli.ts <toebes-export.json> <questions.json> <answers.json>
// questions.json is the question paper's input; answers.json (every answer in plaintext) is the
// answer key's.

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { prepareAnswers } from "./answers.js";
import { prepareQuestions } from "./questions.js";

const [input, output, answersOutput] = process.argv.slice(2);
if (!input || !output || !answersOutput) {
  console.error("Usage: tsx src/cli.ts <toebes-export.json> <questions.json> <answers.json>");
  process.exit(2);
}

const exp = JSON.parse(readFileSync(input, "utf8"));
const result = prepareQuestions(exp);
mkdirSync(dirname(output), { recursive: true });
writeFileSync(output, JSON.stringify(result, null, 2) + "\n");
mkdirSync(dirname(answersOutput), { recursive: true });
writeFileSync(answersOutput, JSON.stringify(prepareAnswers(exp), null, 2) + "\n");

const kinds = new Map<string, number>();
for (const q of result.questions) kinds.set(q.kind, (kinds.get(q.kind) ?? 0) + 1);
console.log(`Wrote ${result.questions.length} questions to ${output}:`, Object.fromEntries(kinds));
console.log(`Wrote the answer key's input to ${answersOutput}`);
