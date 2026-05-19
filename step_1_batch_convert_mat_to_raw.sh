#!/bin/bash

BASE_DIR="/path/to/AUGMENTRUM-COWS-DATA"
SCRIPT="/path/to/python/file/step_0_mat_to_raw.py"  # <-- update this path

find "$BASE_DIR" -name "*.mat" | while read -r mat_file; do
    raw_file="${mat_file%.mat}.raw"

    if [ -f "$raw_file" ]; then
        echo "SKIP (exists): $raw_file"
    else
        echo "Converting: $mat_file"
        python "$SCRIPT" "$mat_file" "$raw_file"
        if [ $? -eq 0 ]; then
            echo "  Done: $raw_file"
        else
            echo "  ERROR converting: $mat_file"
        fi
    fi
done

