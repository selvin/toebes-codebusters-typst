// ============================================================================
// COLUMNAR TRANSPOSITION CIPHERS
// Handles complete columnar cipher
// ============================================================================

#import "common.typ": *

// Render complete columnar cipher
#let render-columnar(cipher, num) = {
  question-heading(num, cipher)
  
  // Display the encoded cipher text
  v(0.5em)
  block(
    fill: rgb("#f5f5f5"),
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
