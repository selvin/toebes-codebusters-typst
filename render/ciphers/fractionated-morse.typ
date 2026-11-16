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
// lines: lines → cipher letters, at most 17 a line (Toebes's breaks), in 17 equal columns across
// the text width, so lines are left-aligned. Students write the plaintext under each line, so the
// room below the lines grows to fill the slot (24pt at least), leaving about 10% of it free below
// the table
#let render-fractionated-morse-prepared(q) = {
  prepared-heading(q)

  let columns = calc.max(17, ..q.lines.map(l => l.len()))
  for line in q.lines {
    grid(columns: (1fr,) * columns, align: center,
      ..line.map(c => text(font: mono-font, weight: cipher-weight, size: 14.5pt, c)))
    v(24pt)
    v(1fr)
  }
  render-fm-table()
  v(10%)
}
