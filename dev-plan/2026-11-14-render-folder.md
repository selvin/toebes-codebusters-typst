# Move the Typst code under `render/`

**Date:** 2026-11-14
**Status:** **Done** 2026-11-14. Text, `check-reference` and every page image of
`competitiondata/001` are identical before and after.
**Related:** [2026-11-14-competition-ready-pdf-by-nov-30.md](2026-11-14-competition-ready-pdf-by-nov-30.md)
(render pass, before step 2)

## Goal

All Typst code moves out of the repo root into `render/` (owner), next to `prepare/`. A refactor
only: **the compiled PDF must not change.**

## Target tree

```
render/
  main.typ            — entry point (today's main.typ)
  common/common.typ   — shared helpers (today's common.typ, not split: nothing yet calls for it)
  ciphers/            — one .typ per cipher type, names unchanged:
                        affine, aristocrats, atbash, baconian, caesar, checkerboard, columnar,
                        cryptarithm, fractionated-morse, homophonic, nihilist, patristocrats,
                        porta, unknown
```

`compile.sh`, `prepare/`, `build/` and `dev-plan/` stay where they are.

## What changes besides the move

- **Imports.** `main.typ`: `common/common.typ`, `ciphers/<name>.typ`. Each cipher:
  `../common/common.typ`.
- **Project root.** Typst's root defaults to the entry file's folder, so `render/main.typ` could
  not read `build/questions.json` or the export. `compile.sh` passes `--root .` (repo root), and
  the input paths become root-absolute: `/build/questions.json`, `/$EXPORT`. The defaults in
  `main.typ` change the same way (`/build/questions.json`, `/input.json`). The export must still be
  inside the repo, as today.
- **Docs.** `CLAUDE.md` ("Repository layout"), `README.md` (usage text) in a separate commit. The
  "Running it" section of the competition-ready plan names only `compile.sh`, so it stays.

## Gotchas found

- `input.json` and `main.pdf` at the repo root are untracked and gitignored (`input.json`,
  `*.pdf`). They are left alone; `compile.sh`'s defaults still point at them.
- `patristocrats.typ` is dead: `main.typ` doesn't import it, and the `render-patristocrat` it uses
  lives in `aristocrats.typ`. It moves with the rest; removing it is the owner's call, as its own
  commit.

## Check

Compile `competitiondata/001` before and after (scratchpad output). `pdftotext -layout` of both
must be identical, rendered pages must match pixel for pixel, and `check-reference` must pass as
before.

## Commits

1. This plan.
2. The `git mv` with only the path fixes it needs (one commit, so history follows the files).
3. Doc updates (`CLAUDE.md`, `README.md`).

## Decisions — 2026-11-15 (patristocrat proxy)

The dead `patristocrats.typ` becomes a light proxy instead of being deleted (owner). Both old
`render-patristocrat` copies (it and the one in `aristocrats.typ`) printed the export's
`cipherString`, which is the plaintext. Patristocrats in `competitiondata/001` never reached them
(`prepare` made them `kind: "aristocrat"`), but a non-English patristocrat, which `prepare` still
leaves legacy, would have printed its answer.

1. `prepare` gives patristocrats `kind: "patristocrat"` (same data as an aristocrat).
   `render/ciphers/patristocrats.typ` has `render-patristocrat-prepared(q)`, which calls
   `render-aristocrat-prepared(q)` for now: patristocrat layout lands there in the render pass.
   `main.typ` dispatches the new kind to it. The PDF must not change. `check-reference` needs no
   change (it compares anything with `ciphertext`).
2. Both old `render-patristocrat` copies and their legacy branch go. A legacy patristocrat falls
   through to `render-unknown`. Its own commit, since it changes what unsupported input does.
3. `render-unknown` stops printing `cipherString` as "Debug Info" (it leaks the answer for any
   unsupported type). Its own commit.
