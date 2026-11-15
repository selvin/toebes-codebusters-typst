// ============================================================================
// CAESAR CIPHER
// ============================================================================

#import "../common/common.typ": *

// q: a "caesar" entry from questions.json (ciphertext already encoded by prepare/)
#let render-caesar-prepared(q) = {
  prepared-heading(q)
  render-dual-box-text(q.ciphertext)
}
