// ============================================================================
// MAIN ORCHESTRATOR
// Loads questions.json (from prepare/) and delegates rendering by kind.
// Kinds not yet migrated ("legacy") are still rendered from the raw Toebes export.
// ============================================================================

#import "common.typ": *
#import "affine.typ": *
#import "aristocrats.typ": *
#import "atbash.typ": *
#import "baconian.typ": *
#import "caesar.typ": *
#import "columnar.typ": *
#import "cryptarithm.typ": *
#import "fractionated-morse.typ": *
#import "nihilist.typ": *
#import "porta.typ": *
#import "unknown.typ": *

// Load the input data
// typst compile --input questions=… --input export=… (paths relative to this file)
#let prepared = json(sys.inputs.at("questions", default: "build/questions.json"))
#let data = json(sys.inputs.at("export", default: "input.json"))

// Page setup
#set page(
  paper: "us-letter",
  margin: (top: 1.5cm, bottom: 1cm, left: 1cm, right: 1cm),
)
#set document(title: prepared.test.title)
#set text(size: 11pt)
#show raw: set text(font: "Courier New", weight: "bold")

// Render a kind prepare/ doesn't handle yet, from the raw export (may print plaintext)
#let render-legacy(cipher, num) = {
  // Delegate to appropriate cipher renderer based on cipherType
  let cipher-type = cipher.cipherType
  if cipher-type == "affine" {
    render-affine(cipher, num)
  } else if cipher-type == "aristocrat" {
    render-aristocrat(cipher, num)
  } else if cipher-type == "atbash" {
    render-atbash(cipher, num)
  } else if cipher-type == "baconian" {
    render-baconian(cipher, num)
  } else if cipher-type == "caesar" {
    render-caesar(cipher, num)
  } else if cipher-type == "compcolumnar" {
    render-columnar(cipher, num)
  } else if cipher-type == "cryptarithm" {
    render-cryptarithm(cipher, num)
  } else if cipher-type == "fractionatedmorse" {
    render-fractionated-morse(cipher, num)
  } else if cipher-type == "nihilistsub" {
    render-nihilist(cipher, num)
  } else if cipher-type == "patristocrat" {
    render-patristocrat(cipher, num)
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
      } else if q.kind == "baconian" {
        render-baconian-prepared(q)
      } else if q.kind == "nihilist" {
        render-nihilist-prepared(q)
      } else if q.kind == "porta" {
        render-porta-prepared(q)
      } else {
        render-legacy(data.at("CIPHER." + str(q.toebesId)), num)
      }
    })

    // Apply half-page layout control (except for TIMED question)
    if not q.timed {
      question-page-control(num)
    }

    // TIMED question gets its own page
    if q.timed {
      pagebreak()
    }
  }
}
