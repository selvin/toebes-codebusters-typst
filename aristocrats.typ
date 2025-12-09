// ============================================================================
// ARISTOCRAT CIPHER
// ============================================================================

#import "common.typ": *

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
// keyType: "K1", "K2", or "Random" (if not K1 or K2, treated as Random)
#let render-mapping-table(cipherString, keyType: "Random") = {
  let frequencies = calculate-frequencies(cipherString)
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  // Create table with appropriate number of columns (key column + 26 alphabet columns)
  let columns = (auto,) + (1fr,) * 26

  // Helper function to create empty cells for replacement row
  let empty-boxes = {
    let row = ()
    for letter in alphabet.clusters() {
      row.push([#v(1.5em)])
    }
    row
  }

  // Helper function to create alphabet row (bold code font)
  let alphabet-row = {
    let row = ()
    for letter in alphabet.clusters() {
      row.push([#text(font: "Courier New", weight: "bold", size: 0.9em)[#letter]])
    }
    row
  }

  // Helper function to create frequency row (not bold code font)
  let frequency-row = {
    let row = ()
    for letter in alphabet.clusters() {
      let freq = frequencies.at(letter)
      if freq == 0 {
        row.push([])
      } else {
        row.push([#text(font: "Courier New", size: 0.9em)[#str(freq)]])
      }
    }
    row
  }

  v(1em)

  // Render table based on key type
  if keyType == "K1" {
    table(
      columns: columns,
      stroke: 0.5pt + black,
      align: center + horizon,

      // Row 1: K1 + alphabets
      [#text(font: "Courier New", weight: "bold", size: 1.1em)[K1]], ..alphabet-row,

      // Row 2: Frequency + frequencies
      [#text(font: "Courier New", weight: "bold", size: 0.9em)[Frequency]], ..frequency-row,

      // Row 3: Replacement + empty boxes
      [#text(font: "Courier New", weight: "bold", size: 0.9em)[Replacement]], ..empty-boxes
    )
  } else if keyType == "K2" {
    table(
      columns: columns,
      stroke: 0.5pt + black,
      align: center + horizon,

      // Row 1: Replacement + empty boxes
      [#text(font: "Courier New", weight: "bold", size: 0.9em)[Replacement]], ..empty-boxes,

      // Row 2: K2 + alphabets
      [#text(font: "Courier New", weight: "bold", size: 1.1em)[K2]], ..alphabet-row,

      // Row 3: Frequency + frequencies
      [#text(font: "Courier New", weight: "bold", size: 0.9em)[Frequency]], ..frequency-row
    )
  } else { // Random
    table(
      columns: columns,
      stroke: 0.5pt + black,
      align: center + horizon,

      // Row 1: Empty key + alphabets (Random is understood)
      [], ..alphabet-row,

      // Row 2: Frequency + frequencies
      [#text(font: "Courier New", weight: "bold", size: 0.9em)[Frequency]], ..frequency-row,

      // Row 3: Replacement + empty boxes
      [#text(font: "Courier New", weight: "bold", size: 0.9em)[Replacement]], ..empty-boxes
    )
  }
}

// Render an aristocrat cipher
#let render-aristocrat(cipher, num) = {
  question-heading(num, cipher)

  // Display the encoded cipher text
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    #set text(font: "Courier New", weight: "bold", size: 10pt)
    #upper(cipher.cipherString)
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

// Render a patristocrat cipher (similar to aristocrat but with different spacing)
#let render-patristocrat(cipher, num) = {
  question-heading(num, cipher)
  
  // Display the encoded cipher text
  v(0.5em)
  block(
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    #set text(font: "Courier New", weight: "bold", size: 10pt)
    #cipher.cipherString
  ]
}
