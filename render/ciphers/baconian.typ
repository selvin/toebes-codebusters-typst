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
  let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
  letter-table(letters.len(), [], ..letters.map(table-label), ..replacement-row(letters.len()))
}

// Render a baconian prepared by prepare/ (questions.json); never sees plaintext
// mode "words": lines of cipher words; mode "symbols" (sequence, let4let): lines of symbols, one
// per cell, each line followed by an empty answer row
#let render-baconian-prepared(q) = {
  prepared-heading(q)

  if q.mode == "words" {
    align(center, block(below: 0pt, {
      set align(left)
      set text(font: mono-font, weight: cipher-weight, size: 14pt)
      // About 48pt line to line, as the nihilist and checkerboard lines: room to write under each,
      // the last one included (above the table)
      let gap = 2.7em
      set par(leading: gap)
      q.lines.join(linebreak())
      v(gap)
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
