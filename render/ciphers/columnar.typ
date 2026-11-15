// ============================================================================
// COLUMNAR TRANSPOSITION CIPHERS
// Handles complete columnar cipher
// ============================================================================

#import "../common/common.typ": *

// Render complete columnar cipher
#let render-columnar(cipher, num) = {
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
  
  // Display additional information
  v(0.5em)
  if "keyword" in cipher {
    text()[Keyword: #raw(upper(cipher.keyword))]
    h(1em)
  }
  if "columns" in cipher {
    text()[Columns: #cipher.columns]
  }
  
  if "crib" in cipher and cipher.crib != "" {
    v(0.5em)
    text()[Known text: #raw(upper(cipher.crib))]
  }
}

// Render a complete columnar prepared by prepare/ (questions.json); never sees plaintext
// ciphertext: 5-letter blocks, five to a line on the left, so the right side stays clear for one
// attempt (fewer columns, more rows) and the space below for a second (more columns, fewer rows);
// then an answer line. main.typ gives it a page of its own
#let render-columnar-prepared(q) = {
  prepared-heading(q)

  let blocks = q.ciphertext.split(" ")
  block(inset: (x: 10pt, bottom: 10pt), width: 100%, {
    set text(font: mono-font, weight: "bold", size: 14pt)
    set par(leading: 1.5em)
    blocks.chunks(5).map(line => line.join(" ")).join(linebreak())
  })
  // Work space down to the answer line, 3em above the bottom of the page
  v(1fr)
  text(font: mono-font, weight: "bold", size: 14pt)[Answer: #box(width: 1fr, line(length: 100%))]
  v(3em)
}
