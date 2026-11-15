// ============================================================================
// ATBASH CIPHER
// ============================================================================

#import "../common/common.typ": *

// q: an "atbash" entry from questions.json (ciphertext already encoded by prepare/)
#let render-atbash-prepared(q) = {
  prepared-heading(q)
  render-dual-box-text(q.ciphertext, max-chars: 32)
}
