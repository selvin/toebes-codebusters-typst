# Render pass: UI worklist — 2026-11-15

The owner's review of the packet after the fonts slice (2026-11-15), plus the render-pass notes left
earlier in the competition-ready plan's detail sections, in one list. Each item is done as its own
slice, following the "Render pass: …" pattern in
[2026-11-14-competition-ready-pdf-by-nov-30.md](2026-11-14-competition-ready-pdf-by-nov-30.md):
references, plan, owner's choices, result, owner check. A slice's write-up goes in that plan; this
file only tracks what's open and the order. Tick an item here when its slice is verified.

Items are numbered for reference only; the sessions below set the order.

## Question-independent (step 2)

1. **`[P points]`:** the bold, larger `P` sits badly against the small brackets. Set `[` and `]`
   at the same size as `P`, not bold (`points` stays as it is).
2. **Cribs in question text:** text the test setter marked monospace (bold) now looks smaller than
   the Noto Serif around it. Make it larger, in that case only: monospace runs inside question text
   (`runs-to-content`, and `html-to-typst` for the legacy kind).
3. **Timed question: its own page, in a double outline.** Toebes lets another question share its
   page; the owner thinks that's wrong: the timed question usually goes to the team's aristocrat
   specialist, so every other question should be on pages other team members can take. The double
   outline makes that page stand out.
4. **Line breaking** (the planned last slice of step 2), from the detail sections' notes: porta
   wraps at 35 characters where Toebes fits more blocks per line; the patristocrat fits nine
   blocks a line where Toebes fits eight; a closing period can wrap onto a line of its own with its
   answer row (atbash, caesar, from `smart-line-break`). Re-check each with Noto Sans Mono.

## Question-dependent (step 3)

5. **Nihilist substitution: table 40% larger.** Ours is about 40% smaller than Toebes's. The
   larger table still sits beside only three ciphertext lines, so those lines get more line spacing:
   more room to write in place. (Earlier notes: Toebes gives the ciphertext more vertical room and
   spaces values wider.)
6. **Checkerboard: same as 5.** Table 40% larger, still beside only three ciphertext lines.
7. **Baconian (words): about 1.5 lines of writing space under each line**; students write larger
   than the printed font.
8. **Complete columnar: 5 groups of 5 letters per line**, which leaves a clear area on the right
   for one full columnar attempt (fewer columns, more rows), and the space below the ciphertext for
   a second attempt (more columns, fewer rows). Today two attempts can run into the "Answer:" line.
9. **Fractionated morse table**, following the earlier notes ("Decisions — 2026-11-14
   (render-pass inputs)", item 2, and the detail section):
   - the Replacement row as tall as the aristocrats' Replacement row, to pencil in a letter;
   - "Morse fraction" on two lines within its one header cell (`Morse` over `fraction`; owner,
     2026-11-15), so the header column is narrower and each letter's column gets more width and a
     larger font;
   - cell padding like the aristocrats' table; **put what both tables share in `common`**;
   - ciphertext lines left-aligned (Toebes left-aligns lines inside a centered block; ours centers
     each line); use the spare width for larger letters or more space per letter.
10. **Cryptarithm: Toebes's layout**, as close as possible: the equation as grade-school addition
    (one operand per line, a rule under them), the values to decode, and the letter × digit (0–9)
    work grid. Solution boxes are **individual boxes styled like ours elsewhere**. Toebes's `+` and
    `=` sit out of line with the operands: don't copy that.

## Confirmed, nothing to do

- **Baconian combining marks:** the P with a combining tilde now prints its mark on the P (fixed
  by the switch to Noto; the owner confirmed on paper). Closes the "Render-pass bug" in the plan's
  "Baconian detail".
- **Baconian music symbols:** the owner finds ours (Libertinus fallback) more legible than
  Toebes's. Keep.

## Sessions

1–3 items each, smallest and widest-reaching first:

| Session | Items | Why together |
|---------|-------|--------------|
| A | 1, 2 | Both in the question text's fonts; every page shows them |
| B | 3 | Changes the page layout (half-page logic) |
| C | 5, 6 | Same pattern: a table beside three lines |
| D | 7, 8 | Writing space in two kinds; small each |
| E | 9 | Shared table helper with the aristocrats; widest change in step 3 |
| F | 10 | The largest; cryptarithm is still a legacy kind |
| G | 4 | Line breaking, after the kinds' own layouts settle |

Line breaking moved last: items 5–9 change line widths in their kinds anyway.
