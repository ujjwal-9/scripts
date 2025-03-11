#!/bin/bash

# Check if a file is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <pdf_file>"
    exit 1
fi

PDF_FILE="$1"

# Check if the file exists
if [ ! -f "$PDF_FILE" ]; then
    echo "Error: File not found!"
    exit 1
fi

# Python script to extract highlights and copy to clipboard
/Users/ujjwal/miniconda3/bin/python <<EOF
import fitz  # PyMuPDF
import pyperclip
import sys

pdf_path = "$PDF_FILE"
doc = fitz.open(pdf_path)
highlighted_texts = []

for page_num, page in enumerate(doc):
    for annot in page.annots():
        if annot.type[0] == 8:  # Highlight annotation
            quad_points = annot.vertices
            highlight_text = []

            for i in range(0, len(quad_points), 4):  # QuadPoints are in sets of 4
                rect = fitz.Quad(quad_points[i:i+4]).rect
                text = page.get_text("text", clip=rect).strip()
                if text:
                    highlight_text.append(text)

            if highlight_text:
                formatted_text = " ".join(highlight_text).replace("\n", " ").strip()
                highlighted_texts.append(f"- {formatted_text} (page {page_num + 1})")

# Ensure proper Markdown formatting
md_output = "\\n\\n".join(highlighted_texts)

# Copy to clipboard
pyperclip.copy(md_output)

print("✅ PDF highlights copied to clipboard!")
EOF

