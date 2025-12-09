// ============================================================================
// AFFINE CIPHERS
// Handles affine cipher with parameters a and b
// ============================================================================

#import "common.typ": *

// Render affine cipher
#let render-affine(cipher, num) = {
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
  
  // Display parameters
  v(0.5em)
  text()[Parameters: #emph[a] = #cipher.a, #emph[b] = #cipher.b]
}
