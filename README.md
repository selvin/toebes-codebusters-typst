# Toebes CodeBusters Typst

Renders a Codebusters test exported from [toebes.com](https://toebes.com) as JSON into a
competition-ready PDF, with cleaner styling than the PDF Toebes prints.

**Status (2026-11-14):** work in progress. Several cipher types still print the plaintext, so the
output is not yet safe to hand to students. See [dev-plan/README.md](dev-plan/README.md).

## Usage

Requires [Typst](https://github.com/typst/typst/releases) (developed on 0.14.2).

```sh
# Copy your exported JSON file to input.json, then:
./compile.sh          # or: typst compile main.typ

# Output is main.pdf
```

`input.json` and `*.pdf` are gitignored. Test exports contain the answers, so keep them out of git.
