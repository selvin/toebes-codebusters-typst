// ============================================================================
// BACONIAN CIPHERS
// Handles baconian cipher with different operations (words, sequence, let4let)
// ============================================================================

#import "../common/common.typ": *

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
    #set text(font: mono-font, size: 10pt)
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
    #set text(font: mono-font, size: 10pt)
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

// Empty A–Z table for the student's letter replacements (words mode)
#let render-baconian-replacement-table() = {
  let label(t) = text(font: mono-font, weight: "bold", size: 0.9em)[#t]
  let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
  v(1em)
  table(
    columns: (auto,) + (1fr,) * letters.len(),
    stroke: 0.5pt + black,
    align: center + horizon,
    [], ..letters.map(label),
    label[Replacement], ..letters.map(_ => v(1.5em)),
  )
}

// Render a baconian prepared by prepare/ (questions.json); never sees plaintext
// mode "words": lines of cipher words; mode "symbols" (sequence, let4let): lines of symbols, one
// per cell, each line followed by an empty answer row
#let render-baconian-prepared(q) = {
  prepared-heading(q)

  if q.mode == "words" {
    align(center, block({
      set align(left)
      set text(font: mono-font, weight: "bold", size: 14pt)
      set par(leading: 2.2em)
      q.lines.join(linebreak())
    }))
    render-baconian-replacement-table()
  } else {
    set text(font: mono-font, size: 14pt)
    let width = calc.max(..q.lines.map(l => l.len()))
    let rows = q.lines.map(line => {
      let symbols = line.map(s => [#s]) + ([],) * (width - line.len())
      symbols + (table.cell(colspan: width)[#v(1.8em)],)
    })
    align(center, table(
      columns: width,
      stroke: none,
      inset: (x: 1pt, y: 4pt),
      align: center + horizon,
      ..rows.flatten()
    ))
  }
}
