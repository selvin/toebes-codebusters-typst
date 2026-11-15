# Competition-ready question paper by 2026-11-30

**Date:** 2026-11-14
**Status:** **Active.** Stage 0 (docs, decisions) and Stage 1 (pipeline, aristocrats) done
2026-11-14; porta, nihilistsub (decode), baconian, compcolumnar (decode) and checkerboard done the
same day. Next, in paper order: homophonic (see "Checkerboard detail", Result).
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
| porta: decode, crypt | yes (TS) | done; matches reference |
| baconian: words, sequence, let4let | yes (TS) | done; matches reference |
| nihilistsub: decode, crypt | decode yes (TS) | decode done, matches reference; crypt todo |
| compcolumnar: decode | yes (TS) | decode done; matches reference |
| checkerboard: decode, crypt | yes (TS) | done; matches reference |
| cryptarithm | no (shows formula only; no leak) | todo: Toebes's work grid |
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
   compared with Toebes's PDF; baconian combining marks on the wrong symbol (see "Baconian
   detail"). Aristocrat line breaks (see Stage 1 results) belong there too.

## Porta detail — 2026-11-14

**What a student gets**, from the question text and Toebes's PDF: both operations print the same
thing. The ciphertext, letters only (spaces and punctuation dropped), in blocks of `blocksize`
letters. Each letter sits in a box with an empty box below it for the answer. No Porta tableau, no
keyword row. For `decode` the keyword is in the question text; for `crypt` the question text gives
the crib and its position. So `questions.json` carries neither the keyword nor the crib.

```jsonc
{
  "kind": "porta",
  "ciphertext": "ABCD EFGH IJ"   // uppercase letters, blocks of `blocksize` joined by one space
}
```

`operation` and `blocksize` stay out: the paper looks the same for both, and the blocks already
carry the size.

**Encoding** (Toebes export: `keyword`, `blocksize`, `cipherString` = plaintext): the standard
Porta tableau. Key letters pair up (AB → 0, CD → 1, …, YZ → 12). With shift `s`, a plaintext
letter `p` in A–M becomes `13 + (p + s) mod 13`; one in N–Z becomes `(p − 13 − s) mod 13`. The
keyword repeats over letters only. Checked by hand against the reference before coding.

**Checking:** pdftotext spaces porta letters apart, so `check-reference` falls back to a
letters-only comparison when the exact one fails.

**Result (2026-11-14):** done. Both porta questions in `competitiondata/001` match Toebes's PDF
(letters only), and a letters-only search of our PDF finds no porta plaintext. Typst reuses the
dual-box text rendering (`render-dual-box-text` in `common.typ`). For the render pass: ours wraps at
35 characters, while Toebes fits more blocks per line.

## Nihilist substitution detail — 2026-11-14

Decode only for now; `crypt` stays legacy until its own pass (its page may differ).

**What a student gets** (decode), from the question text and Toebes's PDF: the ciphertext as
numbers, and an empty 5×5 grid headed 1–5 for the student to build the Polybius square in. The
keyword and Polybius key appear in the question text only; the paper shows no keyword row and no
filled square. So `questions.json` carries neither key.

With `blocksize` 0, Toebes keeps the plaintext's word breaks and punctuation: numbers in a word sit
close together, words are spaced apart, and punctuation is its own token. With `blocksize` > 0
(seen only with `crypt` so far) letters run together in blocks, and punctuation is presumably dropped
as in porta.

```jsonc
{
  "kind": "nihilist",
  "words": [["57"], ["93", "27", "…", ","]]   // words → tokens: a number, or a punctuation mark
}
```

**Encoding** (export: `polybiusKey`, `keyword`, `cipherString` = plaintext): the Polybius square is
the key's letters (duplicates dropped), then the rest of the alphabet, with J merged into I. A
letter's value is row × 10 + column (1-based). Each plaintext letter's value plus the value of the
next keyword letter (repeating over letters only) gives the number. Checked by hand against the
reference before coding.

**Checking:** pdftotext interleaves the ciphertext lines with the grid's 1–5 headers. Every
nihilist number is at least 22 (11 + 11), so `check-reference` compares our numbers against the
reference's numbers with two or more digits.

