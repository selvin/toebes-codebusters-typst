# Answer key

**Date:** 2026-11-16
**Status:** Slice 1 done 2026-11-16; awaiting the owner's look (slice 2).
**Related:** [2026-11-14-ts-prepare-typst-layout-split.md](2026-11-14-ts-prepare-typst-layout-split.md)
(Decision 1: answers go to a separate input),
[2026-11-14-competition-ready-pdf-by-nov-30.md](2026-11-14-competition-ready-pdf-by-nov-30.md)

---

## The model: a grading sheet

The owner supplied a Toebes answer key from another test as the example
(`competitiondata/002-key.pdf`, gitignored; we have no export for it). It isn't per-cipher work
(plaintext under the ciphertext). It's **one row per question**, on a landscape page:

| Letters | Number | Answer |
|--------:|:------:|--------|
| count   | T, 1, 2, … | the plaintext, as written in the export (mixed case, punctuation) |

- **Letters:** how many plaintext letters the answer has. Graders sometimes use it to break ties
  between equal scores. Rule, checked on all 29 rows of the example: count the letters, with an
  accented letter counting as one; spaces, digits and punctuation don't count.
- **Answer:** `cipherString` for every kind except **cryptarithm**, whose answer is `soltext` (its
  `cipherString` is the equation). Misspelled aristocrats show the misspelled text, since that
  is what `cipherString` holds and what students decode.
- Toebes adds a cover page front and back, and a running header with a stale date.

## What we'll do (the owner's redesign, 2026-11-16)

- Number column: **T** for the timed question, then 1, 2, 3, ….
- Letter counts **right-aligned** (Toebes centres them).
- **Groups:** the timed answer in its own block, then 1–5, 6–10, …, with a thicker rule between
  groups.
- **Special bonus:** a narrow column left of the letter count holding ★.
- **Zero-error questions:** mark the questions that allow no errors. The owner thinks only
  cryptarithm, for Division B, per the rules. The rule lives in `prepare` as a table by division and
  kind, so a rules change is a one-line edit.

## Input, entry point, output

- `prepare` writes **`build/answers.json`** beside `questions.json`, on every run:
  ```
  { test: { title, division },
    answers: [ { number, timed, kind, points, specialBonus, zeroErrors, answer, letters } ] }
  ```
  `letters` is computed in TS (unit-tested), not in Typst.
- **`render/key.typ`**, a separate Typst entry point, reads only `answers.json`. `render/main.typ`
  (the question paper) is never given `answers.json`.
- `compile.sh <export> <out.pdf>` also writes **`<out>-key.pdf`** (e.g.
  `competitiondata/001-tct-key.pdf`). The leak check stays on the question paper only.

## Slices

1. **The whole table, all kinds at once.** Each kind's answer is one string, so there's no reason
   to do it kind by kind. `answers.json` + `key.typ` + `compile.sh`. Check: every row's letter
   count and answer against the export, and both tests compile with their page counts unchanged
   (16, 11) and the leak check passing.
2. **The owner looks at it**, and we fix whatever that review finds.

## Suggested improvements (for the owner to decide)

1. **Points column** next to the number, for graders adding up a score sheet. Cheap; the data is
   already in `questions.json`.
2. **One page per test.** `001` has 30 rows and `000` has 21, and the longest answer is 124
   characters. In landscape at body size with tight row padding, both should fit on one sheet.
   Long answers wrap rather than shrink.
3. **No cover pages.** Toebes's front and back covers only hide the sheet. A header that says
   ANSWER KEY plus the test title (our header style, without Toebes's stale date) is enough. The
   cover page stays in the Backlog for the question paper.
4. **How to mark zero-error questions:** a second narrow column showing `0` (allowed errors)
   only on those rows, beside the ★ column. Alternative: `0 err` in the ★ column.

## Decisions — 2026-11-16 (owner)

- **Zero-error questions:** no new column. The answer prints in **all caps**, and a **red border**
  surrounds its letter count. The rule: cryptarithm, Division B only.
- **Landscape** (Toebes's key is portrait there, and some answers don't fit).
- **Row borders at 60% black** (the paper's outline colour), so the answers stand out. Group rules
  are thicker.
- **Fonts:** answers in Typst's default serif (Libertinus Serif, built into Typst); cryptarithm
  answers in the mono font (Noto Sans Mono).
- **Not one page.** At most **18 rows a page** (a test has at most 35 questions plus the timed
  one), at a slightly larger size, so around 7 answers may take two lines.
- No points column and no cover pages for now; the header says ANSWER KEY and gives the test title.
  (Covers added later the same day; see below.)
- Column order: ★, letters, number, answer.

## Result — slice 1 (2026-11-16)

- `prepare/src/answers.ts` writes `build/answers.json` (unit-tested; question order shared with the
  paper through `paperOrder` in `questions.ts`). The letter count reuses the leak check's
  `lettersOnly`, the same rule the example key follows.
- `render/key.typ`: landscape, 12pt; ★ column, then the letter count (mono,
  right-aligned), the number (mono bold), the answer. Text is measured cap height to baseline in
  the table, so the ★ and mono rows don't come out taller than the rest.
- `compile.sh` writes `<out>-key.pdf` after the question paper's leak check.
- Checked: every answer and letter count on both keys matches the export (letters-only compare of
  `pdftotext`). Both keys are 2 pages; `000`'s second page holds 3 rows. The question papers are
  unchanged (11 and 16 pages; `check-reference` and the leak check pass).

## Decisions — 2026-11-16 (page split, owner)

- **Page 1 ends after question 15**: T and three groups of five. The rest follow on page 2, breaking
  again only if they must. Replaces "at most 18 rows a page". Most tests now have 30 or 31
  questions (16 to 20 two seasons ago), so page 2 usually holds 15 or 16 rows.
- Row padding down from 9pt to 7pt, so a 35-question test fits on 2 pages: checked with a made-up
  key, T + 1–35 with every seventh answer wrapping (page 2: 20 rows, 4 of them two lines).

## Decisions — 2026-11-16 (styling, owner)

Supersedes the page split and the groups above.

- **Columns:** letter count, ★, number, answer. The count is in 60% black so it doesn't dominate
  (the red zero-error border stays); the number is ink blue and bold.
- **No groups of five.** Odd-numbered questions get a 20% black background instead; all row rules
  are thin.
- **One table that flows,** with roomier rows (10pt padding), so page 1 fills first and holds more
  rows than page 2: `001` is 18 + 12, `000` 18 + 3. Made-up keys of 31 and 32 rows fit on 2 pages;
  the maximum (T + 35) takes 3.
- The ★ sits in a cap-height box, so ★ rows are no taller than the others.

## Decisions — 2026-11-16 (covers, owner)

- Odd-row shading down to **10% black** (20% was too noticeable).
- **Front and back cover**, the same page twice, all in the answers' serif: ANSWER KEY as the title,
  large and red but not bold, then the
  test's name and its division, centred on the page both ways. The footer's page numbers skip the
  covers ("Page 1 of 2" on the table's pages).
- **No date:** Toebes's export holds none (checked both tests' `TEST.0`). If one is wanted, it
  needs its own input (e.g. a `compile.sh` option); not built.
