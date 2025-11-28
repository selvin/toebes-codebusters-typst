// ============================================================================
// MAIN ORCHESTRATOR
// Loads input.json and delegates rendering to appropriate cipher type files
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

// Load the input data
#let data = json("input.json")

// Page setup
#set page(
  paper: "us-letter",
  margin: (top: 1.5cm, bottom: 1cm, left: 1cm, right: 1cm),
)
#set text(size: 11pt)
#show raw: set text(font: "Courier New", weight: "bold")

// Main document rendering logic
#{
  let keys = data.keys().filter(k => k.starts-with("CIPHER."))
  
  // Sort numerically by extracting the number after "CIPHER."
  keys = keys.sorted(key: k => {
    let num-str = k.split(".").at(1)
    int(num-str)
  })
  
  for (idx, key) in keys.enumerate() {
    let cipher = data.at(key)
    let num = key.split(".").at(1)
    
    // Add spacing between questions (but not before the first one)
    if idx > 0 and num != "1" {
      v(1em)
    }
    
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
      question-heading(num, cipher)
      text()[Unknown cipher type: #cipher-type]
    }
    
    // TIMED question gets its own page
    if num == "0" {
      pagebreak()
    }
  }
}
