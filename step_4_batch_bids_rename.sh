#!/bin/bash

OSPREY_DIR="/path/to/OSPREY-FILES"

for bids_folder in OCC PAR PFC; do

    find "$OSPREY_DIR/$bids_folder" -type d -name "sub-*" | sort | while read -r sub_dir; do

        sub_label=$(basename "$sub_dir")
        mrs_dir="$sub_dir/ses-01/mrs"

        if [ ! -d "$mrs_dir" ]; then
            echo "SKIP (no mrs dir): $sub_dir"
            continue
        fi

        # Rename Water conj file
        water_src=$(find "$mrs_dir" -maxdepth 1 -type f -name "*Water_conj.nii.gz" | head -1)
        if [ -n "$water_src" ]; then
            water_dest="$mrs_dir/${sub_label}_ses-01_${bids_folder}_Water.nii.gz"
            if [ -f "$water_dest" ]; then
                echo "SKIP (exists): $water_dest"
            else
                echo "RENAME: $water_src --> $water_dest"
                mv "$water_src" "$water_dest"
            fi
        fi

        # Rename Metab conj file
        metab_src=$(find "$mrs_dir" -maxdepth 1 -type f -name "*Metab_conj.nii.gz" | head -1)
        if [ -n "$metab_src" ]; then
            metab_dest="$mrs_dir/${sub_label}_ses-01_${bids_folder}.nii.gz"
            if [ -f "$metab_dest" ]; then
                echo "SKIP (exists): $metab_dest"
            else
                echo "RENAME: $metab_src --> $metab_dest"
                mv "$metab_src" "$metab_dest"
            fi
        fi

    done

done