# Render pass: UI worklist — 2026-11-15

The owner's review of the packet after the fonts slice (2026-11-15), plus the render-pass notes left
earlier in the competition-ready plan's detail sections, in one list. Each item is done as its own
slice, following the "Render pass: …" pattern in
[2026-11-14-competition-ready-pdf-by-nov-30.md](2026-11-14-competition-ready-pdf-by-nov-30.md):
references, plan, owner's choices, result, owner check. A slice's write-up goes in that plan; this
file only tracks what's open and the order. Tick an item here when its slice is verified.

Items are numbered for reference only; the sessions below set the order.

## Question-independent (step 2)

1. ✅ **`[P points]`:** the bold, larger `P` sits badly against the small brackets. Set `[` and `]`
   at the same size as `P`, not bold (`points` stays as it is).
2. ✅ **Cribs in question text:** text the test setter marked monospace (bold) now looks smaller than
   the Noto Serif around it. Make it larger, in that case only: monospace runs inside question text
   (`runs-to-content`, and `html-to-typst` for the legacy kind).
3. ✅ **Timed question: its own page, in a double outline.** Toebes lets another question share its
   page; the owner thinks that's wrong: the timed question usually goes to the team's aristocrat
   specialist, so every other question should be on pages other team members can take. The double
   outline makes that page stand out.
4. **Line breaking** (the planned last slice of step 2), from the detail sections' notes: porta
   wraps at 35 characters where Toebes fits more blocks per line; the patristocrat fits nine
   blocks a line where Toebes fits eight; a closing period can wrap onto a line of its own with its
   answer row (atbash, caesar, from `smart-line-break`; fixed 2026-11-15: a word ending a sentence
   now wraps whole when it doesn't fit). Re-check each with Noto Sans Mono.

## Question-dependent (step 3)

5. ✅ **Nihilist substitution: table 40% larger.** Ours is about 40% smaller than Toebes's. The
   larger table still sits beside only three ciphertext lines, so those lines get more line spacing:
   more room to write in place. (Earlier notes: Toebes gives the ciphertext more vertical room and
   spaces values wider.)
6. ✅ **Checkerboard: same as 5.** Table 40% larger, still beside only three ciphertext lines.
7. ✅ **Baconian (words): about 1.5 lines of writing space under each line**; students write larger
   than the printed font.
8. ✅ **Complete columnar: 5 groups of 5 letters per line**, which leaves a clear area on the right
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
10. ✅ **Cryptarithm: Toebes's layout** (verified on paper 2026-11-15; follow-up is item 12), as
    close as possible: the equation as grade-school addition
    (one operand per line, a rule under them), the values to decode, and the letter × digit (0–9)
    work grid. Solution boxes are **individual boxes styled like ours elsewhere**. Toebes's `+` and
    `=` sit out of line with the operands: don't copy that.

11. **Steal space from the top question by kind** (owner, 2026-11-15), to save paper. Many kinds
    rarely need their half page (fractionated morse answers are written in line, under the
    ciphertext). Give each top question a minimum height, the rest of its half page going to the
    question below, which can grow into it. Spare share of the half page, the owner's estimates:

    | Kind | Spare |
    |------|-------|
    | Atbash, caesar, porta, 2 lines | 40% |
    | Atbash, caesar, porta, 3 lines; aristocrats and variants, 2 lines | 20% |
    | Aristocrats and variants, 3 lines | none |
    | Baconian, any mode, 4 lines | 5% |
    | Baconian, any mode, 5 lines | none |
    | Nihilist substitution, checkerboard, 4 lines | 20% |
    | Nihilist substitution, checkerboard, 5 lines | 8% |
    | Fractionated morse, 4 lines | 30% |
    | Fractionated morse, 5 lines | 20% |
    | Complete columnar, cryptarithm, homophonic | none |

    Track which kinds overflow their half page in practice, and refine the table from that.

12. **Cryptarithm value boxes: individual, by reusing the atbash/caesar box** (owner, 2026-11-15).
    Ours touch and share an edge; the dual-box kinds' boxes stand apart with a small gap. Keep the
    digit boxed (owner). `render-char-dual-box` boxes only letters (an atbash keeps a plaintext
    digit outside the boxes), so give it a way to box digits too, then use it for the values.
13. **Box outlines at 60% black** (owner, 2026-11-15), instead of black: answer boxes and tables
    (dual boxes, cryptarithm values and work grid, aristocrat, nihilist, checkerboard, fractionated
    morse tables). Plan which strokes count (rules and the timed question's double outline
    likely not), and define the colour once in `common`.

14. **Ciphertext a little less bold** (owner, 2026-11-15): a weight a tad below the usual bold,
    for legibility and to save ink. The ciphertext is `mono-font` at `weight: "bold"` (about 30
    places in `render/`). `fonts/` bundles only Noto Sans Mono Regular and Bold, so a lighter weight
    means bundling another static weight (SemiBold 600 or Medium 500, OFL) or the variable font,
    and naming the weight once in `render/common/fonts.typ`. Show the owner the candidates side by
    side before choosing. Wider letters at a lower weight could move line breaks: check page
    counts.

## Confirmed, nothing to do

- **Baconian combining marks:** the P with a combining tilde now prints its mark on the P (fixed
  by the switch to Noto; the owner confirmed on paper). Closes the "Render-pass bug" in the plan's
  "Baconian detail".
- **`check-reference`'s NOT FOUND on `001`'s accent-symbol baconian** no longer shows (2026-11-15;
  see the plan's "Cryptarithm detail", Result). The owner checked that question on paper
  (2026-11-15): each P carries one tilde, and the symbols match Toebes's. When a change touches the
  symbol baconian's path (its `prepare` mode or `render/ciphers/baconian.typ`), check it by eye once
  more.
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
| F | 10 | The largest; cryptarithm is still a legacy kind |
| F2 | 12, 13 | Both in box styling; small, and most pages show box outlines, so ahead of D2 |
| H | 14 | The owner's pick to start the next session; every page shows ciphertext |
| D2 | 11 | Top questions give spare room to the one below; a question moved to the next page takes its top slot |
| E | 9 | Shared table helper with the aristocrats; widest change in step 3 |
| G | 4 | Line breaking, after the kinds' own layouts settle |

Line breaking moved last: items 5–9 change line widths in their kinds anyway. **F moved ahead of
D2 (owner, 2026-11-15):** the unfinished cryptarithm is jarring on every scroll through the packet.
