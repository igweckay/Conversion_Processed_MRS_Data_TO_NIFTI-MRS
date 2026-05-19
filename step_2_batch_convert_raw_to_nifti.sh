#!/bin/bash

BASE_DIR="/path/to/AUGMENTRUM-COWS-DATA"

find "$BASE_DIR" -name "*_Metab.raw" | while read -r metab_raw; do
    dir=$(dirname "$metab_raw")
    base=$(basename "$metab_raw" .raw)          # e.g. VAPOR_7_Occipital_Metab

    # Derive water counterpart
    water_raw="${dir}/${base}_Water.raw"

    # --- spec2nii: Metab ---
    if [ -f "${dir}/${base}.nii.gz" ]; then
        echo "SKIP spec2nii (exists): ${dir}/${base}.nii.gz"
    else
        echo "spec2nii: $metab_raw"
        spec2nii raw \
            -n 1H \
            -i 123.259484 \
            -b 4000 \
            -f "$base" \
            -j \
            -o "$dir" \
            "$metab_raw"
    fi

    # --- spec2nii: Water ---
    if [ -f "${dir}/${base}_Water.nii.gz" ]; then
        echo "SKIP spec2nii (exists): ${dir}/${base}_Water.nii.gz"
    elif [ -f "$water_raw" ]; then
        echo "spec2nii: $water_raw"
        spec2nii raw \
            -n 1H \
            -i 123.259484 \
            -b 4000 \
            -f "${base}_Water" \
            -j \
            -o "$dir" \
            "$water_raw"
    else
        echo "WARN: no water raw found for $metab_raw"
    fi

    # --- fsl_mrs_proc conj: Metab ---
    if [ -f "${dir}/${base}_conj.nii.gz" ]; then
        echo "SKIP conj (exists): ${dir}/${base}_conj.nii.gz"
    elif [ -f "${dir}/${base}.nii.gz" ]; then
        echo "conj: ${dir}/${base}.nii.gz"
        fsl_mrs_proc conj \
            --file "${dir}/${base}.nii.gz" \
            --output "${dir}/${base}_conj.nii.gz"
    fi

    # --- fsl_mrs_proc conj: Water ---
    if [ -f "${dir}/${base}_Water_conj.nii.gz" ]; then
        echo "SKIP conj (exists): ${dir}/${base}_Water_conj.nii.gz"
    elif [ -f "${dir}/${base}_Water.nii.gz" ]; then
        echo "conj: ${dir}/${base}_Water.nii.gz"
        fsl_mrs_proc conj \
            --file "${dir}/${base}_Water.nii.gz" \
            --output "${dir}/${base}_Water_conj.nii.gz"
    fi

done