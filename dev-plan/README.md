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
verified every question's logic on paper.** Cryptarithm (additions) followed on
2026-11-15: no legacy kind is left in either test.
**The render pass** is under way: step 1, global (page header and footer), is done and verified by
the owner. The Typst code now lives under `render/`. Step 2,
question-independent formatting, has its first slice: the question heading (circled number,
monospace points), verified by the owner. Spacing (heading-to-body gap, half-page layout that
can't overlap) is done and verified by the owner; so is the follow-up (answer line near the bottom of
its half page). Fonts are done and verified: all Noto (serif body at 10pt, sans titles, sans
mono), bundled in `fonts/`, system fonts ignored. **Next:** the owner's UI notes, in sessions of 1–3
items. Sessions A (points label, crib size), B (timed question in a double outline on its own page) and C
(nihilist and checkerboard tables at Toebes's size) are done and verified. Session D (baconian writing
space; columnar five blocks a line, back on half a page) is done and verified. Session F (cryptarithm prepared, in
Toebes's layout) is done and verified. Session F2 (cryptarithm values in the atbash
box; outlines at 60% black) is done and verified. Session H (ciphertext in SemiBold) is done and verified. D2 (space by kind) is parked: two
questions a page is already the fewest pages. Session E (fractionated morse table, its lines
across the full width, filling the slot) is done and verified. Session G (line breaking: Toebes's
rule; box kinds shrink to fit) is done, pending the owner's check; it closes step 2's worklist:
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
- **Questions that flow, three on a page when they fit** (worklist item 11, parked 2026-11-15), and
  with it: a question that moves to the next page takes its top slot. Two a page is already the
  fewest pages; flowing saves pages only with less writing room than the owner's minimums (at most
  1 in `000`, 2 in `001`). See "Render pass: space by kind" in the competition-ready plan.
- **2027-season cipher types not in `competitiondata/001`**, each on its own when a real test needs
  it. Only 2027-season types and later are supported (owner): affine and K2 alphabets are out.
- **Baconian words: Toebes's fallback word** (owner, 2026-11-15; not for the 11-30 deadline). When a
  stored word no longer fits its letter's A/B pattern, Toebes prints the first fitting word from
  its fixed list (`app/common/fiveletterwords.ts` in `toebes/ciphers`, BSD-3); we fail loudly,
  which is fine for now. Later: fetch the list from its raw GitHub URL periodically (keeping
  Toebes's license notice) so `prepare` can match. See "Baconian detail" in the competition-ready
  plan.
- **A committed test fixture**: a made-up export in `testdata/`, so the full pipeline can be tested
  in the repo. Real tests never go in git, even after they are held (`CLAUDE.md`, "Hard rule").
