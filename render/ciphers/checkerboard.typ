// ============================================================================
// CHECKERBOARD CIPHERS
// Cipher units (row letter + column letter) beside an empty 6×6 grid, as in Toebes's PDF
// ============================================================================

#import "../common/common.typ": *

// Empty 6×6 grid, no headers: the student fills in the keywords and the square
#let render-checkerboard-grid() = table(
  columns: (3.75em,) * 6,
  rows: 2.25em,
  stroke: 0.5pt + box-stroke-color,
  ..([],) * 36
)

// One line of blocks, each block's units spaced apart
#let render-checkerboard-line(line) = {
  set text(font: mono-font, weight: "bold", size: 12pt)
  line.map(b => b.join(h(0.5em))).join(h(1.2em))
}

// Render a checkerboard prepared by prepare/ (questions.json); never sees plaintext
// lines: lines → blocks → tokens; the first three lines sit beside the grid
#let render-checkerboard-prepared(q) = {
  prepared-heading(q)
  lines-beside-grid(q.lines.map(render-checkerboard-line), render-checkerboard-grid())
}
