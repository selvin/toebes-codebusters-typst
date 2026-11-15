// ============================================================================
// CHECKERBOARD CIPHERS
// Cipher units (row letter + column letter) beside an empty 6×6 grid, as in Toebes's PDF
// ============================================================================

#import "common.typ": *

// Empty 6×6 grid, no headers: the student fills in the keywords and the square
#let render-checkerboard-grid() = table(
  columns: (2.4em,) * 6,
  rows: 1.6em,
  stroke: 0.5pt + black,
  ..([],) * 36
)

// One line of blocks, each block's units spaced apart, with room below for the answer
#let render-checkerboard-line(line) = block(below: 2.8em, {
  set text(font: "Courier New", weight: "bold", size: 12pt)
  line.map(b => b.join(h(0.5em))).join(h(1.2em))
})

// Render a checkerboard prepared by prepare/ (questions.json); never sees plaintext
// lines: lines → blocks → tokens; the first three lines sit beside the grid
#let render-checkerboard-prepared(q) = {
  prepared-heading(q)

  v(1em)
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    q.lines.slice(0, calc.min(3, q.lines.len())).map(render-checkerboard-line).join(),
    render-checkerboard-grid(),
  )
  for line in q.lines.slice(calc.min(3, q.lines.len())) {
    render-checkerboard-line(line)
  }
}
