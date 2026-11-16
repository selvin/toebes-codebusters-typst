# Toebes CodeBusters Typst

Renders a Codebusters test exported from [toebes.com](https://toebes.com) as JSON into a
competition-ready PDF, with cleaner styling than the PDF Toebes prints, and an answer key for
graders.

**Status (2026-11-16):** ready for competitions as a command-line tool: the question paper prints no
plaintext (every compile checks that), and the answer key is built. A browser version on
codebusters.site is later work. See [dev-plan/README.md](dev-plan/README.md).

## Usage

Requires [Typst](https://github.com/typst/typst/releases) (developed on 0.14.2) and Node.js
(developed on 23).

```sh
./compile.sh path/to/export.json out.pdf   # defaults: input.json, main.pdf; key: out-key.pdf
```

Run it from the repo root, with the export inside the repo. It runs `prepare/` (TypeScript), which
writes `build/questions.json` (the question paper's input: nothing a student may not see) and
`build/answers.json` (the answer key's), then `typst compile` on `render/main.typ` (the question
paper) and `render/key.typ` (the answer key). The build fails if the question paper prints a run of
plaintext. Typst uses only the fonts in `fonts/` (Noto Serif, Sans and Sans Mono,
SIL Open Font License, see `fonts/OFL.txt`) and its own built-in ones, never the system's, so a
build looks the same on every machine and in a browser. `cd prepare && npm test` runs the unit
tests.

`input.json`, `build/` and `*.pdf` are gitignored. Test exports contain the answers, so keep them
out of git.
