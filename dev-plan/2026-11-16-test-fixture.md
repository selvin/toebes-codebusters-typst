# A committed test fixture

**Date:** 2026-11-16
**Status:** In progress: slice 1, `testdata/fixture.json` written; Toebes's PDF of it to come.
**Related:** `CLAUDE.md` ("Hard rule: test content is confidential"), Backlog in
[README.md](README.md)

---

## Goal

A made-up Toebes export in `testdata/`, so the whole pipeline (`compile.sh`: prepare, the paper,
the leak check, the answer key) can be run and checked in the repo, by anyone, without
`competitiondata/`.

**It tests functionality and corner cases, not paper quality** (owner, 2026-11-16). No tuning of a
quote's letter statistics to its points, no balancing of the test. Each question is there to hit a
code path.

## Quotes: from Goodreads (owner, 2026-11-16)

Short published quotes from goodreads.com, not invented text. Fine to commit: they aren't from any
real test. `CLAUDE.md` said "made-up quotes only"; it now says "never from a real test", which was
the point of the rule.

## How the export gets made

**Recommended: the owner builds it in toebes.com** from the list below, and exports both the JSON
and Toebes's PDF into `testdata/` (`testdata/fixture.json`, `testdata/fixture.pdf`). Why:

- Toebes fills fields at random that we can't fake faithfully by hand (`replacement` for random
  alphabets, homophonic `randomSlot`, Baconian `words`, cryptarithm `mapping`). A hand-written
  export would test our idea of the format, not the format.
- Toebes's PDF lets `check-reference` run on the fixture, as it does on the real tests.

Alternative: a script writes the JSON. Cheaper for the owner, but no reference PDF and a risk of
drifting from what Toebes really writes.

## Questions (each one hits something)

Division **B**, so the cryptarithm takes the zero-error path in the key.

| # | Kind / settings | Quote (author) | Hits |
|---|-----------------|----------------|------|
| T | Aristocrat, K1 | "Be yourself; everyone else is already taken." (Wilde) | timed question, semicolon |
| 1 | Aristocrat, random | "Two things are infinite: the universe and human stupidity; and I'm not sure about the universe." (Einstein) | apostrophe, colon |
| 2 | Aristocrat, random, misspelled | "Nothing in life is to be feared, it is only to be understood. Now is the time to understand more, so that we may fear less." (Curie) | the longest answer (key wraps), misspelling |
| 3 | Aristocrat, Spanish | "Por una mirada un mundo; por una sonrisa, un cielo; por un beso…¡yo no sé qué te diera por un beso!" (Bécquer) | accents (key letter count), ¡ and … |
| 4 | Patristocrat | "Any sufficiently advanced technology is indistinguishable from magic." (Clarke) | blocks of five; special bonus ★ |
| 5 | Atbash | "So many books, so little time." (Zappa) | table kind |
| 6 | Caesar | "Without music, life would be a mistake." (Nietzsche) | table kind |
| 7 | Baconian, words | "Time is a drug." (Pratchett) | one word per letter |
| 8 | Baconian, sequence | "Never memorize something that you can look up." (Einstein) | |
| 9 | Baconian, letter for letter | "Somewhere, something incredible is waiting to be known." (Sagan) | |
| 10 | Checkerboard, decode | "In the beginning there was nothing, which exploded." (Pratchett) | |
| 11 | Checkerboard, crypt | "Everything must be made as simple as possible. But not simpler." (Einstein) | |
| 12 | Nihilist, decode | "If I have seen further it is by standing on the shoulders of Giants." (Newton) | |
| 13 | Nihilist, crypt | "Always forgive your enemies; nothing annoys them so much." (Wilde) | |
| 14 | Porta | "We accept the love we think we deserve." (Chbosky) | |
| 15 | Complete columnar | "An expert is a person who has made all the mistakes that can be made in a very narrow field." (Bohr) | |
| 16 | Fractionated Morse | "That which can be asserted without evidence, can be dismissed without evidence." (Hitchens) | |
| 17 | Homophonic, decode | "If you tell the truth, you don't have to remember anything." (Twain) | numbers header |
| 18 | Homophonic, crypt | "A friend is someone who knows all about you and still loves you." (Hubbard) | letters header |
| 19 | Cryptarithm | (Toebes generates the words) | `soltext` answer, Division B zero errors |

Left out on purpose: inputs we already fail on loudly (Morse with digits or an XXX triple,
Baconian A/B sets with formatting); 2026-season-only kinds (affine, K2), which aren't supported.

## Slices

1. **The fixture.** Owner builds and exports it; it's committed in `testdata/`. Check: `compile.sh`
   runs clean on it (leak check passes, key written), `check-reference` passes, and the owner looks
   at both PDFs beside Toebes's.
2. **A one-command check.** A script (or `npm test` step) that runs the pipeline on the fixture and
   fails on any error, so a render change can be checked without the real tests. Decide its exact
   shape once slice 1 shows what's worth asserting (page counts at least).

## Decisions — 2026-11-16 (owner)

- **The question list is fine as it is.** No unsupported-kind question for `unknown.typ`.
- **Claude writes the JSON** (a one-off script, not committed), rather than the owner building it in
  Toebes. Field shapes copied from the real exports: `replacement` maps `alphabetSource[i]` →
  `alphabetDest[i]`, Baconian words carry the plaintext's punctuation (one has a no-break space),
  homophonic `randomSlot` has one entry per letter. The cryptarithm is SEND + MORE = MONEY, answer
  DRONES.
- **The owner imports it into toebes.com** to make Toebes's PDF (`testdata/fixture.pdf`), which
  shows whether Toebes reads our JSON as we do, and lets `check-reference` run on it. If the owner
  fixes anything in Toebes, Toebes's re-export replaces `fixture.json`.
- First run: all 20 questions take their own renderer (none legacy); the paper is 11 pages, the key
  4, the leak check passes, the key marks ★ on 4 and zero errors on 19.

## Decisions — 2026-11-16 (Toebes's test checker, first pass)

Toebes's checker flagged the first import. Fixed: point totals no longer end in 0 or 5; question
text says "decrypt", names K1 alphabets and the Nihilist keyword's length; the misspelled
aristocrat and the patristocrat use K1 alphabets; the special bonus moved from the patristocrat (not
allowed there) to the crypt homophonic; the Nihilist crypt keyword is short enough for its crib;
the decode homophonic has three hint letters; the cryptarithm names its values.

Left on purpose, since fixing them would drop a corner case: fewer than 22 questions, and
Division B warnings (no misspelled aristocrat, no cryptanalysis, no decode homophonic). Division B
is what puts the cryptarithm on the key's zero-error path. The owner fixes the rest by hand in
Toebes, and Toebes's re-export then replaces `fixture.json`.