**Result (2026-11-14):** decode done. It matches Toebes's PDF by number comparison (and the check
fails when one number is changed), and our PDF holds no plaintext for it. Toebes gives the
ciphertext more vertical room, for the render pass.

**Next, in paper order** (from a letters-only leak scan of the compiled packet): **baconian**.
Sequence and let4let print the plaintext. Words mode doesn't leak, but nothing has checked it
against the reference yet, so move all three modes together. After baconian: compcolumnar.

**Owner check (2026-11-14):** the owner verified on paper the porta questions and the nihilist decode
question; the packet is now verified up to the last porta question. Priority for the next session:
**baconian, then compcolumnar**. Both are firm, not "if there's room".

## Baconian detail — 2026-11-14

Source: Toebes's `app/codebusters/cipherbaconianencoder.ts` (`makeBaconianReplacement`,
`makeWordReplacement`, `genQuestion`), checked against the reference.

**What a student gets**, from the question text and Toebes's PDF:

- **words**: the cipher words, centered, one line per `lines` entry, then an empty A–Z
  "Replacement" table (26 columns). The crib, when there is one, is in the question text only.
- **sequence** and **let4let**: the cipher symbols, one per table cell, in rows of `linewidth`
  symbols, each row followed by an empty answer row. When `bitmap` is set, Toebes prints each
  symbol as an image (so pdftotext sees nothing); otherwise as text.

No mode shows the A/B letter sets, `abMapping` or the Bacon table, so `questions.json` carries none
of them.

```jsonc
{ "kind": "baconian", "mode": "words",   "lines": ["WORD WORD …", "…"] }
{ "kind": "baconian", "mode": "symbols", "lines": [["s", "s", …], …] }   // sequence and let4let
```

**Encoding** (plaintext letters only; I = J and U = V share a code, standard 24-letter Bacon
table written as A/B):

- **words**: the export's `words` holds one cipher word per plaintext letter, already chosen in
  the editor, with any trailing punctuation as its last character. That punctuation (plus a space)
  goes before the next word; a `.` alone starts a new line. Lines wrap before 53 characters
  (Toebes's `maxEncodeWidth`; `linewidth` is ignored for this mode). Non-breaking spaces inside a
  word print as spaces. Each word is checked: its letters, mapped through `abMapping`
  (alphabet position → A/B, other characters ignored), must spell the letter's Bacon code. Toebes
  substitutes a word from its dictionary when they don't; we fail loudly instead, since we don't
  ship the dictionary.
- **sequence**: `texta` and `textb` split into graphemes (combining marks stay with their base
  letter; trailing spaces stay with the previous symbol). One position counter shared by both
  sets: each A/B bit takes the symbol at that position from its set, then the counter moves on,
  wrapping to 0 when it reaches the chosen set's length.
- **let4let**: the same sets, but A and B keep separate counters.
- `texta`/`textb` with formatting tags (bold, italic, spans) would make A and B differ only in
  looks; prepare stops with an error for those until a test needs them.

**Checking:** words and sequence by text (`check-reference`, NFC-normalized, since pdftotext may
compose combining marks). Let4let prints images when `bitmap` is set: compare our symbol order with
the order of image object ids from `pdfimages -list` (one object per distinct symbol), in session.

**Result (2026-11-14):** done, all three modes. Words and sequence match Toebes's PDF by text (and
the check fails when one word or symbol is changed); let4let matches the reference's image order
symbol for symbol. Every export word matched its letter, so no dictionary fallback was needed. A
letters-only scan of our PDF finds no baconian plaintext. For the render pass: fonts for combining
marks and music symbols (Typst falls back on its own today).

**Render-pass bug (owner, 2026-11-14): combining marks land on the wrong symbol.** In a sequence
question whose symbols carry accents, a P with a tilde followed by an I with an acute prints both
marks over the I, leaving the P bare. Other pairs on the same line print correctly. Unverified
guess: P-with-tilde has no precomposed character, so it stays P + U+0303 (combining tilde); Courier
New lacks that mark, Typst takes it from a fallback font, and the mark is placed in the next cell.
The other accented letters in the set are precomposed after NFC and don't hit this. Toebes did *not*
use images for this question (`bitmap` was off): it printed text in a font with combining-mark
support (JuliaMono, via its `combchar` class). Likely fix: a font with combining marks for baconian
symbols, and NFC-normalizing symbols in `prepare`. Check by eye on the reference page afterwards.

