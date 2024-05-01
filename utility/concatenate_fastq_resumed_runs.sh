#!/bin/bash

#Run in main directory, containing one directory for each resumed run, containing barcode[0-9].fastq.gz files
#Will take any partial matches (e.g. also to SQK-NBD114-96_barcode79.fastq.gz)

# Function to recursively concatenate files matching a pattern
recursive_concatenate() {
    local output_dir="$1"

    # Find files matching the pattern
    find . -type f -iname '*barcode[0-9]*.fastq.gz' -print0 |
    while IFS= read -r -d '' file; do
        # Extract barcode number
        barcode=$(echo "$file" | grep -oE 'barcode[0-9]+')
        echo "Found file: $file, Barcode: $barcode"
        # Concatenate file to corresponding barcode file
        cat "$file" >> "$output_dir/$barcode.fastq.gz"
    done
}

# Specify the output directory for concatenated files
output_dir="concatenated"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Call the recursive function to concatenate files
recursive_concatenate "$output_dir"

echo "Concatenation complete."
