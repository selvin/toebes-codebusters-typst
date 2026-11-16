// ============================================================================
// ANSWER KEY
// Reads only answers.json (from prepare/): one row per question, for graders. The question
// paper (main.typ) is never given answers.json.
// ============================================================================

#import "common/common.typ": box-stroke-color
#import "common/fonts.typ": *

// typst compile --input answers=… (path from the repo root: --root .)
#let key = json(sys.inputs.at("answers", default: "/build/answers.json"))

#let rows-per-page = 18
#let key-size = 12pt
#let key-red = rgb("#d00000")
#let row-rule = 0.5pt + box-stroke-color
#let group-rule = 1.5pt + box-stroke-color

#let answer-key-label = text(fill: key-red, weight: "bold")[ANSWER KEY]
#set page(
  paper: "us-letter",
  flipped: true,
  margin: (top: 1.5cm, bottom: 1.5cm, left: 1cm, right: 1cm),
  header: grid(
    columns: (1fr, auto, 1fr),
    answer-key-label,
    text(font: title-font, key.test.title),
    align(right, answer-key-label),
  ),
  footer: context align(center)[Page #counter(page).get().first() of #counter(page).final().first()],
)
#set document(title: key.test.title + " — Answer key")
#set text(font: body-font, size: key-size)

// The timed question is T; a thick rule follows it and every fifth question
#let label(a) = if a.timed { "T" } else { str(a.number) }
#let ends-group(a) = a.timed or calc.rem(a.number, 5) == 0

// Zero-error answers: all caps, and a red border round the letter count
#let letters-cell(a) = {
  let count = text(font: mono-font, str(a.letters))
  if a.zeroErrors { box(stroke: 1pt + key-red, outset: (x: 3pt, y: 3pt), count) } else { count }
}
#let answer-cell(a) = {
  let body = if a.zeroErrors { upper(a.answer) } else { a.answer }
  if a.kind == "cryptarithm" { text(font: mono-font, body) } else { text(font: answer-font, body) }
}

// Text measured cap height to baseline, so the ★ and the mono answers don't make their rows taller
#let key-table(answers) = {
  set text(top-edge: "cap-height", bottom-edge: "baseline")
  set par(leading: 0.75em)
  table(
    columns: (auto, auto, auto, 1fr),
    align: (center + horizon, right + horizon, center + horizon, left + horizon),
    inset: (x: 6pt, y: 9pt),
    stroke: (x, y) => (left: row-rule, right: row-rule),
    table.hline(stroke: group-rule),
    ..answers
      .map(a => (
        if a.specialBonus { text(font: answer-font, size: 1.5em, "★") } else { [] },
        letters-cell(a),
        text(font: mono-font, weight: "bold", label(a)),
        answer-cell(a),
        table.hline(stroke: if ends-group(a) or a == answers.last() { group-rule } else { row-rule }),
      ))
      .flatten(),
  )
}

#for (i, page-answers) in key.answers.chunks(rows-per-page).enumerate() {
  if i > 0 { pagebreak() }
  key-table(page-answers)
}
