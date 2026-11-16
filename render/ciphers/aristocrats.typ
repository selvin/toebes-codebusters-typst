// ============================================================================
// ARISTOCRAT CIPHER
// ============================================================================

#import "../common/common.typ": *

// Calculate frequency count for each letter A-Z in the cipher text
#let calculate-frequencies(cipherString) = {
  // Initialize frequency dictionary with all letters set to 0
  let frequencies = (
    A: 0, B: 0, C: 0, D: 0, E: 0, F: 0, G: 0, H: 0, I: 0, J: 0, K: 0, L: 0, M: 0,
    N: 0, O: 0, P: 0, Q: 0, R: 0, S: 0, T: 0, U: 0, V: 0, W: 0, X: 0, Y: 0, Z: 0
  )

  // Count occurrences of each letter in cipher text
  for char in upper(cipherString).clusters() {
    if char in ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z") {
      frequencies.at(char) = frequencies.at(char) + 1
    }
  }

  return frequencies
}

// Render the mapping table for aristocrat ciphers
// alphabet: the letters heading the columns; frequencies: one count per letter, same order
// keyType: "K1", "K2", or "Random" (if not K1 or K2, treated as Random)
#let render-frequency-table(alphabet, frequencies, keyType: "Random") = {
  let letters = alphabet.clusters()

  // Alphabet row (bold code font)
  let alphabet-row = letters.map(table-label)

  // Frequency row (not bold code font); a zero count stays blank
  let frequency-row = (table-label[Frequency],) + frequencies.map(freq =>
    if freq == 0 { [] } else { text(font: mono-font, size: 0.9em, str(freq)) })

  let key-label(k) = text(font: mono-font, weight: "bold", size: 1.1em, k)

  v(1em)

  // Rows ordered by key type; Random leaves the key label empty (understood)
  let rows = if keyType == "K1" {
    ((key-label[K1],) + alphabet-row, frequency-row, replacement-row(letters.len()))
  } else if keyType == "K2" {
    (replacement-row(letters.len()), (key-label[K2],) + alphabet-row, frequency-row)
  } else {
    (([],) + alphabet-row, frequency-row, replacement-row(letters.len()))
  }
  letter-table(letters.len(), ..rows.flatten())
}

// Mapping table computed from a plain string (legacy kinds)
#let render-mapping-table(cipherString, keyType: "Random") = {
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let counts = calculate-frequencies(cipherString)
  render-frequency-table(alphabet, alphabet.clusters().map(l => counts.at(l)), keyType: keyType)
}

// Render an aristocrat cipher
#let render-aristocrat(cipher, num) = {
  question-heading(num, cipher)

  // Display the encoded cipher text with smart line breaks
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    #set text(font: mono-font, weight: "bold", size: 16pt)
    #let lines = smart-line-break(upper(cipher.cipherString), max-chars: 55)
    #for line in lines {
      line
      linebreak()
      v(2.5em)  // Space for students to write answers
    }
  ]

  // Determine key type from cipher object
  // Check for encodeType property (from toebes.com structure)
  let keyType = "Random"  // Default to Random
  if "encodeType" in cipher {
    let encodeType = lower(cipher.encodeType)
    if encodeType == "k1" {
      keyType = "K1"
    } else if encodeType == "k2" {
      keyType = "K2"
    } else {
      keyType = "Random"  // "random" or any other value
    }
  } else if "keyType" in cipher {
    // Fallback for other possible property names
    keyType = cipher.keyType
  }

  // Render the mapping table
  render-mapping-table(cipher.cipherString, keyType: keyType)

  // Additional info if available
  if "crib" in cipher and cipher.crib != "" {
    v(0.5em)
    text()[Known text: #raw(upper(cipher.crib))]
  }
}

// Render an aristocrat prepared by prepare/ (questions.json); never sees plaintext
#let render-aristocrat-prepared(q) = {
  prepared-heading(q)

  // No bottom inset: the writing space after the last line is room enough above the table
  block(
    inset: (x: 10pt),
    radius: 4pt,
    width: 100%
  )[
    #set text(font: mono-font, weight: cipher-weight, size: 16pt)
    #let lines = toebes-line-break(q.ciphertext, 53)
    #for line in lines {
      line
      linebreak()
      v(2.5em)  // Space for students to write answers
    }
  ]

  let keyType = if q.keyType == "k1" { "K1" } else { "Random" }
  render-frequency-table(q.alphabet, q.frequencies, keyType: keyType)
}
