# Dev Plan

Planning and decision documents for `toebes-codebusters-typst`. How this folder is used:
`CLAUDE.md`, "Working method".

## Current status (2026-11-14)

Picked back up after a pause since 2025-12-15. Repo docs set up following the
`sunnystepslearning-com` conventions.

**Active:** a competition-ready question paper for `competitiondata/001` by 2026-11-30 —
[2026-11-14-competition-ready-pdf-by-nov-30.md](2026-11-14-competition-ready-pdf-by-nov-30.md).
Cipher logic moves to TypeScript (`prepare/`); Typst only lays out, and the question-paper template
never sees answers —
[2026-11-14-ts-prepare-typst-layout-split.md](2026-11-14-ts-prepare-typst-layout-split.md).
Stage 1 done: `prepare/` writes `build/questions.json`, English aristocrats render from it and match
Toebes's PDF; every other kind is still "legacy" (rendered from the raw export, and still leaking).
Next: Stage 2, the easy encoders.

## Index

| Date | Doc | Status |
|------|-----|--------|
| 2026-11-14 | [Competition-ready question paper by 2026-11-30](2026-11-14-competition-ready-pdf-by-nov-30.md) | Active |
| 2026-11-14 | [Split: TypeScript prepares, Typst lays out](2026-11-14-ts-prepare-typst-layout-split.md) | Decided |

## Backlog

- **Typst reports in codebusters-site.** A per-team report and an overall ranking report, made with
  Typst from the scores graders already enter there. Likely the first way Typst enters the
  codebusters-site codebase: inside an existing utility, rather than as a new one. Its own design
  doc when picked up.
- **Question-paper tool on codebusters.site**: upload a Toebes JSON, get the question paper.
  Runs `prepare` plus Typst (WASM) in the browser; `prepare/` moves into codebusters-site then.
  After the November deadline.
- **Answer key and cover page** if they miss the deadline (Toebes's answer key is the fallback).
- **Fonts** for a browser build: Courier New won't be available.
- **Cipher types not in `competitiondata/001`** (affine, Hill, Vigenère, etc.), each on its own when a
  real test needs it.
- **Committing a test fixture**: `competitiondata/001` stays out of git until the owner confirms the test
  has been held.
