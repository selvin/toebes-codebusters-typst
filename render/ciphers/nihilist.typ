// ============================================================================
// NIHILIST SUBSTITUTION CIPHERS
// Handles nihilist substitution cipher with polybius square
// ============================================================================

#import "../common/common.typ": *

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
    #set text(font: mono-font, weight: "bold", size: 10pt)
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
  let header(n) = text(font: mono-font, weight: "bold", size: 0.8em)[#n]
  table(
    columns: (2.25em,) + (4em,) * 5,
    rows: 2.25em,
    stroke: 0.5pt + box-stroke-color,
    align: center + horizon,
    [], ..range(1, 6).map(header),
    ..range(1, 6).map(r => (header(r),) + ([],) * 5).flatten()
  )
}

// One line of blocks. As in Toebes's 24-token lines, every token (a value, punctuation, or the
// space between blocks) takes one equal cell: 24 fit the text width
#let render-nihilist-line(line) = {
  set text(font: mono-font, weight: cipher-weight, size: 12pt)
  let cell = 1.9em
  line.map(b => b.map(v => box(width: cell, align(center, v))).join()).join(h(cell))
}

// Render a nihilist substitution prepared by prepare/ (questions.json); never sees plaintext
// lines: Toebes's lines → blocks (words when blocksize is 0) → values or punctuation;
// the first three sit beside the grid
#let render-nihilist-prepared(q) = {
  prepared-heading(q)
  lines-beside-grid(q.lines.map(render-nihilist-line), render-polybius-grid())
}
