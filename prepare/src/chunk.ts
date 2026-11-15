// Toebes's chunking and blocking, shared by kinds that print cipher units in blocks.

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

// Toebes's chunk: letters only, in blocks of `size` joined by one space; 0 keeps the text as is.
export function chunk(text: string, size: number): string {
  if (size <= 0) return text;
  const letters = [...text].filter((ch) => ALPHABET.includes(ch.toUpperCase()));
  const blocks = [];
  for (let i = 0; i < letters.length; i += size) blocks.push(letters.slice(i, i + size).join(""));
  return blocks.join(" ");
}

// Splits a line's tokens into blocks at whitespace tokens.
export function toBlocks(tokens: string[]): string[][] {
  const blocks: string[][] = [[]];
  for (const t of tokens) {
    if (t.trim() === "") blocks.push([]);
    else blocks[blocks.length - 1].push(t);
  }
  return blocks.filter((b) => b.length > 0);
}
