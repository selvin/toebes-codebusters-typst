// ============================================================================
// COMMON UTILITIES
// Shared functions used across multiple cipher types
// ============================================================================

#import "fonts.typ": *

// A monospace run inside question text (a crib or hint): bold, at the size of the text around it
// (not raw, which Typst sets at 0.8em; the two fonts' cap heights match)
#let mono-run(body) = text(font: mono-font, weight: "bold", body)

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
      ("<code>", "</code>", mono-run),
      ("<span style=\"font-family:'Courier New', Courier, monospace;\">", "</span>", mono-run),
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
// Odd questions start a page; the even question after one starts at the middle of the text area,
// or lower if the odd one runs past it (then a clear gap between them). An even question that no
// longer fits moves to the next page.
#let position-question(num, content) = {
  if num != "0" and calc.rem(int(num), 2) == 1 {
    // Odd question: at the top of the page, in a block down to the middle, so a v(1fr) in it fills
    // to the middle (measured, not placed, so a tall question pushes the next one down instead of
    // running into it, with a clear gap)
    layout(size => {
      let height = measure(block(width: size.width, content)).height
      let gap = 1.5em.to-absolute()
      if height + gap <= size.height / 2 {
        block(height: size.height / 2, width: 100%, content)
      } else {
        content
        v(gap)
      }
    })
  } else if num == "0" {
    // TIMED question: a page of its own (main.typ breaks the page after it), framed by a double
    // outline around the whole text area so it stands out
    let rule = 0.75pt + black
    block(width: 100%, height: 100%, stroke: rule, inset: 2pt,
      block(width: 100%, height: 100%, stroke: rule, inset: (x: 0.5cm, y: 0.4cm), content))
  } else {
    // Even question: follows the padding
    content
  }
}

// Create a question heading with proper formatting
// num: "0" for the timed question; body: the question text as content
#let question-heading-core(num, points, special-bonus, body) = {
  // Add a thin line above each question for visual separation, clear of the page header
  // (not for the timed question: its outline already sets it apart)
  if num != "0" {
    v(0.5em)
    line(length: 100%, stroke: 0.25pt)
    v(0.6em)
  }

  // Remove default heading spacing to make the line hug the heading
  show heading: it => block(above: 0.1em, below: 0em, it)

  // Prepare special bonus prefix if needed
  let bonus-prefix = if special-bonus {
    [★ (Special Bonus Question) ]
  } else {
    []
  }

  // The question number in a circle that fits one or two digits, centered both ways
  // (a circle, not a square, so it stands out from the cipher boxes)
  let number-box = box(baseline: 0.55em, circle(
    radius: 0.9em,
    inset: 0pt,
    stroke: 0.5pt,
    align(center + horizon, text(top-edge: "bounds", bottom-edge: "bounds", strong(num))),
  ))
  let label = if num == "0" [#strong[TIMED] #text(weight: "regular")[Question]] else { number-box }

  // [P points] in monospace: the brackets and P at normal size, only P bold, "points" small
  let points-label = text(font: mono-font, weight: "regular")[\[#strong(str(points)) #text(size: 0.85em)[points]\]]

  heading(level: 3)[
    #text(size: body-size)[
      #text(weight: "regular")[#bonus-prefix]#label #points-label
      #text(weight: "regular")[#body]
    ]
  ]

  // The one gap between heading and body (renderers add no space of their own before the body)
  v(1.5em)
}

// Heading from a raw Toebes cipher (legacy kinds)
#let question-heading(num, cipher) = {
  let special-bonus = "specialbonus" in cipher and cipher.specialbonus
  let body = if "question" in cipher { html-to-typst(cipher.question) } else { [] }
  question-heading-core(num, cipher.points, special-bonus, body)
}

// Question text prepared by prepare/ (paragraphs of runs) → content
#let runs-to-content(paragraphs) = {
  paragraphs.map(runs => {
    runs.map(run => {
      let body = if run.mono { mono-run(run.text) } else { [#run.text] }
      if run.bold and not run.mono { body = strong(body) }
      if run.italic { body = emph(body) }
      body
    }).join()
  }).join(linebreak())
}

// Heading from a prepared question (questions.json)
#let prepared-heading(q) = {
  let body = runs-to-content(q.text)
  if q.timed {
    body += [ When you have solved it, raise your hand so that the time can be recorded and the solution checked.]
  }
  question-heading-core(str(q.number), q.points, q.specialBonus, body)
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

// Render already-encoded text in dual-box format: each letter boxed, an empty box below it
#let render-dual-box-text(encodedString, max-chars: 35) = {
  // Use smart-line-break for the cipher text
  let lines = smart-line-break(encodedString, max-chars: max-chars)

  // Render the lines
  block(inset: (x: 4pt, bottom: 4pt))[
    #set text(font: mono-font, weight: "bold", size: 12pt)
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
