# Competition-ready question paper by 2026-11-30

**Date:** 2026-11-14
**Status:** **Active.** Stage 0 (docs, decisions) and Stage 1 (pipeline, aristocrats) done
2026-11-14. Next: porta, then nihilistsub (see Decisions below).
**Deadline:** 2026-11-30.
**Related:** [2026-11-14-ts-prepare-typst-layout-split.md](2026-11-14-ts-prepare-typst-layout-split.md)

---

## Goal

From `competitiondata/001.json`, produce a question paper a proctor could hand out. "Competition-ready"
means every question shows the right ciphertext, numbering and points match Toebes's PDF, and
nothing in the packet gives away an answer.

**Scope is the cipher types in `competitiondata/001`**, not every Codebusters type. Other types come later,
each on its own.

**Not in scope:**
- The answer key: nice to have; Toebes's answer key is the fallback (graders only).
- The cover page and score table: last, and optional. Graders score on codebusters.site, not on
  paper.
- The website.

## The yardstick

In `competitiondata/` (gitignored; see `CLAUDE.md`, "Hard rule"):

- `001.json` — input.
- `001.pdf` — Toebes's question paper for it, printed from Chrome. No answer key.

Check ciphertext by text: `pdftotext -layout competitiondata/001.pdf` gives each question's ciphertext,
which tests can compare with ours. Check looks by eye.

## Assessment of the code as of 2026-11-14

Last worked on 2025-11-26 → 2025-12-15. It compiles against `competitiondata/001.json`, but:

- **Plaintext leaks:** aristocrat, patristocrat, xenocrypt, porta, nihilist, columnar, fractionated
  morse, baconian and cryptarithm all print `cipherString`, which is the plaintext. Only atbash and
  caesar encode.
- **Numbering:** headings show the Toebes id instead of the position in `TEST.0.questions`.
  `main.typ` treats `CIPHER.0` as the timed question, which only fits older exports.
- **Missing types:** checkerboard and homophonic fall through to the red "unknown" box.
- **Missing pieces:** page header (title, "Team Number"), cover page, answer key.
- **Fonts:** Courier New, which a browser build won't have.

What's worth keeping: the look of the dual-box layout (atbash, caesar), the aristocrat frequency
and replacement table, the half-page placement, the HTML-to-Typst handling.

## Cipher tracker

Types only; which question uses which stays out of the repo.

| Type (`cipherType`, variants) | Encodes today? | Status |
|---|---|---|
| aristocrat: random, K1, with hint | yes (TS) | done; matches reference |
| aristocrat, Spanish (xenocrypt) | no | todo |
| patristocrat, K1 | no | todo |
| atbash | yes | layout ok; move to TS |
| caesar | yes | layout ok; move to TS |
| porta: decode, crypt | no | todo |
| baconian: words, sequence, let4let | no | todo |
| nihilistsub: decode, crypt | no | todo |
| compcolumnar | no | todo |
| checkerboard: decode, crypt | missing | todo |
| cryptarithm | no | todo |
| homophonic: decode, crypt | missing | todo |
| fractionatedmorse | no | todo |

Update the Status column as each lands.

## Sequencing

Most uncertainty first.

1. **Stage 1 — prove the pipeline end to end.** `prepare/` (TS) reads the export and writes
   `questions.json` with correct ordering, numbering, points, bonus flags and question text. One
   cipher all the way through: aristocrat (the most common type, and the frequency table checks
   derived data). Typst reads `questions.json` instead of the raw export. Check against the
   reference by text.
2. **Stage 2 — the easy encoders.** Atbash, caesar, patristocrat, K1 and xenocrypt aristocrats.
   Settles the model's shape across a few kinds.
3. **Stage 3 — the hard encoders**, most uncertain first: homophonic, checkerboard, fractionated
   morse, nihilist, baconian (three modes), porta, complete columnar, cryptarithm.
4. **Stage 4 — page header** (title, "Team Number").
5. **If time allows:** answer key, then cover page.

Each stage is a few commits; each cipher type its own commit.

## Launch gates (by 11-30, off the critical path)

- No question prints plaintext: a test checks that the question paper's text contains no plaintext
  sentence from the export.
- Owner prints a packet and reviews it on paper.

