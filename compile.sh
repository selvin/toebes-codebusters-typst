#!/bin/bash
# Compile script for Toebes CodeBusters Typst

echo "Toebes CodeBusters Typst Compiler"
echo "=================================="
echo ""

# Check if typst is installed
if ! command -v typst &> /dev/null; then
    echo "Error: Typst is not installed."
    echo "Please install Typst from: https://github.com/typst/typst/releases"
    exit 1
fi

# Check if input.json exists
if [ ! -f "input.json" ]; then
    echo "Error: input.json not found."
    echo "Please copy your exported JSON file to input.json"
    exit 1
fi

# Compile
echo "Compiling main.typ..."
typst compile main.typ

if [ $? -eq 0 ]; then
    echo "Success! Output saved to main.pdf"
else
    echo "Compilation failed. Please check for errors."
    exit 1
fi
