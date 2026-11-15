# Competition-ready question paper by 2026-11-30

**Date:** 2026-11-14
**Status:** **Active.** Stage 0 (docs, decisions) and Stage 1 (pipeline, aristocrats) done
2026-11-14; every cipher type in `competitiondata/001` followed the same day, and the owner verified
the whole packet's logic on paper. Only cryptarithm is still legacy (no leak). Render pass step 1
(header and footer) done and verified. Typst code moved under `render/`. **Next:** step 2, question-independent formatting (see "Decisions —
2026-11-14 (render pass order)").
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
- `000.json`, `000.pdf` — an older real test and Toebes's PDF of it (added 2026-11-15), a second
  check. See "Second yardstick: competitiondata/000".

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
| aristocrat, Spanish (xenocrypt), K1 | yes (TS) | done; matches reference |
| patristocrat, K1 | yes (TS) | done; matches reference |
| atbash | yes (TS) | done; matches reference |
| caesar | yes (TS) | done; matches reference |
| porta: decode, crypt | yes (TS) | done; matches reference |
| baconian: words, sequence, let4let | yes (TS) | done; matches reference |
| nihilistsub: decode, crypt | yes (TS) | done; matches reference |
| compcolumnar: decode | yes (TS) | decode done; matches reference |
| checkerboard: decode, crypt | yes (TS) | done; matches reference |
| cryptarithm | no (shows formula only; no leak) | todo: Toebes's work grid |
| homophonic: decode, crypt | yes (TS) | done; matches reference |
| fractionatedmorse: crypt | yes (TS) | done; matches reference |

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
  "test": { "title": "…", "division": "C", "count": 20 },
                                // count = untimed questions; division "A"/"B"/"C" or ""
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

**Crypt and blocks (2026-11-14):** Toebes's `genQuestion` is the same for decode and crypt: the
values in lines from `buildNihilistSequenceSets` (width 24, extra 11: the first three lines break
at 13 tokens, beside the grid, later lines at 24; tokens include spaces; a break falls after the
last non-letter). With `blocksize` > 0 only letters survive, in blocks, so a line beside the grid
holds two blocks of four and later lines four. Each line has an empty answer row below; the grid is
the same as decode's. The crib and its position are in the question text only.

```jsonc
{ "kind": "nihilist", "lines": [[["65", "92", …], …], …] }   // lines → blocks → values
```

Prepare uses `lines` for crypt, and for decode with `blocksize` > 0; decode with `blocksize` 0
keeps `words` (verified on paper; moving it to Toebes's line breaks is render-pass work). Like
homophonic, Toebes doesn't reset the last-split marker after a split; we copy that. Checked by
`check-reference` as decode is (numbers of two digits or more).

**Crypt result (2026-11-14):** done. The crypt question matches Toebes's PDF by number comparison
(and the check fails when one value is changed); line shapes match (two blocks a line beside the
grid, then four). A letters-only scan of our PDF finds no nihilist plaintext. Toebes spaces values
wider, for the render pass. **Next, in paper order:** fractionated morse, then patristocrat, then
a xenocrypt aristocrat.

**Owner check (2026-11-14):** the owner verified on paper every question up to and including the
nihilistsub crypt question and the two after it, i.e. up to the first fractionated morse one.

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

**Render-pass bug (owner, 2026-11-14), fixed by the Noto fonts (2026-11-15): combining marks land on the wrong symbol.** In a sequence
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
2. **Fractionated morse** (owner, after the fractionated morse pass): cipher lines left-aligned,
   not centered. Use the spare width (about 30% blank around the ciphertext): larger letters
   and/or more space per letter. The Replacement row needs room to pencil in a letter; the Morse
   fraction row needs more vertical spacing; its header can be set as "Morse" over "fraction".
3. **Look at the sister attempt, `~/workspace/codebusters-test-papers`** (owner's earlier
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

**Result (2026-11-14):** done, decode and crypt. Both questions match Toebes's PDF by number
comparison (and the check fails when one value is changed); line shapes match the reference (four
blocks a line) and the help tables look like Toebes's. A letters-only scan of our PDF finds no
homophonic plaintext.

**Next, in paper order** (leak scan): **nihilistsub crypt** (still legacy; see "Nihilist
substitution detail": blocks of letters, page may differ from decode). After it: fractionated
morse, then patristocrat, then a xenocrypt aristocrat.

**Owner check (2026-11-14):** the owner verified on paper every question up to and including the
first homophonic one. Only 100 prints as `00` (Toebes's `plainCt100`); 1–9 print without a leading
zero, as in the reference.

## Fractionated morse detail — 2026-11-14

Source: Toebes's `app/codebusters/cipherfractionatedmorseencoder.ts` (`makeReplacement`,
`genQuestion`, `generateReplacementTable`), `app/common/morse.ts` (`tomorse`) and `genKstring` in
`app/codebusters/cipherencoder.ts`.

**What a student gets** (both questions in `competitiondata/001` are `crypt`), from the question
text and Toebes's PDF: the cipher letters, spaced apart, in centered lines with generous room
between them (no separate answer row). Below, a 27-column table: a "Replacement" row of empty
cells, and a "Morse fraction" row holding the 26 fixed triples (●, –, ×) stacked vertically, in
Toebes's fixed order (`OOO`, `OO-`, `OOX`, … `XX-`). The triples are the same for every question;
which cipher letter stands for which triple (the keyword alphabet) is not shown. The crib, its
cipher letters and their triples are in the question text only. So `questions.json` carries no
keyword, crib or letter order.

Export fields read: `cipherString` (plaintext), `keyword` (a word; 5–6 letters here), `operation`.
Also present, not read: `crib` (5), `replacement` (empty), `encoded` (empty), `curlang`, `offset`,
`salt`, `author`.

```jsonc
{ "kind": "fractionatedmorse", "lines": [["G", "V", …], …] }   // lines → cipher letters
```

**Encoding:** the plaintext in morse (`O` dot, `-` dash), `X` between letters, `XX` at a word
break (any character other than a letter or digit, once a letter has been seen), padded with `X`
to a multiple of three. Each triple's position in the fixed list picks a letter from the keyword
alphabet (keyword letters, duplicates dropped, then the rest of A–Z). Toebes encodes letter by
letter, removing and redoing the padded last cipher letter each time; a triple of `XXX` would hang
Toebes, so prepare stops with an error. Digits are left out until a test has them (whether Toebes's
print path treats them as letters is unclear).

**Line breaks:** Toebes's `makeReplacement` with `maxEncodeWidth` 53 on a line string of
`" c "` per cipher letter (≈ 17 letters a line), split at the last word break, last-split marker
never reset (as homophonic). The redo of the padded letter acts on the current line string, so we
port the string handling as is rather than break the finished letter list afterwards.

**Checking:** `check-reference` compares the cipher letters with the reference's letters (the
table adds none, and its `●–×` aren't letters).

**Result (2026-11-14):** done. Both questions match Toebes's PDF by letters (and the check fails
when one letter is changed); line shapes match the reference line for line. A letters-only scan of
our PDF finds no fractionated morse plaintext. For the render pass: Toebes centers the block of
lines as a whole, with lines left-aligned inside it; ours centers each line. The table's header
cells are smaller than Toebes's.

**Repeated letter at a line break (2026-11-14):** because the last-split marker isn't reset, a
long word (about 11 plaintext letters or more; a fuzz of made-up texts found none up to 10) can
fill the next line before another word break. Toebes then splits at the stale position, at or past
the line's end, pushes the padded last letter with the line, and encodes it again on the next
line: one extra cipher letter, on Toebes's paper too. We copy it, so ours matches Toebes. Whether
to keep matching Toebes or print the correct ciphertext was the owner's call. **Decided
(owner, 2026-11-14): keep matching Toebes**, so our paper and Toebes's answer key agree.

**Next, in paper order** (leak scan): **patristocrat** (K1), then the remaining aristocrat (a
xenocrypt, per the earlier plan) and the second patristocrat.

## Patristocrat detail — 2026-11-14

Source: Toebes's `getEncodingString` in `app/codebusters/cipherencoder.ts` and `chunk` in
`app/common/cipherhandler.ts`.

**What a student gets**, from the question text and Toebes's PDF: the ciphertext in blocks of five
letters (eight blocks a line, from `maxEncodeWidth` 53), then the same table as an aristocrat: a
"K1" (or "Random") header row of the alphabet, a frequency row, an empty replacement row. The
hint is in the question text only. Export fields are the aristocrat's (`replacement`,
`alphabetSource`, `alphabetDest`, `keyword`, `hint`, `offset`, …); only `replacement` and
`alphabetSource` are read, as for aristocrats.

**Encoding:** Toebes chunks the plaintext (letters only, blocks of five) and then encodes it like an
aristocrat. So prepare reuses the aristocrat kind: `"kind": "aristocrat"` with the blocked
ciphertext; no new field, no new renderer. Our line breaking (55 characters) fits nine blocks a line
where Toebes fits eight: render pass.

**Checking:** `check-reference` compares `ciphertext` as for aristocrats.

**Result (2026-11-14):** done. Both patristocrats match Toebes's PDF by text (and the check fails
when one letter is changed); the frequency rows match by eye. A letters-only scan of our PDF finds
no patristocrat plaintext.

**Next, in paper order** (leak scan): the **Spanish (xenocrypt) aristocrat**, K1, the only question
left that leaks. Its alphabet and accent handling need checking against Toebes (`langreplace`,
Spanish `Ñ`), which is why Stage 1 left it legacy.

**Owner check (2026-11-14):** the owner verified on paper every question except the Spanish
aristocrat: fractionated morse and patristocrat included. After the xenocrypt, the logic is done and
work moves to rendering and fonts for a browser build.

## Xenocrypt detail — 2026-11-14

Source: Toebes's `langcharset`, `langreplace` and `makeReplacement` in
`app/common/cipherhandler.ts`; `findUsage` in `app/codebusters/cipherencoder.ts`.

**What a student gets**, from the question text and Toebes's PDF: the same as an English
aristocrat, over the Spanish alphabet `ABCDEFGHIJKLMNÑOPQRSTUVWXYZ` (27 letters, `Ñ` between `N`
and `O`). The table has 27 letter columns; the frequency row counts all 27. The ciphertext shows
no accents.

Export fields (the aristocrat's; lengths only): `cipherString` 98, `keyword` 9, `alphabetSource` 27,
`alphabetDest` 27, `replacement` 27 keys (`Ñ` included), `curlang` `es`, `encodeType` `k1`. Also
present, not read: `translation`, `keyword2`, `offset2`, `misspelled`, `salt`, `author`. As for
English aristocrats, only `replacement` and `alphabetSource` are read.

**Encoding** (`makeReplacement`): uppercase, then fold accented letters by `langreplace.es`
(`Á É Í Ó Ú Ü Ý` → `A E I O U U Y`), then substitute through the inverse of `replacement`.
`Ñ` is a letter of its own and is substituted, not folded. Characters outside the alphabet
(including `¿ ¡`) are kept. The plaintext in `competitiondata/001` has accented vowels and no `Ñ`.

So prepare drops the `curlang` ≠ `en` guard for `es` only, applying the fold before the substitution.
Other languages stay legacy until a test has one. The Typst aristocrat renderer already takes its
columns from `alphabet`; only whether 27 columns fit the page needs checking.

**Checking:** `check-reference` compares `ciphertext` as for aristocrats.

**Result (2026-11-14):** done. The xenocrypt matches Toebes's PDF by text (and the check fails when
one letter is changed); the 27-column table fits the page, and the frequency row and line breaks
match the reference by eye. Spanish patristocrats stay legacy: `chunk` keeps A–Z only and would drop
accented letters and `Ñ`.

**The packet is leak-free.** A letters-only scan of our PDF (accents folded) finds no question's
plaintext, whole or as any 20-letter window, and no cryptarithm `soltext`. Still rendered from the
raw export (`kind: "legacy"`), without leaking: atbash and caesar (they encode in Typst) and
cryptarithm (formula only).

**Next, the owner's call** (none started):
1. Owner verifies the xenocrypt on paper, closing the correctness pass.
2. Move atbash and caesar to TS, so `main.typ` stops reading the export for them (the question
   paper still sees the export, plaintext included, until every kind is migrated).
3. The render pass, starting from "Decisions — 2026-11-14 (render-pass inputs)" and the layout
   notes in each detail section (cryptarithm work grid included).
4. Fonts for a browser build (Courier New won't exist there).
5. Stage 4: page header (title, "Team Number").

The repeated letter at a line break in fractionated morse: since decided, keep matching Toebes
("Fractionated morse detail").

## Atbash and caesar detail — 2026-11-14

Source: Toebes's `app/codebusters/ciphertableencoder.ts` (`genAlphabet`, `genQuestion`), one
encoder for both types.

**What a student gets**, from the question text and Toebes's PDF: the ciphertext one letter per
box, an empty answer box under each, words kept apart and punctuation outside the boxes. No table.
Lines break at 37 characters in Toebes (`makeReplacement`, width 37; 30 for Division A). For a
caesar, the offset isn't printed.

Export fields (both types; lengths only): `cipherString` 56–87, `replacement` 26 keys, `offset`,
`operation` (`decode` in all four), `curlang` `en`. Also present, not read: `author`, `salt`.

**Encoding:** `genAlphabet` builds `replacement` as the decode table (reverse alphabet for atbash,
the alphabet rotated by `offset` for caesar), the same convention as aristocrats. In
`competitiondata/001` each `replacement` agrees with its type and offset. So prepare reuses
`encodeSubstitution` on `replacement`, the source the other substitution kinds read; `offset` is not
read.

```jsonc
{ "kind": "atbash", "ciphertext": "SVOOL, AVYIZ." }   // or "caesar"; uppercase, spaces and punctuation kept
```

One kind per type, as porta (which prints the same boxes from `ciphertext`): each keeps its current
line width (32 atbash, 35 caesar), so the owner-verified layout doesn't move before the render pass.
Typst's `render-dual-box-text` takes the ciphertext as is, so the Typst atbash and caesar encoders
go. `operation` `encode` (Toebes would print the
plaintext for the student to encode) stays legacy until a test has one. Line breaks (ours: 32 for
atbash, 35 for caesar) are render pass.

**Checking:** `check-reference` compares `ciphertext` as for aristocrats (letters-only fallback, since
boxes space the letters apart).

**Result (2026-11-14):** done, as kinds `atbash` and `caesar`. All four questions match Toebes's
PDF by text (and the check fails when one letter is changed in either kind); pages look as before.
The leak scan still finds nothing. `render-dual-box-cipher` and the Typst encoders are gone. Only
cryptarithm stays legacy (formula only, no leak; its work grid is in the render-pass inputs).
For the render pass: a closing period can wrap onto a line of its own (with its answer row), from
`smart-line-break`.

**Owner check (2026-11-14):** the owner verified the ciphertext of all four atbash and caesar
questions against Toebes's PDF: they match.

## Decisions — 2026-11-14 (render pass order)

The owner verified the xenocrypt on paper: **every question in `competitiondata/001` is verified for
logic.** The render pass comes next, in this order (owner):

1. **Global:** page header and footer (Stage 4: test title, page number, "Team Number" blank).
2. **Question-independent formatting:** what every question shares: heading, question number,
   points, spacing, fonts, line breaking.
3. **Question-dependent formatting:** each kind's own layout, from "Decisions — 2026-11-14
   (render-pass inputs)" and the notes in each detail section (cryptarithm work grid included).

The sister attempt, `~/workspace/codebusters-test-papers`, is the first reference for 1 and 2.
Fonts for a browser build fit under 2.

## Render pass: header and footer — 2026-11-14

Step 1 of the render pass (Stage 4).

### What the references do

- **Toebes's PDF.** The cover page has no header or footer, and page numbering starts on the first
  question page ("Page 1"). Every question page, the timed one included, has a header line: the
  test title, then at the right "Team Number:" with a blank that has the division letter
  pre-filled (the first letter of `TEST.0.testtype`, which names the division, e.g. a made-up
  `cregional` → `_C_____`). The footer is "Page N", centered. No rule under the header.
- **Sister attempt** (`~/workspace/codebusters-test-papers`, `src/driver.py`,
  `render_page_header`): header only, on every question page: the title at the left (70% of the
  width), "Page N" and "Team: ____" at the right, a horizontal rule under it. No footer. No cover
  page, so nothing differs on page 1. The team number is a plain blank, not a box.

### What we'll do

`set page(header: …, footer: …)` in `main.typ`, the title from `prepared.test.title`, read at
compile time, so nothing about the test sits in a tracked file. Every page carries it, the timed
question's page included (we have no cover page yet; when one comes, it opts out and numbering
starts after it, as in Toebes).

### Decided (owner)

1. **Toebes's layout:** the title and "Team Number:" in the header, the page number centered in the
   footer, no rule.
2. **"Page N of M"**, so students can check no page is missing.
3. **Division letter pre-filled** in the team number blank, as in Toebes. `prepare` adds
   `test.division` (`"A"`, `"B"`, `"C"`, or `""` when `testtype` doesn't start with one of them);
   the blank is plain when it's empty.

### Result

Done. The header is a two-column grid: the title centered in the free width, then "Team Number:"
and a 2.5 cm underlined blank holding the division letter. The footer is "Page N of M", centered.
The bottom margin went from 1 cm to 1.5 cm to make room; the packet's page count still matches
Toebes's question pages. `check-reference` passes and the leak scan is clean.

Surprise: `counter(page).display("Page 1 of 1", both: true)` reads the "a" in "Page" as a counting
symbol (prints "Pbge"). The footer builds the text from `counter(page).get()` and `.final()`
instead.

The question heading's rule (from `position-question`) now sits right under the header line; step
2 (question heading) is where to space them apart.

**Owner check (2026-11-14):** header and footer verified. Before step 2, the owner wants the Typst
code moved under `render/` (cipher renderers in `render/ciphers/`, shared files in
`render/common/`, where that makes sense); a refactor only, its own commits, no change to the
output. Step 2 follows it, possibly in a later session.

## Second yardstick: competitiondata/000 — 2026-11-15

An older real test (formerly the untracked `input.json` at the repo root) and Toebes's PDF of it.
Checked with the pipeline as built for `001`:

- **`check-reference` passes** for every question it can compare. Baconian symbol questions have
  no text layer in Toebes's PDF; checked by eye instead, and they match.
- **Bug found and fixed:** this export stores the baconian `linewidth` as a string, which broke
  line breaking for symbol baconians (`prepare/src/baconian.ts`).
- **Legacy kinds still in it:** affine, cryptarithm, and K2 aristocrat and patristocrat (`prepare`
  handles random and K1 only). Legacy affine and K2 aristocrat still print the plaintext; a K2
  patristocrat shows the "unsupported" box. Not a blocker: `001` is the deadline test.
- **K2 won't be added** (owner): it was a Division B alphabet until last season and was dropped as
  a cipher type for the 2027 season.

**Decided (owner):** the tool supports the 2027 season's cipher types and later only. K2
aristocrat, K2 patristocrat and affine are unsupported. The owner will re-export `000.json` from
Toebes with those questions removed.

**Re-exported (2026-11-15):** `000.json` and `000.pdf` now hold only supported types. Every question
is a prepared kind except cryptarithm (legacy, no leak); `check-reference` passes for everything
it can compare, and a scan of our PDF's text finds no plaintext. The re-export changed nothing in
the remaining questions, so the by-eye baconian check above still holds. `check-reference` reports a
let4let baconian whose letters are the A/B symbols as "NOT FOUND" rather than "check by eye": its
image detection looks for any symbol in the reference text, and plain letters are always there.

**Cryptarithm, for when it moves to `prepare`:** its `cipherString` is the equation, which students
see, not the answer. The answer is `mapping` (letter → digit) and `soltext` (the decoded words);
the values to decode are written into the question text by Toebes. The question paper gets the
equation only; `mapping` and `soltext` belong to the answer key. The legacy renderer reads neither,
so it doesn't leak.


## Render pass: question heading — 2026-11-15

Step 2 of the render pass, first slice: the line each question starts with (number, points, then
the question text). Spacing, fonts and line breaking come later.

### What the references do

- **Toebes's PDF.** A thin rule above each question, set a little below the page header. Then
  `N)` in the body font (not bold), then `[P points]` all bold, then the question text. The timed
  question reads `Timed Question [P points]`, and the whole question sits in a frame.
- **Sister attempt** (`src/renderers/aristocrat.py`): the number bold in a box (`\fbox`), then
  `[P points]` in small monospace with only `P` bold at normal size, then the question text. No
  rule; no timed question.
- **Ours before this step:** the rule, set tight under the page header; `N.` bold; `[P points]`
  with `P` in bold Courier; `TIMED Question` for the timed one.

### Decided (owner)

1. **The sister attempt's look**, with the number in a **square** box, sized so one or two digits
   both fit, centered both ways.
2. **The rule stays above the heading line**, as in Toebes and ours. It gets a small gap below the
   page header, as in Toebes.

### What we'll do

In `question-heading-core` (`render/common/common.typ`): the boxed number, then `[P points]` in
Courier New (`[` `points]` small, `P` bold at normal size), then the question text. The timed
question keeps its `TIMED Question` label in place of the box (the box is for a number). The
timed question's frame is question-dependent (step 3).

### Result

Done, pending the owner's check on paper. The number box is 1.7em square (fits two digits), the
digits centered by their glyph bounds (`top-edge`/`bottom-edge: "bounds"`; with the default edges
they sat high), the box centered on the text line (`baseline: 0.5em`). The rule has 0.5em above
it and 0.6em below; less let the box touch it in bottom-half questions. Page counts are unchanged
for `001` and `000`; `check-reference` passes for `001`, and for `000` reports only the known
let4let baconian (see "Second yardstick").

**Changed (owner, 2026-11-15): a circle, not a square.** The cipher renders are full of boxes, so
a boxed number blends in. The number now sits in a circle 6% wider than the square was (1.8em
across, `circle` inside a `box` with `baseline: 0.55em`). Downscaled previews of it look flat on
the right; measuring the pixels at 600 ppi shows it is round, so check it at full size.

**Owner check (2026-11-15):** verified. The heading looks polished and every piece is easy to find
at a glance. Formatting a hint or crib in the question text (bold, monospace) is the test setter's
job in Toebes; we render the question's HTML as given and add no emphasis of our own.

**Next in step 2:** spacing, then fonts (including a browser-safe monospace), then line breaking.

## Render pass: spacing — 2026-11-15

Step 2 of the render pass, second slice: the vertical space every question shares. Fonts and line
breaking come later.

### What the references do

- **Toebes's PDF.** Questions flow: each starts right after the last one ends, so a page holds
  one, two or three questions. A small, even gap between the heading text and the cipher body.
- **Sister attempt** (`src/driver.py`): two questions a page, the second pushed down a fixed
  `\vspace{10cm}` after the first. The cipher body starts one paragraph break under the heading.
- **Ours.** Two questions a page (`position-question`, `question-page-control`): odd questions at
  the top, even ones placed at a fixed 12.72 cm below the top margin. That length was worked out
  for a 1 cm bottom margin; since the footer made it 1.5 cm, the "middle" sits 0.25 cm low. The
  gap from heading to body is set by each renderer: none, `v(0.5em)` or `v(1em)`, on top of the
  heading's own 0.5em, and some bodies add a 4–10 pt top inset; so it differs from kind to kind.

### What we'll do

1. **Keep the half-page layout** (a fixed place for each question is easier to find on paper), and
   place the bottom question at **50% of the text area** instead of a hard-coded length, so it
   follows the margins.
2. **The heading owns the heading-to-body gap**: one value in `question-heading-core`, and the
   renderers' own leading `v()` and top insets go (prepared kinds and the legacy cryptarithm).
3. **Body to the next question's rule** needs no setting: the next rule is at a fixed place (top of
   the page, or the middle). Not guarded: a top question taller than half a page would run into
   the bottom one. None does in `001` or `000`; if one ever does, that's its own slice.
   *(Wrong: one top question in `001` already ran into the bottom one; see below.)*

### Decided (owner)

**The bottom question starts at the middle, or lower** if the top one runs past the middle (then a
clear gap between them). Nothing can overlap; a bottom question that no longer fits moves to the
next page. Chosen over keeping a fixed middle (and shrinking the tall kind in step 3) and over
flowing questions as Toebes does.

### Result

Done, pending the owner's check on paper.

- **Half page:** the top question is measured (`layout` + `measure`) and padded down to the middle
  of the text area, at least 1.5em; the bottom question just follows. `place` is gone, and so is
  the hard-coded 12.72 cm. A first try computed the padding from `here().position()`; that
  depends on its own result, Typst warned the layout did not converge, and three bottom questions
  wrongly moved to the next page. Measuring has no such loop.
- **Heading to body:** one `v(1.5em)` at the end of `question-heading-core`. The renderers' own
  leading `v()` and top insets are gone (prepared kinds and the legacy cryptarithm). Measured from
  the end of that gap to the first ink: every kind within 0.5 pt, except the symbol baconian (3 pt
  lower, from its table's cell inset). 1em matched the heading's own line spacing, so the body
  didn't read as separate. The heading's `show` rule never set this gap: the `below` of its
  wrapping block had no effect, and each renderer's `v()` was doing the work.
- **Broken window:** a page break after the last question left a blank last page when that
  question was on the bottom half (`000` is one page shorter now).
- Page counts otherwise unchanged (in `001` every pair still shares a page); `check-reference`
  passes for both.

**Owner check (2026-11-15):** verified on paper. One change asked for:

### Answer line near the bottom (owner, 2026-11-15)

A cipher's "Answer: ____" line (only the complete columnar has one) sits 3em above the bottom of
its container: the middle of the page for a top question, the bottom margin for a bottom one.
Before, a fixed `v(12em)` left it in the middle of the work area.

- A top question that fits in half the page becomes a block of exactly that height (instead of
  content plus padding), so a `v(1fr)` inside it fills down to the middle. A bottom question is
  followed by a page break, so a `v(1fr)` there fills down to the bottom margin already.
- The columnar's `v(12em)` becomes `v(1fr)`, and `v(3em)` follows the answer line.

**Result:** done; the answer line sits just above the middle (top question) or the bottom margin
(bottom question). Page counts unchanged, `check-reference` passes for `001` and `000`.

**Owner check (2026-11-15):** verified.

## Render pass: fonts — 2026-11-15

Step 2 of the render pass, third slice: the body font, the monospace font (ciphertext, `[P points]`,
table labels), and their sizes. Line breaking comes later.

### What the references do

- **Toebes's PDF.** Arial (regular, bold, italic) for body text; Courier New (regular and bold) for
  ciphertext and labels. A few symbol fonts (Segoe UI Symbol, JuliaMono) for special glyphs.
- **Sister attempt** (`src/driver.py`): Arial at 0.9 scale for body; MesloLGS NF at 1.1 scale for
  monospace.
- **Ours.** No body font is set, so Typst's default, Libertinus Serif (a serif), is used by
  accident. `"Courier New"` is named about 40 times across `render/main.typ`,
  `render/common/common.typ` and 8 cipher renderers, each with its own size. The base size is
  11pt in `main.typ`.
- **What a browser build has.** Typst's WASM build only has the fonts it embeds (Libertinus Serif,
  New Computer Modern, DejaVu Sans Mono) plus any we ship. Courier New and Arial are Microsoft
  fonts we can't redistribute.

### What we'll do

1. **One place names the fonts:** `render/common/fonts.typ` with `body-font`, `title-font` and
   `mono-font`; `main.typ` sets the body font, the page header's title uses `title-font` (so will
   the cover page, later), and every renderer uses `mono-font` instead of `"Courier New"`. Sizes
   stay where they are in this slice (each kind's sizes are question-dependent, step 3).
2. **Ship the fonts in the repo** (`fonts/`, with the OFL license file) and compile with
   `--font-path fonts --ignore-system-fonts`, so the local build uses exactly what a browser build
   will.

### Decided (owner)

1. **All Noto** (SIL OFL): Noto Serif for body text, Noto Sans for titles, Noto Sans Mono for
   monospace. The owner prefers a serif for body text (sharper edges) and a sans for titles. Typst
   embeds no sans font, so one family had to be bundled anyway; one design for all three was
   preferred over Libertinus Serif + DejaVu Sans Mono (both built into Typst) + a bundled sans.
2. **Keep the monospace sizes.** A slashed zero was considered: Courier New has none, nor does
   DejaVu Sans Mono (its `zero` feature does nothing). Digits only appear in number ciphertexts,
   which hold no letter O, so it isn't needed. Courier New and DejaVu Sans Mono are equally wide
   (0.600 vs 0.602 em) but DejaVu's capitals are a third taller; a smaller size to match heights
   would make it narrower than the boxes, so sizes stay and the letters just read larger.

### Result

Done, pending the owner's check on paper.

- `render/common/fonts.typ` names `body-font`, `title-font`, `mono-font` and `body-size`; no
  renderer names a font any more (the `'Courier New'` strings left in `common.typ` match Toebes's
  HTML, they don't choose a font). A first commit routed everything through it with the old fonts
  and gave identical output; the switch to Noto was the second.
- `fonts/` holds Noto Serif (regular, bold, italic, bold italic), Noto Sans and Noto Sans Mono
  (regular, bold), with `OFL.txt`. `compile.sh` passes `--font-path fonts --ignore-system-fonts`.
- **Body size 10pt, not 11pt.** Noto Serif's x-height is 25% larger than Libertinus's and its text
  runs 16% wider; at 11pt one bottom aristocrat no longer fit and its Replacement row spilled onto
  a page of its own (17 pages for `001`, 12 for `000`). 10pt is near Libertinus 11pt on the page
  (a width match would be about 9.5pt) and restores 16 and 11 pages; 10.5pt also fits.
- **The question heading takes `body-size`** instead of its own fixed 11pt, so one setting sizes
  the question text. Monospace sizes in the renderers are unchanged: Noto Sans Mono is as wide as
  Courier New, so line breaks and box widths are the same.
- **Symbols fall back to Libertinus Serif** (built into Typst, so a browser build has it): the
  symbol baconian glyphs (★ ♩ ♪ ♫ ♬ ●) and combining accents aren't in Noto. Libertinus drew them
  before too. A P with a combining tilde (no precomposed form) now sits right; under Courier New
  the tilde sat beside it.
- **`check-reference`:** `000` passes. `001` reports its accent-symbol baconian as NOT FOUND: the
  PDF's text layer maps both glyphs of each P + combining tilde to the whole cluster, so
  pdftotext reads every one twice (10 of 10). The page shows each once; checked by eye.

**Found, not fixed:** a bottom question too tall for the rest of its page is split across pages
(the 11pt try split an aristocrat's table), though "Render pass: spacing" decided it moves to the
next page. Only the top question is measured. Backlog.

**Owner check (2026-11-15):** reviewed on paper. The fonts stay; the P with a combining tilde now
prints right, and the music symbols read better than Toebes's. The owner's UI notes from this
review (crib size among them) are in
[2026-11-15-render-pass-ui-worklist.md](2026-11-15-render-pass-ui-worklist.md), which now sets the
order of the rest of the render pass.

## Render pass: points label and cribs — 2026-11-15

Worklist items 1 and 2 ([2026-11-15-render-pass-ui-worklist.md](2026-11-15-render-pass-ui-worklist.md)):
both in the question heading's fonts.

### What we found

- **`[P points]`:** `[` and `points]` are at 0.85em, `P` bold at 1em, so the brackets look small
  beside it.
- **Cribs:** the two fonts aren't the cause. Measured from the font files (OS/2): Noto Serif cap
  height 0.714 em, x-height 0.536; Noto Sans Mono 0.714 and 0.536 (bold: 0.546). At the same size
  they match. The cause is Typst's built-in rule that sets `raw` text at **0.8em**: question text
  marks monospace runs with `raw` (`runs-to-content`, and `html-to-typst` for the legacy
  cryptarithm), so cribs print at 8pt in 10pt text.

### What we'll do

1. **`[P points]`:** `[`, `P` and `]` at 1em; only `P` bold. `points` stays at 0.85em.
2. **Cribs:** monospace runs in question text become `text(font: mono-font, weight: "bold")` at
   the surrounding size (1em: the cap heights already match), not `raw`. Other `raw` uses (the
   renderers' own labels) keep their sizes: the worklist limits this to question text.

### Result

Done, pending the owner's check on paper.

- **`[P points]`:** brackets at 1em, regular; `P` bold; `points` at 0.85em.
- **Cribs:** a `mono-run` helper in `render/common/common.typ` (bold Noto Sans Mono at the
  surrounding size) replaces `raw` in `runs-to-content` and in `html-to-typst`'s tag table. A crib
  now stands as tall as the serif capitals beside it. The renderers' own `raw` labels are unchanged.
- Page counts unchanged for `001` and `000`. `check-reference` passes for `000`; `001` reports
  only its known accent-symbol baconian (see "Render pass: fonts").