## Stage 1 detail — 2026-11-14

### `questions.json` (the question paper's only input for migrated kinds)

```jsonc
{
  "test": { "title": "…", "count": 20 },      // count = untimed questions
  "questions": [
    {
      "number": 0,              // 0 = timed; then 1…n in TEST.0.questions order
      "timed": true,
      "toebesId": 1234,         // lets main.typ find legacy (not yet migrated) entries
      "points": 100,
      "specialBonus": false,
      "text": [[{ "text": "…", "bold": true, "italic": false, "mono": false }]],
                                // paragraphs → runs; HTML gone
      "kind": "aristocrat",     // picks the Typst renderer
      // kind data, aristocrat:
      "keyType": "random",      // "random" | "k1"
      "alphabet": "ABC…Z",
      "ciphertext": "…",        // uppercase, punctuation and spaces kept
      "frequencies": [3, 0, …]  // one per alphabet letter
    }
  ]
}
```

No `cipherString`, `replacement`, `alphabetDest`, `keyword`, `hint`, `author` field or
`translation`. Every kind not migrated yet is `"kind": "legacy"` with no kind data, and `main.typ`
renders it from the raw export by `toebesId` as before (still leaking, as today). Each later stage
turns legacy entries into real kinds; when none are left, `main.typ` stops reading the export.

Stage 1 migrates only English aristocrats with random or K1 keys. Xenocrypts (`curlang` ≠ `en`) stay
legacy until Stage 2, since their alphabet and accent handling need their own check.

The aristocrat ciphertext comes from the export's `replacement` map applied to the uppercased
`cipherString`; characters not in the map are kept as they are.

### `prepare/` layout and tooling

```
prepare/
  package.json        — tsx (run), vitest (tests), typescript (types only); no runtime deps
  src/toebes.ts       — types for the export fields we read
  src/html.ts         — question HTML → paragraphs of runs
  src/aristocrat.ts   — encode, frequencies
  src/questions.ts    — order, number, dispatch by cipherType
  src/cli.ts          — export path in, questions.json path out
  src/check-reference.ts — compares our ciphertext with `pdftotext -layout` of Toebes's PDF
  test/               — unit tests on made-up fixtures only
```

Output goes to `build/questions.json` (gitignored).

### Running it

```
./compile.sh competitiondata/001.json <out.pdf>
```

runs `prepare` then `typst compile --input export=… --input questions=…`. Check against the
reference with
`prepare/node_modules/.bin/tsx prepare/src/check-reference.ts build/questions.json <pdftotext output>`
from the repo root.

## Stage 1 results — 2026-11-14

Done. All English aristocrats in `competitiondata/001` match Toebes's PDF by text (ciphertext) and by
eye (frequency row).

Findings for later stages:

- **Toebes's `replacement` is the decode table** (ciphertext letter → plaintext letter), not the
  encode table. Encoding uses its inverse. The K1 keyword therefore shows up in `alphabetDest`.
  Expect the same convention in patristocrats and xenocrypts.
- Toebes appends "When you have solved it, raise your hand…" to the timed question's text; Typst
  adds it from the `timed` flag.
- `check-reference` can only test kinds with a `ciphertext` field. Kinds that print numbers or
  symbols will need their own comparison.
- Line breaking still uses `smart-line-break`, which breaks at every period; Toebes breaks by width
  only. Layout, so not a Stage 2 blocker.

## Decisions — 2026-11-14 (after Stage 1 review)

The owner checked the Stage 1 packet on paper, in question order, and stopped at the first
question that showed an answer.

1. **Work follows the paper, not the stage list.** Next is whichever type leaks first in paper
   order, so the owner can verify one more stretch of the packet each pass. The stage groupings
   above still say what each type involves; their order no longer decides what comes next. Next:
   **porta** (decode and crypt), then **nihilistsub** (decode). The legacy porta renderer prints
   the plaintext; the owner's pass missed it and a text comparison caught it.
2. **Correctness first, looks last.** Layout problems the owner notices go to a single render pass
   at the end, not fixed as they come up. Known so far: baconian (words mode) is set too tight
   compared with Toebes's PDF. Aristocrat line breaks (see Stage 1 results) belong there too.
