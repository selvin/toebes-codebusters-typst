#let data = json("data.json")

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

// Main document
#set page(
  paper: "us-letter",
  margin: (top: 1.5cm, bottom: 1cm, left: 1cm, right: 1cm),
)
#set text(size: 11pt)
#show raw: set text(font: "Courier New", weight: "bold")  // Use Courier New for non-slashed zeros

// Iterate through all cipher entries
#{
  let keys = data.keys().filter(k => k.starts-with("CIPHER."))
  
  // Sort numerically by extracting the number after "CIPHER."
  keys = keys.sorted(key: k => {
    let num-str = k.split(".").at(1)
    int(num-str)
  })
  
  for (idx, key) in keys.enumerate() {
    let cipher = data.at(key)
    let num = key.split(".").at(1)
    
    // Add spacing between questions (but not before the first one)
    if idx > 0 and num != "1" {
      v(1em)
    }
    
    // Create heading with question number/TIMED, points, then question text
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
      // TIMED question gets its own page
      pagebreak()
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
}
