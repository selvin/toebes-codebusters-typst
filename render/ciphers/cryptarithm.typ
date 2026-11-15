// ============================================================================
// CRYPTARITHM CIPHERS
// Handles cryptarithm puzzles
// ============================================================================

#import "../common/common.typ": *

// Render cryptarithm cipher
#let render-cryptarithm(cipher, num) = {
  question-heading(num, cipher)
  
  // Display the cryptarithm puzzle
  block(
    inset: (x: 10pt, bottom: 10pt),
    radius: 4pt
  )[
    #set text(font: mono-font, weight: "bold", size: 12pt)
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
