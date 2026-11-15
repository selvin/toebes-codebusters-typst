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

// Replacement row (empty) over the 26 fractions, each stacked vertically as ●, –, ×
#let render-fm-table() = {
  let symbol = (O: "●", "-": "–", X: "×")
  let head(t) = text(font: mono-font, weight: "bold", size: 8pt, t)
  table(
    columns: (auto,) + (1fr,) * 26,
    align: center + horizon,
    inset: 2pt,
    stroke: 0.5pt + black,
    head[Replacement], ..([],) * 26,
    head[Morse fraction],
    ..fm-fractions.map(f => text(size: 7pt, f.clusters().map(c => symbol.at(c)).join(linebreak()))),
  )
}

// Render a fractionated morse prepared by prepare/ (questions.json); never sees plaintext
// lines: lines → cipher letters, centered and spaced apart, as in Toebes's PDF
#let render-fractionated-morse-prepared(q) = {
  prepared-heading(q)

  for line in q.lines {
    block(width: 100%, below: 2.4em, align(center, text(font: mono-font, weight: "bold", size: 13pt,
      line.join(h(1em)))))
  }
  render-fm-table()
}