**Next, in paper order:** compcolumnar (decode).

## Complete columnar detail — 2026-11-14

Source: Toebes's `app/codebusters/ciphercompletecolumnarencoder.ts` (`CompleteColumnarSolver`,
`genQuestion`, `makeReplacement`).

**What a student gets** (decode), from the question text and Toebes's PDF: the ciphertext in
blocks of five letters, eight blocks to a line (Toebes wraps at 48 characters), then empty work
space and an `Answer: ____` line. The crib is in the question text only. The paper shows neither the
column count nor the key (the legacy renderer printed both, along with the plaintext).

```jsonc
{ "kind": "compcolumnar", "ciphertext": "ABCDE FGHIJ …" }   // blocks of 5 joined by one space
```

**Encoding** (export: `columns`, `keyword` = column order string, `cipherString` = plaintext):
letters only, padded with `X` to a multiple of `columns`, written into rows of `columns` letters.
The key is cut or padded with `~` to `columns` characters; its characters sorted (by code unit)
give the reading order: the column of the smallest key character first, ties left to right. Each
column is read top to bottom. `crypt` stays legacy until a test needs it.

**Checking:** `check-reference` compares `ciphertext` as it does for aristocrats.

**Result (2026-11-14):** decode done. Both questions match Toebes's PDF by text, and a letters-only
scan of our PDF finds no compcolumnar plaintext. The page follows Toebes's: eight blocks a line,
work space, answer line.

**Owner check (2026-11-14):** the owner verified on paper every question up to and including the
last compcolumnar one; nothing leaks. One layout bug noted for the render pass (see "Baconian
detail", render-pass bug).

**Next, in paper order:** **checkerboard** (decode and crypt). It has no renderer, so it falls to
the "unknown" box, whose debug line prints `cipherString`: a leak. Checkerboard is in Stage 3's
hard list, so expect more reading of Toebes's source than for the kinds so far.

## Checkerboard detail — 2026-11-14

Source: Toebes's `app/codebusters/ciphercheckerboardencoder.ts` (`buildPolybiusMap`,
`buildCheckerboardSequenceSets`, `genQuestion`) and `chunk` in `app/common/cipherhandler.ts`.

**What a student gets** (decode and crypt look the same), from the question text and Toebes's PDF:
the ciphertext as two-letter cipher units, in blocks of `blocksize` units, one line of units per
table row with an empty answer row below it. Beside the first lines sits an empty 6×6 grid: no
row or column headers, no letters. The Polybius key (decode) or the crib and its cipher-unit
position (crypt) are in the question text only. Neither keyword is shown anywhere. So
`questions.json` carries no key, keyword or crib.

```jsonc
{ "kind": "checkerboard", "lines": [[["NN", "EO", …], ["EO", …]], …] }
                                    // lines → blocks (words when blocksize is 0) → tokens
```

A token is a cipher unit, or (with `blocksize` 0) a punctuation mark kept as in the plaintext.

**Encoding** (export: `keyword` = row keyword, `keyword2` = column keyword, `polybiusKey`,
`blocksize`, `cipherString` = plaintext): the square is the Polybius key's letters, then the
alphabet, J merged into I, duplicates dropped, filled row by row. A letter at row r, column c
becomes row keyword letter r followed by column keyword letter c. Both keywords must be exactly 5
letters (Toebes refuses otherwise; prepare leaves the question legacy). With `blocksize` > 0 only
letters survive, in blocks; with 0, spaces and punctuation stay.

**Line breaks** follow Toebes's `buildCheckerboardSequenceSets` with width 24: the first three
lines break at 13 tokens (spaces count), later lines at 24, each at the last space. With blocks of
5 that gives two blocks a line beside the grid, then four. Kept in `prepare` because the break
rule counts tokens, not printed width.

