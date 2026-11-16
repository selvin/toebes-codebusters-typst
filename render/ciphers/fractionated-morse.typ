// ============================================================================
// FRACTIONATED MORSE CIPHERS
// Handles fractionated morse cipher
// ============================================================================

#import "../common/common.typ": *

// Render fractionated morse cipher
#let render-fractionated-morse(cipher, num) = {
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
  
  // Display crib if available
  if "crib" in cipher and cipher.crib != "" {
    v(0.5em)
    text()[Known text: #raw(upper(cipher.crib))]
  }
}

// Toebes's fixed morse fractions, in table order (O dot, - dash, X separator)
#let fm-fractions = (
  "OOO", "OO-", "OOX", "O-O", "O--", "O-X", "OXO", "OX-", "OXX", "-OO", "-O-", "-OX", "--O",
  "---", "--X", "-XO", "-X-", "-XX", "XOO", "XO-", "XOX", "X-O", "X--", "X-X", "XXO", "XX-",
)

// Replacement row (empty) over the 26 fractions, each stacked vertically as ●, –, ×; the
// header as "Morse" over "fraction", so the label column is no wider than "Replacement"
#let render-fm-table() = {
  let symbol = (O: "●", "-": "–", X: "×")
  let fraction(f) = {
    set par(leading: 0.55em)
    text(size: 9pt, f.clusters().map(c => symbol.at(c)).join(linebreak()))
  }
  letter-table(fm-fractions.len(),
    ..replacement-row(fm-fractions.len()),
    table-label[Morse \ fraction], ..fm-fractions.map(fraction),
  )
}

// Render a fractionated morse prepared by prepare/ (questions.json); never sees plaintext
// lines: lines → cipher letters, spaced apart; the lines left-aligned in a block centered as a
// whole, as in Toebes's PDF
#let render-fractionated-morse-prepared(q) = {
  prepared-heading(q)

  align(center, block(below: 0pt, {
    set align(left)
    set text(font: mono-font, weight: cipher-weight, size: 14.5pt)
    // Room under each line to write the morse, the last one included (above the table): 24pt, as
    // before the letters grew
    for line in q.lines {
      block(above: 0pt, below: 0pt, inset: (bottom: 1.65em), line.join(h(1.3em)))
    }
  }))
  render-fm-table()
}
