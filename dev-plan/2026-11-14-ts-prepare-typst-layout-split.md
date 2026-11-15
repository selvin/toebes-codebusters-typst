# Split: TypeScript prepares, Typst lays out

**Date:** 2026-11-14
**Status:** **Decided 2026-11-14** (see Decisions below).
**Related:** [2026-11-14-competition-ready-pdf-by-nov-30.md](2026-11-14-competition-ready-pdf-by-nov-30.md)

---

## The original reasoning (2025-11)

Do the whole job in Typst, so that one day an offline web page can embed a Typst interpreter
(perhaps cross-compiled to JavaScript). Anyone uploads their Toebes JSON and gets the question
paper and answer paper back. No server, no install.

## What still holds, and what doesn't

**The goal holds.** An offline, upload-and-download page on codebusters.site is right for this
tool: test files hold answers, and none of it should go to a server.

**The premise no longer needs "all in Typst".** The Typst compiler already runs in the browser as
WebAssembly (e.g. the `typst.ts` project), so nothing has to be cross-compiled. JavaScript is
already on that page anyway. So the question is only *where each part of the work is easiest to do
correctly*, and both sides are available offline.

**Typst is a poor home for the cipher logic.** Evidence from the current code:

- Most renderers print `cipherString`, which is the **plaintext**. Only atbash and caesar encode.
  Most types leak the answer today.
- The remaining types are real algorithms: homophonic (uses the stored `randomSlot`), checkerboard,
  fractionated morse, nihilist, complete columnar, three baconian modes, cryptarithm number
  encoding, K1/K2/K3 alphabets. Typst has no unit tests, weak string handling, and is slow in
  loops. Bugs here are silent and give away answers.
- Toebes itself is written in TypeScript. Its encoders are the definition of "correct". Matching
  them is far easier in the same language, whether we port code (check the toebes/ciphers license
  first) or reimplement against it.
- codebusters.site is React + TypeScript + Vite, so a TS module drops straight in.

**Typst is the right home for layout.** Page geometry, boxes, tables, fonts, half-page placement,
line wrapping by measured width: this is what Typst does well, and it's why the output can look
better than Toebes's browser-printed PDF.

## Proposal

```
Toebes JSON ──► prepare (TypeScript) ──► model.json ──► Typst templates ──► test.pdf
                                                                       └──► answers.pdf
```

- **prepare** (TS, pure functions, unit-tested, runs in Node and the browser): orders questions
  (`TEST.0.timed`, then `TEST.0.questions` in order, numbered 1…n); computes ciphertext and
  everything derived from it (frequency counts, cipher units, numbers); turns the question HTML into
  simple text runs (bold / italic / mono); emits the answer data (plaintext, key, alphabets).
- **model.json** is the contract. One entry per question with its number, points, special bonus
  flag, question text runs, a `kind` that picks the Typst renderer, and the kind's data. No HTML and
  no plaintext in the parts the test packet uses.
- **Typst** reads only `model.json`. It decides how things look and where they break. The test and
  the answer key are two entry points. (Superseded by Decision 1: two separate inputs, so the
  question paper never receives answers.)

Rule of thumb for the boundary: **if a wrong answer would change what a student must solve, it
belongs in TS. If it only changes how it looks, it belongs in Typst.**

Line wrapping stays in Typst (it depends on measured width). The current character-count
`smart-line-break` can stay until it causes trouble.

## Consequences

- The website later is a thin shell: file input → `prepare` → typst.ts → download. No new design.
- For November we run the same pipeline from the command line (`node`/`tsx` + `typst compile`).
  The website is a separate piece of work after the deadline.
- Verification gets cheap: unit tests can assert our ciphertext equals the text in the Toebes
  reference PDF, question by question.
- Fonts: Courier New isn't available in a browser build. Pick open-licensed fonts and bundle them
  (codebusters-site already ships Noto Sans / Serif / Mono). Owner decision; not blocking for the
  CLI.

## Open questions (answered in Decisions below)

1. Confirm the split.
2. Where the TS lives: a `prepare/` folder in this repo (proposed), later imported by
   codebusters-site; or in codebusters-site from the start.
3. Fonts for the printed packet.

## Decisions — 2026-11-14

1. **Split confirmed.** The clincher is test security, not convenience: the question-paper
   template receives only what a student may see, so nothing in Typst can leak an answer, whatever
   bug a template has. `prepare` writes two inputs:
   - `questions.json` — for the question paper. Ciphertext, question text, points, numbering,
     derived data (frequency counts etc.). **No plaintext, no keys, no `cipherString`.**
   - `answers.json` — for the answer key only.

   `main.typ` (or its successor) must never read the raw export again once a cipher moves over.
2. **The answer key is low priority.** Only graders see it, so looks matter little. It's trivial
   next to the question paper, and if it isn't done by the deadline the Toebes answer key is the
   fallback.
3. **The TypeScript lives in `prepare/` in this repo.** Moving it into codebusters-site is later
   work, done with the website.
4. **Fonts:** not decided; not needed for the CLI.
