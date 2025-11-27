// ============================================================================
// ATBASH CIPHER
// ============================================================================

#import "common.typ": *

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

// Render an atbash cipher (uses the generic dual-box cipher renderer from common.typ)
#let render-atbash(cipher, num) = {
  render-dual-box-cipher(cipher, num, atbash-encode, max-chars: 32)
}
