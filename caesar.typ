// ============================================================================
// CAESAR CIPHER
// ============================================================================

#import "common.typ": *

// Helper function to perform Atbash encoding on a character
#let caesar-encode-char(char, offset) = {
  let code = str.to-unicode(upper(char))
  if code >= 65 and code <= 90 {
    let newCode = code + offset
    if newCode > 90 {
      newCode -= 26
    }
    str.from-unicode(newCode)
  } else {
    // Not a letter, return as-is
    char
  }
}

// Helper function to encode a string with Atbash
#let caesar-encode(text, offset) = {
  text.clusters().map(char => caesar-encode-char(char, offset)).join("")
}

// Render an caesar cipher (uses the generic dual-box cipher renderer from common.typ)
#let render-caesar(cipher, num) = {
  render-dual-box-cipher(cipher, num, text => caesar-encode(text, cipher.offset), max-chars: 32)
}
