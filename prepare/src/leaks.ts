// Leak check: does the question paper's text hold a run of plaintext? Compares letters only
// (accents stripped, case ignored, across word boundaries), so line breaks and boxes don't hide one.

// Measured on real tests, chance matches and printed cribs stay at 11 letters or fewer.
export const MIN_LEAK_RUN = 15;

export const lettersOnly = (s: string) =>
  s.normalize("NFD").toUpperCase().replace(/[^A-Z]/g, "");

// True when some `minRun` consecutive letters of the plaintext appear in the paper's letters.
export function leaks(plaintext: string, paperText: string, minRun = MIN_LEAK_RUN): boolean {
  const plain = lettersOnly(plaintext);
  const paper = lettersOnly(paperText);
  for (let i = 0; i + minRun <= plain.length; i++) {
    if (paper.includes(plain.slice(i, i + minRun))) return true;
  }
  return false;
}
