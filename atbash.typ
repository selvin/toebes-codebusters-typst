// ============================================================================
// ATBASH CIPHER
// ============================================================================

#import "common.typ": *

// Helper function to check if a character is alphabetic
#let is-alpha(char) = {
  let code = str.to-unicode(char)
  (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
}

// Helper function to perform Atbash encoding on a character
#let atbash-encode-char(char) = {
  let code = str.to-unicode(char)
  if code >= 65 and code <= 90 {
    // Uppercase: A=65, Z=90
    // A->Z: 65 -> 90, B->Y: 66 -> 89, etc.
    str.from-unicode(90 - (code - 65))
  } else if code >= 97 and code <= 122 {
    // Lowercase: a=97, z=122
    // a->z: 97 -> 122, b->y: 98 -> 121, etc.
    str.from-unicode(122 - (code - 97))
  } else {
    // Not a letter, return as-is
    char
  }
}

// Helper function to encode a string with Atbash
#let atbash-encode(text) = {
  text.clusters().map(char => atbash-encode-char(char)).join("")
}

// Helper function to render a single character
#let render-char(char) = {
  if is-alpha(char) {
    // For alphabetic characters: render two stacked boxes
    box(
      stack(
        dir: ttb,
        spacing: 0pt,
        // Top box: ciphertext
        box(
          inset: 0.5em,
          stroke: 0.25pt + black,
          width: 1.2em,
          height: 1.8em,
          align(center + horizon)[#text(char)]
        ),
        // Bottom box: empty for student to fill in
        box(
          inset: 0.5em,
          stroke: 0.25pt + black,
          width: 1.2em,
          height: 1.8em,
          []
        )
      )
    )
  } else {
    // For non-alphabetic characters: render in the middle
    // The height should match the total height of the two boxes (2 * 1.8em = 3.6em)
    box(
      width: if char == " " { 0.3em } else { 1em },
      height: 3.6em,
      align(center + horizon)[#text(char)]
    )
  }
}

// Render an atbash cipher
#let render-atbash(cipher, num) = {
  question-heading(num, cipher)

  let cipherString = upper(cipher.cipherString)

  // Encode the string with Atbash
  let encodedString = atbash-encode(cipherString)

  // Use smart-line-break for the cipher text
  let lines = smart-line-break(encodedString, max-chars: 32)
  
  v(1em)
  // Render the lines
  block(inset: 4pt)[
    #set text(font: "Courier New", weight: "bold", size: 12pt)
    #for line in lines [
      // Render each character in the line
      #box[
        #{
          let chars = line.clusters()
          for (i, char) in chars.enumerate() [
            #render-char(char)
            // Add negative spacing between consecutive alphabetic characters
            #if i < chars.len() - 1 and is-alpha(char) and is-alpha(chars.at(i + 1)) [
              #h(-0.4em)
            ]
          ]
        }
      ]
      // Add vertical space after each line
      #v(1em)
    ]
  ]
}