**Checking:** `check-reference` compares the letters of all cipher units, in order, with the
reference's letters (the grid is empty, so it adds none).

**Result (2026-11-14):** done, decode and crypt. Both questions match Toebes's PDF by letters (and
the check fails when one unit is changed); line shapes match the reference (two blocks a line beside
the grid, then four). A letters-only scan of our PDF finds no checkerboard plaintext.

**Leak scan finding:** the scan flags cryptarithm, but falsely: a cryptarithm's `cipherString` is the
formula, which Toebes prints too. The answer is `soltext`, which the legacy renderer doesn't print.
So cryptarithm doesn't leak. It still lacks Toebes's "values to decode" boxes and letter/digit work
grid, a gap for the render pass or its own pass. Future scans should test cryptarithm by `soltext`.

**Next, in paper order:** **homophonic** (decode and crypt). It has no renderer and falls to the
"unknown" box, which prints `cipherString`. In Stage 3's hard list.

**Owner check (2026-11-14):** the owner verified on paper questions up to and including the second
checkerboard one. The let4let baconian (music symbols, printed as images by Toebes) was taken on
trust from the image-order comparison in "Baconian detail", Result. The cryptarithm in between
doesn't leak; see the render-pass list below.

## Decisions — 2026-11-14 (render-pass inputs)

Collected for the render pass at the end; not to be fixed before then.

1. **Cryptarithm** (owner): the formula prints on one line. Toebes sets it as grade-school
   addition, one operand per line with a rule under them. Also missing: the boxes under the values
   to decode, and the letter × digit (0–9) work grid.
2. **Look at the sister attempt, `~/workspace/codebusters-test-papers`** (owner's earlier
   LaTeX-from-Python version, local only). Ideas worth taking: how question numbers are set (boxed),
   point values stood out more, a page header with the test name, page number and a blank for the
   team number, and more. Its fonts are Arial for body text and MesloLGS NF (scaled 1.1) for
   monospace: compare MesloLGS with Courier New here, especially since Courier New won't exist in
   a browser build (see Backlog, Fonts).

## Homophonic detail — 2026-11-14

Source: Toebes's `app/codebusters/cipherhomophonicencoder.ts` (`updateMapping`,
`buildReplacementHomophonic`, `genQuestion`, `genHelpTable`) and `chunk` in
`app/common/cipherhandler.ts`.

**What a student gets**, from the question text and Toebes's PDF: the ciphertext as numbers, in
blocks of `blocksize`, each line followed by an empty answer row. Below it a help table: for
`decode`, four header rows numbering 1–25, 26–50, 51–75, 76–00; for `crypt`, one header row of the
25 letters (`I/J` shared). Then four empty rows. The keyword (decode) or the crib and its position
(crypt) are in the question text only. So `questions.json` carries no keyword, crib or slot
choices.

```jsonc
{ "kind": "homophonic", "header": "numbers", "lines": [[["00", "92", …], …], …] }
                         // "numbers" (decode) | "letters" (crypt); lines → blocks → tokens
```

A token is a cipher value (100 prints as `00`), or (with `blocksize` 0) a punctuation mark.

**Encoding** (export: `keyword`, `randomSlot`, `blocksize`, `cipherString` = plaintext): the
alphabet is the 25 letters without J (J encodes as I). The keyword's first four letters (padded
with `A`) each own one range of 25 values; in range `i` (0–3), letter `c` is
`1 + 25i + (pos(c) − pos(keyword[i])) mod 25`. Which range each plaintext letter uses is **not
random at print time**: the export's `randomSlot` holds one choice (0–3) per plaintext letter,
saved when the question was written. So Toebes's ciphertext can be reproduced exactly.

**Line breaks** follow `buildReplacementHomophonic` with width 25 (Division A uses 15; not handled
until a test needs it): tokens, spaces included, break at the last space once a line reaches 25.
Toebes doesn't reset the last-space marker after a split; we copy that. With blocks of 5 that gives
four blocks a line.

**Checking:** `check-reference` compares the cipher values in order with the reference's numbers,
minus the help table's.
