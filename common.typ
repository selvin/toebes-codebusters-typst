// ============================================================================
// COMMON UTILITIES
// Shared functions used across multiple cipher types
// ============================================================================

// Convert HTML directly to Typst content, processing recursively
#let html-to-typst(html-str) = {
  let text = html-str
    // First, remove bold tags inside code blocks (they're redundant)
    .replace("<span style=\"font-family:'Courier New', Courier, monospace;\"><strong>", "<span style=\"font-family:'Courier New', Courier, monospace;\">")
    .replace("</strong></span>", "</span>")
    .replace("<span style=\"font-family:'Courier New', Courier, monospace;\"><b>", "<span style=\"font-family:'Courier New', Courier, monospace;\">")
    .replace("</b></span>", "</span>")
    .replace("<code><strong>", "<code>")
    .replace("</strong></code>", "</code>")
    .replace("<code><b>", "<code>")
    .replace("</b></code>", "</code>")
    .replace("<p>", "")
    .replace("</p>", "")
    .replace("&nbsp;", "\u{00A0}")  // Unicode non-breaking space

  // Recursive function to process tags
  let process-tags(text) = {
    // Try to find the first opening tag
    let min-pos = text.len()
    let min-tag = none

    for tag-info in (
      ("<b>", "</b>", strong),
      ("<strong>", "</strong>", strong),
      ("<i>", "</i>", emph),
      ("<em>", "</em>", emph),
      ("<code>", "</code>", raw),
      ("<span style=\"font-family:'Courier New', Courier, monospace;\">", "</span>", raw),
    ) {
      let open-tag = tag-info.at(0)
      let parts = text.split(open-tag)
      if parts.len() > 1 {
        // Found this tag
        let pos = parts.at(0).len()
        if pos < min-pos {
          min-pos = pos
          min-tag = tag-info
        }
      }
    }

    if min-tag == none {
      // No tags found, return as-is
      return text
    }

    let open-tag = min-tag.at(0)
    let close-tag = min-tag.at(1)
    let formatter = min-tag.at(2)

    // Split by opening tag
    let parts = text.split(open-tag)
    let result = ()
    result.push(process-tags(parts.at(0)))  // Process before tag

    for part in parts.slice(1) {
      let subparts = part.split(close-tag)
      if subparts.len() >= 2 {
        // Found matching close tag
        result.push(formatter(process-tags(subparts.at(0))))  // Process content recursively
        result.push(process-tags(subparts.slice(1).join(close-tag)))  // Process after tag
      } else {
        // No matching close tag
        result.push(open-tag + process-tags(part))
      }
    }

    return result.join()
  }

  process-tags(text)
}

// Control page layout: half-page per question
// Call this after rendering each question to handle spacing and page breaks
#let question-page-control(num) = {
  if num != "0" {
    let question-num = int(num)
    // After any question (odd or even), force a page break
    // Odd questions will have the next (even) question positioned at 50% on same page
    // Even questions will start a new page for the next (odd) question
    if calc.rem(question-num, 2) == 0 {
      // After even question: start new page
      pagebreak()
    }
  }
}

// Wrapper for positioning questions at the correct vertical position
// Even questions are positioned at exactly 50% of usable page height
#let position-question(num, content) = {
  if num != "0" {
    let question-num = int(num)
    if calc.rem(question-num, 2) == 0 {
      // Even question: position at exactly 50% of page height using absolute positioning
      // US Letter: 11in = 27.94cm, margins: top 1.5cm + bottom 1cm
      // Usable height: 27.94 - 1.5 - 1 = 25.44cm
      // 50% of usable height = 12.72cm from top margin
      place(top, dy: 12.72cm, content)
    } else {
      // Odd question: render normally at top of page
      content
    }
  } else {
    // Question 0 (TIMED): render normally
    content
  }
}

// Create a question heading with proper formatting
#let question-heading(num, cipher) = {
  // Add a thin line above each question for visual separation
  line(length: 100%, stroke: 0.25pt)
  v(0.05em)

  // Remove default heading spacing to make the line hug the heading
  show heading: it => block(above: 0.1em, below: 0.5em, it)

  // Prepare special bonus prefix if needed
  let bonus-prefix = if "specialbonus" in cipher and cipher.specialbonus {
    [★ (Special Bonus Question) ]
  } else {
    []
  }

  if num == "0" {
    heading(level: 3)[
      #text(size: 11pt)[
        #text(weight: "regular")[#bonus-prefix]#strong[TIMED] #text(weight: "regular")[Question] \[#raw(str(cipher.points)) #text(weight: "regular")[points]\]
        #text(weight: "regular")[
          #if "question" in cipher {
            html-to-typst(cipher.question)
          }
        ]
      ]
    ]
  } else {
    heading(level: 3)[
      #text(size: 11pt)[
        #text(weight: "regular")[#bonus-prefix]#num. \[#raw(str(cipher.points)) #text(weight: "regular")[points]\]
        #text(weight: "regular")[
          #if "question" in cipher {
            html-to-typst(cipher.question)
          }
        ]
      ]
    ]
  }
}

