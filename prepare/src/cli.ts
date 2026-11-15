// Usage: tsx src/cli.ts <toebes-export.json> <questions.json>

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { prepareQuestions } from "./questions.js";

const [input, output] = process.argv.slice(2);
if (!input || !output) {
  console.error("Usage: tsx src/cli.ts <toebes-export.json> <questions.json>");
  process.exit(2);
}

const result = prepareQuestions(JSON.parse(readFileSync(input, "utf8")));
mkdirSync(dirname(output), { recursive: true });
writeFileSync(output, JSON.stringify(result, null, 2) + "\n");

const kinds = new Map<string, number>();
for (const q of result.questions) kinds.set(q.kind, (kinds.get(q.kind) ?? 0) + 1);
console.log(`Wrote ${result.questions.length} questions to ${output}:`, Object.fromEntries(kinds));
