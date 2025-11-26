// ============================================================================
// ATBASH CIPHER
// ============================================================================

#import "common.typ": *

// Render an atbash cipher
#let render-atbash(cipher, num) = {
  question-heading(num, cipher)
  
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
}
