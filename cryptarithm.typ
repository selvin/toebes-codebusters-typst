// ============================================================================
// CRYPTARITHM CIPHERS
// Handles cryptarithm puzzles
// ============================================================================

#import "common.typ": *

// Render cryptarithm cipher
#let render-cryptarithm(cipher, num) = {
  question-heading(num, cipher)
  
  // Display the cryptarithm puzzle
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt
  )[
    #set text(font: "Courier New", weight: "bold", size: 12pt)
    #align(center)[
      #cipher.cipherString
    ]
  ]
  
  // Display the encoded values to decode
  if "soltext" in cipher and cipher.soltext != "" {
    v(0.5em)
    text()[Decode these values using the cryptarithm key]
  }
}
