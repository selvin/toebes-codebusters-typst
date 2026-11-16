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
Porta and nihilistsub (decode) followed, verified by the owner on paper. Baconian (all three modes)
and compcolumnar (decode) followed, also verified on paper. Checkerboard (decode, crypt) followed,
also verified on paper. Homophonic (decode, crypt) followed; the owner verified the packet through its first question. Nihilistsub crypt
followed; verified on paper up to the first fractionated morse question. Fractionated morse,
patristocrat, the xenocrypt, atbash and caesar followed: **the packet doesn't leak, and the owner
verified every question's logic on paper.** Only cryptarithm is still legacy (no leak).
**The render pass** is under way: step 1, global (page header and footer), is done and verified by
the owner. The Typst code now lives under `render/`. Step 2,
question-independent formatting, has its first slice: the question heading (circled number,
monospace points), verified by the owner. Spacing (heading-to-body gap, half-page layout that
can't overlap) is done and verified by the owner; so is the follow-up (answer line near the bottom of
its half page). Fonts are done and verified: all Noto (serif body at 10pt, sans titles, sans
mono), bundled in `fonts/`, system fonts ignored. **Next:** the owner's UI notes, in sessions of 1–3
items. Sessions A (points label, crib size), B (timed question in a double outline on its own page) and C
(nihilist and checkerboard tables at Toebes's size) are done and verified. Session D (baconian writing
space; columnar five blocks a line, back on half a page) is done; the columnar's half-page version
is pending the owner's check. Next, session D2: top questions give spare room to the question below,
by kind (owner's estimates):
[2026-11-15-render-pass-ui-worklist.md](2026-11-15-render-pass-ui-worklist.md).

## Index

| Date | Doc | Status |
|------|-----|--------|
| 2026-11-14 | [Competition-ready question paper by 2026-11-30](2026-11-14-competition-ready-pdf-by-nov-30.md) | Active |
| 2026-11-14 | [Split: TypeScript prepares, Typst lays out](2026-11-14-ts-prepare-typst-layout-split.md) | Decided |
| 2026-11-14 | [Move the Typst code under `render/`](2026-11-14-render-folder.md) | Done |
| 2026-11-15 | [Render pass: UI worklist](2026-11-15-render-pass-ui-worklist.md) | Active |

## Backlog

- **Typst reports in codebusters-site.** A per-team report and an overall ranking report, made with
  Typst from the scores graders already enter there. Likely the first way Typst enters the
  codebusters-site codebase: inside an existing utility, rather than as a new one. Its own design
  doc when picked up.
- **Question-paper tool on codebusters.site**: upload a Toebes JSON, get the question paper.
  Runs `prepare` plus Typst (WASM) in the browser; `prepare/` moves into codebusters-site then.
  After the November deadline.
- **Answer key and cover page** if they miss the deadline (Toebes's answer key is the fallback).
- **A question that moves to the next page should take its top slot**, so the next question can
  follow below it. Today it sits alone. Nothing moves in `001` or `000` now; part of session D2.
- **2027-season cipher types not in `competitiondata/001`**, each on its own when a real test needs
  it. Only 2027-season types and later are supported (owner): affine and K2 alphabets are out.
- **A committed test fixture**: a made-up export in `testdata/`, so the full pipeline can be tested
  in the repo. Real tests never go in git, even after they are held (`CLAUDE.md`, "Hard rule").
