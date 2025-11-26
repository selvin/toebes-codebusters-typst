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

// Create a question heading with proper formatting
#let question-heading(num, cipher) = {
  if num == "0" {
    heading(level: 2)[
      #text(size: 11pt)[
        #strong[TIMED] #text(weight: "regular")[Question] \[#raw(str(cipher.points)) #text(weight: "regular")[points]\] 
        #text(weight: "regular")[
          #if "question" in cipher {
            html-to-typst(cipher.question)
          }
        ]
      ]
    ]
  } else {
    heading(level: 2)[
      #text(size: 11pt)[
        #num. \[#raw(str(cipher.points)) #text(weight: "regular")[points]\] 
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
