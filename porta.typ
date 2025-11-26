// ============================================================================
// PORTA CIPHERS
// Handles porta cipher with keyword
// ============================================================================

#import "common.typ": *

// Render porta cipher
#let render-porta(cipher, num) = {
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
  
  // Display keyword
  v(0.5em)
  text()[Keyword: #raw(upper(cipher.keyword))]
}
