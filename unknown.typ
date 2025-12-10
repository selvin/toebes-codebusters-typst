// ============================================================================
// UNKNOWN CIPHER TYPE HANDLER
// Renders a clear error message for unsupported cipher types
// ============================================================================

#import "common.typ": *

// Render unknown cipher type with error message
#let render-unknown(cipher, num) = {
  question-heading(num, cipher)

  // Display error message in red
  v(1em)
  block(
    inset: 15pt,
    radius: 4pt,
    stroke: 2pt + red,
    width: 100%
  )[
    #set text(fill: red, weight: "bold", size: 11pt)
    #align(center)[
      ⚠️ UNKNOWN CIPHER TYPE: #cipher.cipherType

      #v(0.5em)
      #text(size: 10pt, weight: "regular")[
        This cipher type is not yet supported.

        Please contact the implementor to add support for this cipher.
      ]
    ]
  ]

  // Show the raw cipher data for debugging
  v(1em)
  text(size: 9pt, fill: gray)[
    #strong[Debug Info:] Cipher string: #raw(str(cipher.cipherString))
  ]
}
