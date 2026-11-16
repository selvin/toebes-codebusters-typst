# Dev Plan

Planning and decision documents for `toebes-codebusters-typst`. How this folder is used:
`CLAUDE.md`, "Working method".

## Current status (2026-11-16)

**The competition-ready initiative is resolved** (owner, 2026-11-16):
[2026-11-14-competition-ready-pdf-by-nov-30.md](2026-11-14-competition-ready-pdf-by-nov-30.md).
`compile.sh` turns a Toebes export into the question paper and an answer key. `prepare/` (TS) does
the cipher logic and writes `build/questions.json` (nothing a student may not see) and
`build/answers.json`; Typst lays out `render/main.typ` (the paper) and `render/key.typ` (the key,
[2026-11-16-answer-key.md](2026-11-16-answer-key.md)). Every compile fails if the paper prints a
run of plaintext. Both real tests in `competitiondata/` render, verified by the owner.

**Scope and order (owner, 2026-11-16):** Divisions A and B only; **Division C is out of scope**.
Production on codebusters.site comes first, in this order: the team's own scorecard reports in
Typst (Backlog, first item), then the question-paper tool. The 2026–27 rules gaps
([2026-11-16-rules-summary-2026-27.md](2026-11-16-rules-summary-2026-27.md)) are worked on after.

**Next: work moves to the codebusters-site repo** (`~/workspace/codebusters-site`, plan
`plan/2026-11-16-Typst-Reports-and-Paper-Tool.md`): Typst reports first. Back here later: slice 2
of the test fixture ([2026-11-16-test-fixture.md](2026-11-16-test-fixture.md)), a one-command check
of the pipeline on `testdata/0000`.

## Index

| Date | Doc | Status |
|------|-----|--------|
| 2026-11-14 | [Competition-ready question paper by 2026-11-30](2026-11-14-competition-ready-pdf-by-nov-30.md) | Resolved |
| 2026-11-14 | [Split: TypeScript prepares, Typst lays out](2026-11-14-ts-prepare-typst-layout-split.md) | Decided |
| 2026-11-14 | [Move the Typst code under `render/`](2026-11-14-render-folder.md) | Done |
| 2026-11-15 | [Render pass: UI worklist](2026-11-15-render-pass-ui-worklist.md) | Resolved |
| 2026-11-16 | [Answer key](2026-11-16-answer-key.md) | Resolved |
| 2026-11-16 | [A committed test fixture](2026-11-16-test-fixture.md) | In progress |
| 2026-11-16 | [2026–2027 season: which ciphers each division uses](2026-11-16-rules-summary-2026-27.md) | Record |

## Backlog

- **Typst reports in codebusters-site** (first, per the order above). A per-team report and an overall ranking report, made with
  Typst from the scores graders already enter there. Likely the first way Typst enters the
  codebusters-site codebase: inside an existing utility, rather than as a new one. Its own design
  doc when picked up.
- **Question-paper tool on codebusters.site**: upload a Toebes JSON, get the question paper.
  Runs `prepare` plus Typst (WASM) in the browser; `prepare/` moves into codebusters-site then.
  After the reports.
- **Cover page for the question paper** (the answer key has its own).
- **Questions that flow, three on a page when they fit** (worklist item 11, parked 2026-11-15), and
  with it: a question that moves to the next page takes its top slot. Two a page is already the
  fewest pages; flowing saves pages only with less writing room than the owner's minimums (at most
  1 in `000`, 2 in `001`). See "Render pass: space by kind" in the competition-ready plan.
- **2027-season cipher types not in `competitiondata/001`**, each on its own when a real test needs
  it. Only 2027-season types and later are supported (owner): affine and K2 alphabets are out.
- **Baconian words: Toebes's fallback word** (owner, 2026-11-15; not for the 11-30 deadline). When a
  stored word no longer fits its letter's A/B pattern, Toebes prints the first fitting word from
  its fixed list (`app/common/fiveletterwords.ts` in `toebes/ciphers`, BSD-3). It also does this for a
  word that fits but isn't on its list (seen on the fixture, 2026-11-16). We fail loudly on a misfit,
  which is fine for now. Later: fetch the list from its raw GitHub URL periodically (keeping
  Toebes's license notice) so `prepare` can match. See "Baconian detail" in the competition-ready
  plan.
