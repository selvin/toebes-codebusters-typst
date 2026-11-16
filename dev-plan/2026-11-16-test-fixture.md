# A committed test fixture

**Date:** 2026-11-16
**Status:** Slice 1 done (owner checked `0000` by eye, 2026-11-16, Baconians 8 and 9 included).
Slice 2 waits until the codebusters-site work below is done.
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
and Toebes's PDF into `testdata/` (`testdata/0000.json`, `testdata/0000.pdf`). Why:

- Toebes fills fields at random that we can't fake faithfully by hand (`replacement` for random
  alphabets, homophonic `randomSlot`, Baconian `words`, cryptarithm `mapping`). A hand-written
  export would test our idea of the format, not the format.
- Toebes's PDF lets `check-reference` run on the fixture, as it does on the real tests.

Alternative: a script writes the JSON. Cheaper for the owner, but no reference PDF and a risk of
drifting from what Toebes really writes.

## Questions (each one hits something)

Division **B**, state level (`bstate`): crypt questions are allowed there, and the cryptarithm
takes the zero-error path in the key.

| # | Kind / settings | Quote (author) | Hits |
|---|-----------------|----------------|------|
| T | Aristocrat, K1 | "Be yourself; everyone else is already taken." (Wilde) | timed question, semicolon |
| 1 | Aristocrat, random | "Two things are infinite: the universe and human stupidity; and I'm not sure about the universe." (Einstein) | apostrophe, colon |
| 2 | Aristocrat, K1 (misspelling dropped) | "Nothing in life is to be feared, it is only to be understood. Now is the time to understand more, so that we may fear less." (Curie) | the longest answer (key wraps) |
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
| 19 | Cryptarithm | SEND + MORE = MONEY, answer DRY ROSES MEND | `soltext` answer, Division B zero errors |
| 20 | Aristocrat, random | "Be the change that you wish to see in the world." (Gandhi) | repeat |
| 21 | Aristocrat, K1 | "A room without books is like a body without a soul." (Cicero) | repeat |
| 22 | Patristocrat, K1 | "The saddest aspect of life right now is that science gathers knowledge faster than society gathers wisdom." (Asimov) | repeat |
| 23 | Complete columnar | "To live is the rarest thing in the world. Most people exist, that is all." (Wilde) | repeat, 7 columns |
| 24 | Cryptarithm | BASE + BALL = GAMES, answer SMALL BEAGLES | repeat |

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
- **The owner imports it into toebes.com** to make Toebes's PDF (`testdata/0000.pdf`), which
  shows whether Toebes reads our JSON as we do, and lets `check-reference` run on it. If the owner
  fixes anything in Toebes, Toebes's re-export replaces `0000.json`.
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
Toebes, and Toebes's re-export then replaces `0000.json`.

## Decisions — 2026-11-16 (owner: length and level)

- **A full-length test: the timed question plus 24.** Top teams now solve about 24 questions, so a
  shorter test leaves several first places with no tiebreak; real tests repeat question types.
  Added questions 20–24 (two aristocrats, a patristocrat, a complete columnar, a cryptarithm).
- **State level, Division B.** Crypt questions are allowed at state level, and the cryptarithm is
  allowed in Division B, so both stay.
- First run: 25 questions, none legacy; paper 13 pages, key 4; leak check passes.

## Decisions — 2026-11-16 (Toebes's checker, second pass)

- **No misspelled aristocrat:** Toebes doesn't allow one in Division B at any level. Question 2 is
  now spelled correctly.
- **Cryptarithm values in the question:** one group of digits per answer word, groups separated by
  spaces (e.g. `782 80959 1567`), as real tests print them. Both answers now have several words.

## Decisions — 2026-11-16 (Toebes's PDF; names)

- **Four-digit names** (owner): `testdata/0000.json` and Toebes's PDF of it, `testdata/0000.pdf`
  (committed; `.gitignore` excepts 4-digit PDFs in `testdata/`). Real tests have 3 digits, so a
  fixture can't overwrite one.
- **`check-reference` passes on `0000`**, with the symbol Baconians (8, 9) left to check by eye:
  Toebes prints their symbols as images.
- **Toebes replaces any Baconian word that isn't on its own list**, even one that fits its
  letter's code. Our first words came from a general word list, and Toebes printed its own. Question 7
  now stores the words Toebes printed (some are two words joined by a no-break space, e.g.
  "A DEAR"). See the Backlog item on Toebes's fallback word.
- `make visualcheck 0000` opens our paper, Toebes's paper and our key.

## Decisions — 2026-11-16 (round trip through Toebes)

The owner imported `0000.json` into Toebes unchanged and re-exported it over itself. Toebes kept
every field (Baconian words, alphabets, slots, mapping, points) and added none. Two changes only:
it renumbered the `CIPHER.n` ids (harmless: `prepare` follows `TEST.0`'s order), and it **dropped
`<b>` from question text**. Real exports use `<strong>`, `<i>` and `<span>`, never `<b>`. The
re-export is now the fixture, so its question text has no formatting. Putting `<strong>` back (and
round-tripping again) would let the fixture cover the HTML→Typst bold path.
