// ============================================================================
// PORTA CIPHERS
// Handles porta cipher with keyword
// ============================================================================

#import "../common/common.typ": *

// Render porta cipher
#let render-porta(cipher, num) = {
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
  
  // Display keyword
  v(0.5em)
  text()[Keyword: #raw(upper(cipher.keyword))]
}

// Render a porta prepared by prepare/ (questions.json); never sees plaintext
// ciphertext: letter blocks separated by spaces, each letter boxed with an answer box below
#let render-porta-prepared(q) = {
  prepared-heading(q)
  render-dual-box-text(q.ciphertext)
}
