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
