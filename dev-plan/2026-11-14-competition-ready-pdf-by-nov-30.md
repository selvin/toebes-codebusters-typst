# Competition-ready question paper by 2026-11-30

**Date:** 2026-11-14
**Status:** **Active.** Stage 0 (docs, decisions) done 2026-11-14. Next: Stage 1.
**Deadline:** 2026-11-30.
**Related:** [2026-11-14-ts-prepare-typst-layout-split.md](2026-11-14-ts-prepare-typst-layout-split.md)

---

## Goal

From `testdata/001.json`, produce a question paper a proctor could hand out. "Competition-ready"
means every question shows the right ciphertext, numbering and points match Toebes's PDF, and
nothing in the packet gives away an answer.

**Scope is the cipher types in `testdata/001`**, not every Codebusters type. Other types come later,
each on its own.

**Not in scope:**
- The answer key: nice to have; Toebes's answer key is the fallback (graders only).
- The cover page and score table: last, and optional. Graders score on codebusters.site, not on
  paper.
- The website.

## The yardstick

In `testdata/` (gitignored; see `CLAUDE.md`, "Hard rule"):

- `001.json` — input.
- `001.pdf` — Toebes's question paper for it, printed from Chrome. No answer key.

Check ciphertext by text: `pdftotext -layout testdata/001.pdf` gives each question's ciphertext,
which tests can compare with ours. Check looks by eye.

## Assessment of the code as of 2026-11-14

Last worked on 2025-11-26 → 2025-12-15. It compiles against `testdata/001.json`, but:

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
| aristocrat: random, K1, with hint | no | todo |
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
