// ============================================================================
// CRYPTARITHM CIPHERS
// Values to decode and the equation on the left, a letter × digit work grid on the right, as in
// Toebes's PDF
// ============================================================================

#import "../common/common.typ": *

#let cryptarithm-label(body) = text(font: title-font, size: 1.3em, body)

// The values to decode: each digit over an empty box, as the dual-box kinds' (atbash, caesar)
#let render-cryptarithm-values(values) = render-dual-box-text(values.join(" "), toebes-width: 37, box-digits: true)

// The equation as grade-school addition: operands right-aligned, `+` on the last operand's line,
// a rule, then the result. Each letter gets room under it to pencil in its digit.
#let render-cryptarithm-formula(operands, result) = {
  set text(font: mono-font, weight: cipher-weight, size: 14pt)
  let width = calc.max(..operands.map(o => o.len()), result.len())
  let row(prefix, word) = (
    (align(center, prefix),) + ([],) * (width - word.len()) + word.clusters().map(c => align(center, c))
  )
  grid(
    columns: (1.6em,) + (1.6em,) * width,
    row-gutter: 2.2em,
    inset: (_, y) => if y == operands.len() { (top: 0.5em) } else { 0pt },
    ..operands.enumerate().map(((i, o)) => row(if i == operands.len() - 1 { "+" } else { [] }, o)).flatten(),
    grid.hline(stroke: 1pt + black),
    ..row([], result),
  )
  v(2.2em)
}

// Header row 0–9, then one row per letter of the equation, cells empty
#let render-cryptarithm-work-grid(letters) = {
  let header(n) = text(font: mono-font, weight: "bold", size: 0.8em)[#n]
  table(
    columns: (1.7em,) + (1.7em,) * 10,
    rows: (1.7em,) + (2.2em,) * letters.len(),
    align: center + horizon,
    stroke: (x, y) => if x > 0 and y > 0 { 0.5pt + box-stroke-color },
    [], ..range(10).map(header),
    ..letters.map(l => (header(l),) + ([],) * 10).flatten(),
  )
}

// Render a cryptarithm prepared by prepare/ (questions.json); never sees the answer or the key
#let render-cryptarithm-prepared(q) = {
  prepared-heading(q)
  grid(
    columns: (1fr, auto),
    pad(left: 2em, top: 0.5em, {
      cryptarithm-label[Values to decode for solution]
      v(0.4em)
      render-cryptarithm-values(q.values)
      line(length: 70%, stroke: 0.5pt + gray)
      cryptarithm-label[Cryptarithm formula]
      v(0.4em)
      render-cryptarithm-formula(q.operands, q.result)
    }),
    render-cryptarithm-work-grid(q.letters),
  )
}
