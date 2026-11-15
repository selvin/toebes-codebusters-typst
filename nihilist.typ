// ============================================================================
// NIHILIST SUBSTITUTION CIPHERS
// Handles nihilist substitution cipher with polybius square
// ============================================================================

#import "common.typ": *

// Render nihilist substitution cipher
#let render-nihilist(cipher, num) = {
  question-heading(num, cipher)
  
  // Display the encoded cipher text
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    #set text(font: "Courier New", weight: "bold", size: 10pt)
    #cipher.cipherString
  ]
  
  // Display keyword and polybius key
  v(0.5em)
  grid(
    columns: 2,
    gutter: 1em,
    [Keyword: #raw(upper(cipher.keyword))],
    [Polybius Key: #raw(cipher.polybiusKey)]
  )
}

// Empty 5×5 grid, headed 1–5, for the student to build the Polybius square in
#let render-polybius-grid() = {
  let header(n) = text(font: "Courier New", weight: "bold", size: 0.8em)[#n]
  table(
    columns: (1.6em,) + (2.2em,) * 5,
    rows: 1.6em,
    stroke: 0.5pt + black,
    align: center + horizon,
    [], ..range(1, 6).map(header),
    ..range(1, 6).map(r => (header(r),) + ([],) * 5).flatten()
  )
}

// One line of blocks, each value in a fixed-width cell, with room below for the answer
#let render-nihilist-line(line) = block(below: 2.8em, {
  set text(font: "Courier New", weight: "bold", size: 12pt)
  line.map(b => b.map(v => box(width: 2.2em, align(center, v))).join(h(0.3em))).join(h(1.2em))
})

// Render a nihilist substitution prepared by prepare/ (questions.json); never sees plaintext
// words: arrays of tokens (numbers or punctuation); words are spaced wider than tokens
// lines (crypt, or blocks): Toebes's lines; the first three sit beside the grid
#let render-nihilist-prepared(q) = {
  prepared-heading(q)

  v(0.5em)
  if "lines" in q {
    grid(
      columns: (1fr, auto),
      gutter: 1em,
      q.lines.slice(0, calc.min(3, q.lines.len())).map(render-nihilist-line).join(),
      render-polybius-grid(),
    )
    for line in q.lines.slice(calc.min(3, q.lines.len())) {
      render-nihilist-line(line)
    }
    return
  }
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    {
      set text(font: "Courier New", weight: "bold", size: 12pt)
      set par(leading: 2.5em)
      q.words.map(w => box(w.join(h(0.6em)))).join(h(1.8em))
    },
    render-polybius-grid(),
  )
}
