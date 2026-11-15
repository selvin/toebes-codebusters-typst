// ============================================================================
// MAIN ORCHESTRATOR
// Loads questions.json (from prepare/) and delegates rendering by kind.
// Kinds not yet migrated ("legacy") are still rendered from the raw Toebes export.
// ============================================================================

#import "common/common.typ": *
#import "ciphers/aristocrats.typ": *
#import "ciphers/atbash.typ": *
#import "ciphers/baconian.typ": *
#import "ciphers/caesar.typ": *
#import "ciphers/checkerboard.typ": *
#import "ciphers/columnar.typ": *
#import "ciphers/cryptarithm.typ": *
#import "ciphers/fractionated-morse.typ": *
#import "ciphers/homophonic.typ": *
#import "ciphers/nihilist.typ": *
#import "ciphers/patristocrats.typ": *
#import "ciphers/porta.typ": *
#import "ciphers/unknown.typ": *

// Load the input data
// typst compile --input questions=… --input export=… (paths from the repo root: --root .)
#let prepared = json(sys.inputs.at("questions", default: "/build/questions.json"))
#let data = json(sys.inputs.at("export", default: "/input.json"))

// Page setup
// Header: test title, and a team number blank with the division letter pre-filled (as Toebes)
#let team-number-blank = box(
  width: 2.5cm,
  stroke: (bottom: 0.5pt),
  outset: (bottom: 2pt),
  align(left, h(2pt) + prepared.test.division),
)
#set page(
  paper: "us-letter",
  margin: (top: 1.5cm, bottom: 1.5cm, left: 1cm, right: 1cm),
  header: grid(
    columns: (1fr, auto),
    align(center, prepared.test.title),
    [Team Number: #team-number-blank],
  ),
  footer: context align(center)[Page #counter(page).get().first() of #counter(page).final().first()],
)
#set document(title: prepared.test.title)
#set text(size: 11pt)
#show raw: set text(font: "Courier New", weight: "bold")

// Render a kind prepare/ doesn't handle yet, from the raw export (may print plaintext)
#let render-legacy(cipher, num) = {
  // Delegate to appropriate cipher renderer based on cipherType
  let cipher-type = cipher.cipherType
  if cipher-type == "aristocrat" {
    render-aristocrat(cipher, num)
  } else if cipher-type == "baconian" {
    render-baconian(cipher, num)
  } else if cipher-type == "compcolumnar" {
    render-columnar(cipher, num)
  } else if cipher-type == "cryptarithm" {
    render-cryptarithm(cipher, num)
  } else if cipher-type == "fractionatedmorse" {
    render-fractionated-morse(cipher, num)
  } else if cipher-type == "nihilistsub" {
    render-nihilist(cipher, num)
  } else if cipher-type == "porta" {
    render-porta(cipher, num)
  } else {
    // Fallback for unknown cipher types
    render-unknown(cipher, num)
  }
}

// Main document rendering logic
#{
  for q in prepared.questions {
    let num = str(q.number)

    // Wrap question rendering in position-question for proper vertical positioning
    position-question(num, {
      if q.kind == "aristocrat" {
        render-aristocrat-prepared(q)
      } else if q.kind == "atbash" {
        render-atbash-prepared(q)
      } else if q.kind == "baconian" {
        render-baconian-prepared(q)
      } else if q.kind == "caesar" {
        render-caesar-prepared(q)
      } else if q.kind == "checkerboard" {
        render-checkerboard-prepared(q)
      } else if q.kind == "compcolumnar" {
        render-columnar-prepared(q)
      } else if q.kind == "fractionatedmorse" {
        render-fractionated-morse-prepared(q)
      } else if q.kind == "homophonic" {
        render-homophonic-prepared(q)
      } else if q.kind == "nihilist" {
        render-nihilist-prepared(q)
      } else if q.kind == "patristocrat" {
        render-patristocrat-prepared(q)
      } else if q.kind == "porta" {
        render-porta-prepared(q)
      } else {
        render-legacy(data.at("CIPHER." + str(q.toebesId)), num)
      }
    })

    // Apply half-page layout control (except for TIMED question, and after the last one: no blank page)
    if not q.timed and q != prepared.questions.last() {
      question-page-control(num)
    }

    // TIMED question gets its own page
    if q.timed {
      pagebreak()
    }
  }
}
