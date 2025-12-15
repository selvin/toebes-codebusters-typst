// ============================================================================
// PATRISTOCRAT CIPHER
// ============================================================================

#import "common.typ": *

#let render-patristocrat(cipher, num) = {
  question-heading(num, cipher)

  // Display the encoded cipher text with smart line breaks
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    #set text(font: "Courier New", weight: "bold", size: 16pt)
    #let lines = smart-line-break(upper(cipher.cipherString), max-chars: 55)
    #for line in lines {
      line
      linebreak()
      v(2.5em)  // Space for students to write answers
    }
  ]
}
