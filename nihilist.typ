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

// Render a nihilist substitution prepared by prepare/ (questions.json); never sees plaintext
// words: arrays of tokens (numbers or punctuation); words are spaced wider than tokens
#let render-nihilist-prepared(q) = {
  prepared-heading(q)

  v(0.5em)
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
