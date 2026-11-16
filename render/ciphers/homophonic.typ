// ============================================================================
// HOMOPHONIC CIPHERS
// Cipher values in blocks, then Toebes's help table, as in Toebes's PDF
// ============================================================================

#import "../common/common.typ": *

// One line of blocks, each value in a fixed-width cell, with room below for the answer
#let render-homophonic-line(line) = block(below: 2.8em, {
  set text(font: mono-font, weight: cipher-weight, size: 12pt)
  line.map(b => b.map(v => box(width: 1.6em, align(center, v))).join(h(0.3em))).join(h(1.2em))
})

// Help table: header rows (1–00 in four rows, or the 25 letters), then four empty rows
#let render-homophonic-table(header) = {
  let heads = if header == "numbers" {
    range(1, 101).map(i => if i == 100 { "00" } else { str(i) })
  } else {
    "ABCDEFGHIKLMNOPQRSTUVWXYZ".clusters().map(c => if c == "I" { "I/J" } else { c })
  }
  table(
    columns: (1fr,) * 25,
    rows: 1.6em,
    align: center + horizon,
    inset: 2pt,
    stroke: if header == "numbers" { 0.5pt + box-stroke-color } else { (x, y) => if y > 0 { 0.5pt + box-stroke-color } },
    ..heads.map(h => text(font: mono-font, size: 7pt, weight: "bold", h)),
    ..([],) * 100
  )
}

// Render a homophonic prepared by prepare/ (questions.json); never sees plaintext
#let render-homophonic-prepared(q) = {
  prepared-heading(q)

  for line in q.lines {
    render-homophonic-line(line)
  }
  render-homophonic-table(q.header)
}
