#!/bin/bash

#Script to concatenate .fastq.gz outputs
# for example an ONT sequencing run containing a folder for each barcode, and many fastq.gz files within
# Usage: (first make executable chmod u+x)
## ./recurse_dirs

#!/bin/bash

# Function to concatenate .fastq.gz files in a directory
concatenate_fastq() {
    local dir="$1"
    local output_file="$dir/$(basename "$dir").fastq.gz"
    # Check if there are .fastq.gz files in the directory
    if compgen -G "$dir/*.fastq.gz" > /dev/null; then
        # Concatenate .fastq.gz files into a single file
        cat "$dir"/*.fastq.gz > "$output_file"
        echo "Concatenated files in $dir to $output_file"
    else
        echo "No .fastq.gz files found in $dir"
    fi
}

# Main function to recurse through directories
recurse_dirs() {
    local start_dir="$1"
    # Loop through each directory in the starting directory
    for dir in "$start_dir"/*/; do
        # Call function to concatenate .fastq.gz files in each directory
        concatenate_fastq "$dir"
        # Recurse into subdirectories
        if [ -d "$dir" ]; then
            recurse_dirs "$dir"
        fi
    done
}

# Check if directory argument is provided, otherwise use current directory
if [ -n "$1" ]; then
    start_dir="$1"
else
    start_dir="."
fi

# Call the main function with the starting directory
recurse_dirs "$start_dir"
