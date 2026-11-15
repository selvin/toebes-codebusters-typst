// Question HTML → paragraphs of styled text runs, so the Typst side never parses HTML.
// Handles what Toebes's editor produces: <p>, <b>/<strong>, <i>/<em>, <code>, a Courier span for
// monospace, <br>, and a few entities. Unknown tags are dropped, keeping their text.

export interface Run {
  text: string;
  bold: boolean;
  italic: boolean;
  mono: boolean;
}

export type Paragraph = Run[];

const ENTITIES: Record<string, string> = {
  nbsp: " ",
  amp: "&",
  lt: "<",
  gt: ">",
  quot: '"',
  apos: "'",
};

export function decodeEntities(s: string): string {
  return s.replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, (whole, name: string) => {
    if (name[0] === "#") {
      const code = name[1].toLowerCase() === "x" ? parseInt(name.slice(2), 16) : parseInt(name.slice(1), 10);
      return String.fromCodePoint(code);
    }
    return ENTITIES[name.toLowerCase()] ?? whole;
  });
}

type Style = "bold" | "italic" | "mono" | null;

function styleOf(tag: string, attrs: string): Style {
  switch (tag) {
    case "b":
    case "strong":
      return "bold";
    case "i":
    case "em":
      return "italic";
    case "code":
      return "mono";
    case "span":
      return /monospace|courier/i.test(attrs) ? "mono" : null;
    default:
      return null;
  }
}

export function htmlToParagraphs(html: string): Paragraph[] {
  const paragraphs: Paragraph[] = [];
  let current: Paragraph = [];
  const stack: { tag: string; style: Style }[] = [];

  const endParagraph = () => {
    const trimmed = trimParagraph(current);
    if (trimmed.length > 0) paragraphs.push(trimmed);
    current = [];
  };

  const addText = (raw: string) => {
    // Collapse source whitespace before decoding, so &nbsp; survives as a real non-breaking space
    const text = decodeEntities(raw.replace(/\s+/g, " "));
    if (text === "") return;
    const run: Run = {
      text,
      bold: stack.some((s) => s.style === "bold"),
      italic: stack.some((s) => s.style === "italic"),
      mono: stack.some((s) => s.style === "mono"),
    };
    const last = current[current.length - 1];
    if (last && last.bold === run.bold && last.italic === run.italic && last.mono === run.mono) {
      last.text += run.text;
    } else {
      current.push(run);
    }
  };

  const tagPattern = /<(\/?)([a-z][a-z0-9]*)([^>]*)>/gi;
  let pos = 0;
  for (const m of html.matchAll(tagPattern)) {
    addText(html.slice(pos, m.index));
    pos = m.index + m[0].length;
    const closing = m[1] === "/";
    const tag = m[2].toLowerCase();
    if (tag === "p" || tag === "div") {
      endParagraph();
    } else if (tag === "br") {
      endParagraph();
    } else if (closing) {
      const i = stack.map((s) => s.tag).lastIndexOf(tag);
      if (i >= 0) stack.splice(i);
    } else if (!m[3].trimEnd().endsWith("/")) {
      stack.push({ tag, style: styleOf(tag, m[3]) });
    }
  }
  addText(html.slice(pos));
  endParagraph();
  return paragraphs;
}

function trimParagraph(runs: Paragraph): Paragraph {
  const out = runs.map((r) => ({ ...r }));
  if (out.length > 0) out[0].text = out[0].text.replace(/^ +/, "");
  if (out.length > 0) out[out.length - 1].text = out[out.length - 1].text.replace(/ +$/, "");
  return out.filter((r) => r.text !== "");
}
