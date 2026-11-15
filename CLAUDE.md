# toebes-codebusters-typst

Turns a Codebusters test exported from [toebes.com](https://toebes.com) (a JSON file) into a
competition-ready PDF: the test packet and an answer key. The end state is a browser tool on
codebusters.site, next to the owner's two other utilities. See `dev-plan/README.md` for current
status and what's next.

## Repository layout

```
main.typ            — entry point; reads input.json, numbers questions, dispatches by cipherType
common.typ          — shared helpers (question heading, HTML→Typst, line breaking, dual boxes)
<cipher>.typ        — one renderer per cipher type
compile.sh          — wrapper around `typst compile main.typ`
dev-plan/           — plans and decisions (source of truth across sessions)
competitiondata/    — gitignored real competition exports and reference PDFs (hard rule below)
```

This layout is expected to change: see
[dev-plan/2026-11-14-ts-prepare-typst-layout-split.md](dev-plan/2026-11-14-ts-prepare-typst-layout-split.md).

## Hard rule: test content is confidential

**This repo is public, and a Toebes export holds every answer in plaintext** (`cipherString` is the
plaintext, not the ciphertext). This holds **for good, not just until the test is held**: by
custom, only the teams that attended receive a test's question and answer papers, so a real test
never becomes public (owner, 2026-11-14).

- Never commit its export, or a PDF made from one. Test files live in `competitiondata/` (gitignored),
  named by number: `competitiondata/001.json` (input), `competitiondata/001.pdf` (Toebes's own PDF of it).
- **Never write anything identifying the test into a tracked file or a commit message**: not its
  name, the tournament, its division, or which cipher sits at which question number. Refer to it
  only as `competitiondata/001`. This applies to `.gitignore` too.
- Docs may name cipher *types* the work supports, but not tie them to a test's questions.
- `competitiondata/` is for real competitions only. Safe fixtures (made-up quotes only, never a
  real test, held or not) can go in a tracked `testdata/` folder when one is needed.

**The question-paper template never receives answers.** `prepare` (TS) gives the question-paper
Typst template only what a student may see: no `cipherString`, no keys, no plaintext. Answers go to
a separate answer-key input. See
[dev-plan/2026-11-14-ts-prepare-typst-layout-split.md](dev-plan/2026-11-14-ts-prepare-typst-layout-split.md).

Compiling is fine in a session: there is no PII here. Use the scratchpad for output, not the repo.

## Philosophy

Adopted from `~/workspace/sunnystepslearning-com/CLAUDE.md` (2026-11-14). Short versions here; that
file has the full reasoning and examples.

- **Incrementalism.** One thing per commit. Refactors apart from behavior changes, renames apart
  from logic. Test: could I revert just this piece?
- **Gradualism.** Where the outcome is uncertain, build the smallest slice that gives evidence, then
  decide the next slice.
- **Keep proven-doable work off the critical path.** Build what can still surprise us first. Known
  "just work" items become launch gates, named in the dev-plan doc.
- **No unending epics.** When an effort meets its goal, mark its doc resolved. Later findings are new
  work with their own entries.
- **Broken windows.** A small defect noticed in passing gets fixed now, as its own commit.
- **Avoid speculative safety nets.** Don't build a guard when a cheap existing fallback already
  covers the risk.

## Documentation ownership

| File | Owns | Primary reader |
|------|------|----------------|
| `README.md` | What the project is; how to build and run it | Anyone landing on the repo |
| `CLAUDE.md` (this file) | Assistant instructions: navigation, working method, hard rules | Claude |
| `dev-plan/README.md` | Current status, index of plans, Backlog | Owner and Claude |
| `dev-plan/YYYY-MM-DD-*.md` | One plan or decision each | Owner and Claude |

If content fits more than one file, put it where its main reader most needs it.

**Doc changes that are small, incremental and reasonable don't need the owner's permission**
(owner, 2026-11-14). Make them and say what changed. Larger rewrites or anything that changes a
decision still get raised first.

## Working method — dev-plan as source of truth

**Write the plan in `dev-plan/` before writing code**, however small. A future session must be
able to orient from `dev-plan/` alone, without conversation history.

Write a dev-plan entry when a discussion produces a new plan or phase, a design choice with
trade-offs, a sequencing decision, or a non-obvious constraint. Name it `YYYY-MM-DD-short-slug.md`
and add a row to `dev-plan/README.md` at once. When a later discussion refines an existing plan, add
a dated `## Decisions — YYYY-MM-DD` section to it instead of starting a new file, unless the new
material stands alone.

Don't record in-progress state, conversation summaries, or what the code and git log already say.

**Memory** (`~/.claude/projects/.../memory/`) stays minimal, ideally empty. It's a pointer layer, not
a copy of dev-plan. If something firms up, move it into dev-plan or this file.

Commit messages follow the repo's existing style: `Area: what changed` (e.g. `Aristocrats: …`,
`dev-plan: …`).

## Session discipline

Work in short sessions of 1–3 tasks. Before ending one:

1. Bring any background task or subagent to a conclusion, or stop it.
2. Update dev-plan: mark finished steps, record decisions and surprises, re-sequence what's next.
   Update the Backlog in `dev-plan/README.md`.
3. Overwrite `next-session-prompt.md` (repo root, gitignored) with one self-contained prompt for the
   next session's smallest unit of work. Then print this line on its own:
   `Please follow the instructions in the untracked next-session-prompt.md at repo root`
4. Update memory only if needed.
5. Commit (and push when the owner says so).

Prompt the owner to do this after 1–3 tasks, and say which steps applied.

If "Please follow the instructions in the untracked next-session-prompt.md" arrives in a session
that has already done work, it may have been pasted by mistake. Ask the owner to confirm they mean
to continue in this session (rather than a new one) before starting.
