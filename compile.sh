#!/bin/bash
# Compile script for Toebes CodeBusters Typst
# Usage: ./compile.sh [toebes-export.json] [output.pdf]
# Run from the repo root; the export path must be inside it (Typst reads it for legacy kinds).
# Runs prepare/ (export → build/questions.json), then Typst, then the leak check (fails on a leak).

set -e

EXPORT="${1:-input.json}"
OUTPUT="${2:-main.pdf}"
QUESTIONS="build/questions.json"
ANSWERS="build/answers.json"

echo "Toebes CodeBusters Typst Compiler"
echo "=================================="
echo ""

# Check if typst is installed
if ! command -v typst &> /dev/null; then
    echo "Error: Typst is not installed."
    echo "Please install Typst from: https://github.com/typst/typst/releases"
    exit 1
fi

if [ ! -f "$EXPORT" ]; then
    echo "Error: $EXPORT not found."
    echo "Usage: ./compile.sh [toebes-export.json] [output.pdf]"
    exit 1
fi

if [ ! -d prepare/node_modules ]; then
    echo "Installing prepare/ dependencies..."
    (cd prepare && npm install --silent)
fi

echo "Preparing $EXPORT..."
prepare/node_modules/.bin/tsx prepare/src/cli.ts "$EXPORT" "$QUESTIONS" "$ANSWERS"

echo "Compiling render/main.typ..."
typst compile --root . --font-path fonts --ignore-system-fonts --input "questions=/$QUESTIONS" --input "export=/$EXPORT" render/main.typ "$OUTPUT"

echo "Checking for leaks..."
pdftotext "$OUTPUT" build/paper.txt
prepare/node_modules/.bin/tsx prepare/src/check-leaks.ts "$EXPORT" build/paper.txt
echo "Success! Output saved to $OUTPUT"
