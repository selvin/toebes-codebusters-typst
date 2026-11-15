# Move the Typst code under `render/`

**Date:** 2026-11-14
**Status:** Planned.
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
