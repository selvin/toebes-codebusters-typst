// ============================================================================
// BACONIAN CIPHERS
// Handles baconian cipher with different operations (words, sequence, let4let)
// ============================================================================

#import "common.typ": *

// Render baconian cipher with word operation
#let render-baconian-words(cipher, num) = {
  question-heading(num, cipher)
  
  // Display the words
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    #set text(size: 10pt)
    #let words = cipher.words
    #for (i, word) in words.enumerate() {
      if calc.rem(i, 6) == 0 and i > 0 {
        linebreak()
      }
      [#word#h(1em)]
    }
  ]
  
  if "crib" in cipher and cipher.crib != "" {
    v(0.5em)
    text()[Known text: #raw(upper(cipher.crib))]
  }
}

// Render baconian cipher with sequence operation
#let render-baconian-sequence(cipher, num) = {
  question-heading(num, cipher)
  
  // Display the A/B sequence or custom symbols
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    #set text(font: "Courier New", size: 10pt)
    // In the actual implementation, this would display the encoded sequence
    // using the texta and textb symbols
    #cipher.cipherString
    \
    \
    #text(size: 9pt)[
      Symbol A: #html-to-typst(cipher.texta) | 
      Symbol B: #html-to-typst(cipher.textb)
    ]
  ]
}

// Render baconian cipher with letter-for-letter operation
#let render-baconian-let4let(cipher, num) = {
  question-heading(num, cipher)
  
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    #set text(font: "Courier New", size: 10pt)
    #cipher.cipherString
    \
    \
    #text(size: 9pt)[
      A letters: #html-to-typst(cipher.texta) | 
      B letters: #html-to-typst(cipher.textb)
    ]
  ]
}

// Main baconian renderer that delegates to specific types
#let render-baconian(cipher, num) = {
  if cipher.operation == "words" {
    render-baconian-words(cipher, num)
  } else if cipher.operation == "sequence" {
    render-baconian-sequence(cipher, num)
  } else if cipher.operation == "let4let" {
    render-baconian-let4let(cipher, num)
  } else {
    // Default fallback
    question-heading(num, cipher)
    text()[Cipher: #raw(cipher.cipherString)]
  }
}
