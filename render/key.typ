// ============================================================================
// ANSWER KEY
// Reads only answers.json (from prepare/): one row per question, for graders. The question
// paper (main.typ) is never given answers.json.
// ============================================================================

#import "common/common.typ": bonus-star, box-stroke-color
#import "common/fonts.typ": *

// typst compile --input answers=… (path from the repo root: --root .)
#let key = json(sys.inputs.at("answers", default: "/build/answers.json"))

#let key-size = 12pt
#let key-red = rgb("#d00000")
#let key-blue = rgb("#1c3f94") // ink blue, for the question numbers
#let row-rule = 0.5pt + box-stroke-color
#let stripe = luma(90%) // 10% black, behind odd-numbered questions
// Roomy rows: one table that flows, so page 1 fills first and page 2 takes what's left
#let row-inset = 10pt

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
  // Covers aren't counted: the table's pages run 1 to the page of <key-end>
  footer: context align(center)[Page #counter(page).get().first() of #counter(page).at(<key-end>).first()],
)
#set document(title: key.test.title + " — Answer key")
#set text(font: body-font, size: key-size)

// Front and back cover (the same page twice), so the sheets travel face down: ANSWER KEY in red as
// the title (large, not bold), then the test's name and division, centred on the page, all in the
// answers' serif. The export has no date.
#let cover = page(header: none, footer: none, align(center + horizon, {
  set text(font: answer-font)
  text(size: 48pt, fill: key-red)[ANSWER KEY]
  v(1.5em)
  text(size: 24pt, key.test.title)
  if key.test.division != "" {
    v(0.5em)
    text(size: 16pt, fill: box-stroke-color)[Division #key.test.division]
  }
}))

// The timed question is T
#let label(a) = if a.timed { "T" } else { str(a.number) }

// The letter count in 60% black, so it doesn't dominate; zero-error answers get all caps and a
// red border round the count
#let letters-cell(a) = {
  let count = text(font: mono-font, fill: box-stroke-color, str(a.letters))
  if a.zeroErrors { box(stroke: 1pt + key-red, outset: (x: 3pt, y: 3pt), count) } else { count }
}
#let answer-cell(a) = {
  let body = if a.zeroErrors { upper(a.answer) } else { a.answer }
  if a.kind == "cryptarithm" { text(font: mono-font, body) } else { text(font: answer-font, body) }
}

#cover
#counter(page).update(1)

// Text measured cap height to baseline, so the ★ and the mono answers don't make their rows taller
#{
  set text(top-edge: "cap-height", bottom-edge: "baseline")
  set par(leading: 0.75em)
  table(
    columns: (auto, auto, auto, 1fr),
    align: (right + horizon, center + horizon, center + horizon, left + horizon),
    inset: (x: 6pt, y: row-inset),
    stroke: row-rule,
    fill: (x, y) => if calc.odd(key.answers.at(y).number) { stripe },
    ..key
      .answers
      .map(a => (
        letters-cell(a),
        // The ★ sits in a box of cap height, so its size doesn't make the row taller
        if a.specialBonus { box(height: 0.7em, align(horizon, bonus-star)) } else { [] },
        text(font: mono-font, weight: "bold", fill: key-blue, label(a)),
        answer-cell(a),
      ))
      .flatten(),
  )
}
#metadata(none) <key-end>
#cover