// Display cipher text in a grid format (common for many ciphers)
#let display-cipher-grid(cipherString, columns: 5) = {
  // TODO: Implement grid display logic
  // This would show the cipher text in a formatted grid
  text()[Cipher: #raw(cipherString)]
}

// Display a polybius square
#let display-polybius-square(key) = {
  // TODO: Implement polybius square display
  // This would show the polybius square based on the key
  text()[Polybius Key: #raw(key)]
}

// Display a substitution alphabet
#let display-alphabet(source, dest) = {
  // TODO: Implement alphabet display
  // This would show source and destination alphabets aligned
  block[
    #raw(source)
    \
    #raw(dest)
  ]
}

// Smart text renderer that breaks lines intelligently
// - Breaks lines at periods (.)
// - Maximum N characters per line
// - Doesn't break words (moves whole word to next line)
// Returns an array of strings, one per line
#let smart-line-break(text, max-chars: 80) = {
  let lines = ()
  let current-line = ""
  let current-word = ""
  let skip-next-space = false

  // Process each character using clusters (handles Unicode properly)
  for char in text.clusters() {
    // Check if we hit a period
    if char == "." {
      // Add the period to current word
      current-word += char
      // Flush current word to line
      current-line += current-word
      // End the line here
      if current-line.len() > 0 {
        lines.push(current-line)
      }
      current-line = ""
      current-word = ""
      skip-next-space = true  // Skip the space after period
      continue
    }

    // Check if we hit a space
    if char == " " {
      // Skip space right after a period
      if skip-next-space {
        skip-next-space = false
        continue
      }

      // Check if adding this word would exceed max
      if current-line.len() + current-word.len() + 1 > max-chars and current-line.len() > 0 {
        // Current line is full, start new line with the word
        lines.push(current-line)
        current-line = current-word + " "
        current-word = ""
      } else {
        // Add word and space to current line
        current-line += current-word + " "
        current-word = ""
      }
    } else {
      // Regular character, add to current word
      current-word += char
      skip-next-space = false
    }
  }

  // Handle remaining word and line
  if current-word.len() > 0 {
    if current-line.len() + current-word.len() > max-chars and current-line.len() > 0 {
      // Start new line for the last word
      lines.push(current-line.trim())
      lines.push(current-word)
    } else {
      current-line += current-word
      if current-line.len() > 0 {
        lines.push(current-line)
      }
    }
  } else if current-line.len() > 0 {
    lines.push(current-line.trim())
  }

  return lines
}

// ============================================================================
// DUAL-BOX CIPHER RENDERING
// Functions for rendering ciphers with a dual-box format (e.g., Atbash, Caesar, Affine)
// ============================================================================

// Helper function to check if a character is alphabetic
#let is-alpha(char) = {
  let code = str.to-unicode(char)
  (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
}

// Helper function to render a single character in dual-box format
// Top box: ciphertext, Bottom box: empty for student to fill in
#let render-char-dual-box(char) = {
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
    // For non-alphabetic characters
    if char == " " {
      // Spaces: render as a small gap
      box(
        width: 0.05em,
        height: 3.6em,
        align(center + horizon)[#text(char)]
      )
    } else {
      // Punctuation: render twice (once in each 1.8em space, centered)
      box(
        stack(
          dir: ttb,
          spacing: 0pt,
          // Top position: punctuation (no box border)
          box(
            width: 0.5em,
            height: 1.8em,
            align(center + horizon)[#text(char)]
          ),
          // Bottom position: punctuation (no box border)
          box(
            width: 0.5em,
            height: 1.8em,
            align(center + horizon)[#text(char)]
          )
        )
      )
    }
  }
}

// Generic function to render a cipher with dual-box format
// This can be reused for Atbash, Caesar, Affine, etc.
// Parameters:
//   cipher: The cipher object containing cipherString and other properties
//   num: The question number
//   encode-fn: Function to encode the plaintext (e.g., atbash-encode, caesar-encode)
//   max-chars: Maximum characters per line (default: 35)
#let render-dual-box-cipher(cipher, num, encode-fn, max-chars: 35) = {
  question-heading(num, cipher)

  let cipherString = upper(cipher.cipherString)

  // Encode the string with the provided encoding function
  let encodedString = encode-fn(cipherString)

  // Use smart-line-break for the cipher text
  let lines = smart-line-break(encodedString, max-chars: max-chars)

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
            #render-char-dual-box(char)
            // Add negative spacing between consecutive alphabetic characters
            #if i < chars.len() - 1 and is-alpha(char) and is-alpha(chars.at(i + 1)) [
              #h(-0.45em)
            ]
          ]
        }
      ]
      // Add vertical space after each line
      #v(1em)
    ]
  ]
}
