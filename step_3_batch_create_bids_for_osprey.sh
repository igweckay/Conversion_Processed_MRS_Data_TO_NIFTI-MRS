#!/bin/bash

BASE_DIR="/path/to/AUGMENTRUM-COWS-DATA"
OSPREY_DIR="$BASE_DIR/OSPREY-FILES"

# Find all COWS* folders, sorted, and assign sub-XX indices
find "$BASE_DIR" -maxdepth 1 -type d -name "COWS*" | sort | while read -r cows_dir; do

    cows_num=$(basename "$cows_dir" | sed 's/COWS//')
    sub_num=$(printf "%02d" $(( cows_num - 1 )))
    sub_label="sub-${sub_num}"

    for region in OCCIPITAL PARIETAL PFC; do

        case "$region" in
            OCCIPITAL) bids_folder="OCC" ;;
            PARIETAL)  bids_folder="PAR" ;;
            PFC)       bids_folder="PFC" ;;
        esac

        region_dir="$cows_dir/MAT/$region"

        if [ ! -d "$region_dir" ]; then
            echo "SKIP (no $region): $cows_dir"
            continue
        fi

        mrs_dir="$OSPREY_DIR/$bids_folder/$sub_label/ses-01/mrs"
        mkdir -p "$mrs_dir"

        # Copy *_conj.nii.gz files (stored inside *_conj.nii.gz folders)
        find "$region_dir" -type d -name "*_conj.nii.gz" | while read -r conj_dir; do
            conj_name=$(basename "$conj_dir")
            dest="$mrs_dir/$conj_name"

            if [ -f "$dest" ]; then
                echo "SKIP (exists): $dest"
            else
                src=$(find "$conj_dir" -maxdepth 1 -type f -name "*.nii.gz" | head -1)
                if [ -z "$src" ]; then
                    echo "WARN: no .nii.gz found inside $conj_dir"
                else
                    echo "COPY: $src --> $dest"
                    cp "$src" "$dest"
                fi
            fi
        done

    done

done