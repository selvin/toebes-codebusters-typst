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
    #set text(font: "Courier New", weight: "bold", size: 10pt)
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
// ciphertext: 5-letter blocks, eight to a line as in Toebes's PDF, then work space and an answer line
#let render-columnar-prepared(q) = {
  prepared-heading(q)

  v(0.5em)
  let blocks = q.ciphertext.split(" ")
  block(inset: 10pt, width: 100%, {
    set text(font: "Courier New", weight: "bold", size: 14pt)
    set par(leading: 1.5em)
    blocks.chunks(8).map(line => line.join(" ")).join(linebreak())
  })
  v(12em)
  text(font: "Courier New", weight: "bold", size: 14pt)[Answer: #box(width: 1fr, line(length: 100%))]
}
