# AUGMENTRUM-COWS-DATA MRS Processing Pipeline

A set of bash and Python scripts for converting raw MRS .mat files into BIDS-compatible NIfTI files for use with Osprey (https://github.com/schorschinho/osprey).

The raw and the processed dataset can be found on OpenNeuro: https://openneuro.org/datasets/ds006812/versions/1.0.1
Look in the derivatives folder for the processed .mat files per subject, per region of interest, and per water suppression module.

---

## Overview

This pipeline takes MATLAB .mat files exported from a 3T MRS acquisition (using VAPOR water suppression) and sends them through four sequential steps:

1. Convert .mat to .raw (LCModel format)
2. Convert .raw to .nii.gz and apply conjugate correction
3. Build a BIDS directory structure under OSPREY-FILES/
4. Rename files to BIDS-compliant filenames

---

## Directory Structure

### Input (AUGMENTRUM-COWS-DATA)

    AUGMENTRUM-COWS-DATA/
    ├── COWS2/
    │   └── MAT/
    │       ├── OCCIPITAL/
    │       │   ├── VAPOR_7_Occipital_Metab.mat
    │       │   └── VAPOR_7_Occipital_Metab_Water.mat
    │       ├── PARIETAL/
    │       └── PFC/
    ├── COWS3/
    ├── COWS4/
    │   ...
    └── COWS11/

### Output (OSPREY-FILES)

    OSPREY-FILES/
    ├── OCC/
    │   ├── sub-01/ses-01/mrs/
    │   │   ├── sub-01_ses-01_OCC.nii.gz
    │   │   └── sub-01_ses-01_OCC_Water.nii.gz
    │   ├── sub-02/ses-01/mrs/
    │   └── ...
    ├── PAR/
    │   └── sub-01/ses-01/mrs/
    │       ├── sub-01_ses-01_PAR.nii.gz
    │       └── sub-01_ses-01_PAR_Water.nii.gz
    └── PFC/
        └── sub-01/ses-01/mrs/
            ├── sub-01_ses-01_PFC.nii.gz
            └── sub-01_ses-01_PFC_Water.nii.gz

Subject mapping: COWS2 -> sub-01, COWS3 -> sub-02, etc.

---

## Dependencies

- Python 3 with scipy and numpy
- spec2nii (https://github.com/wtclarke/spec2nii)
- fsl_mrs (https://git.fmrib.ox.ac.uk/fsl/fsl_mrs)

---

## Scripts

### step_0_mat_to_raw.py

Converts a single .mat file to LCModel .raw format.

- Reads the exptDat struct from the .mat file
- Extracts FID, spectral frequency, and dwell time
- Flips the imaginary sign to match LCModel .raw convention
- Can be run directly on a single file by editing the hardcoded paths at the top

Usage: python step_1_mat_to_raw.py input.mat output.raw

---

### step_1_batch_convert_mat_to_raw.sh

Batch wrapper for step_1_mat_to_raw.py. Recursively finds all .mat files under BASE_DIR and converts each one, skipping any .raw that already exists.

Before running, update:
- BASE_DIR — path to your AUGMENTRUM-COWS-DATA folder
- SCRIPT — path to step_1_mat_to_raw.py

Usage: ./step_1_batch_convert_mat_to_raw.sh

---

### step_2_batch_convert_raw_to_nifti.sh

For each Metab.raw file found under BASE_DIR:

1. Runs spec2nii raw on the Metab and Water .raw files to produce .nii.gz and .json
2. Runs fsl_mrs_proc conj on both .nii.gz files to produce _conj.nii.gz

Skips any output that already exists.

Before running, update:
- BASE_DIR — path to your AUGMENTRUM-COWS-DATA folder

Usage: ./step_2_batch_convert_raw_to_nifti.sh

---

### step_3_batch_create_bids_for_osprey.sh

Builds the BIDS directory structure under OSPREY-FILES/ and copies the _conj.nii.gz files into the appropriate mrs/ folders.

- Maps COWS folders to sub-XX labels (COWS2 -> sub-01, etc.)
- Handles all three regions: OCCIPITAL -> OCC, PARIETAL -> PAR, PFC -> PFC
- Skips any file that already exists at the destination

Before running, update:
- BASE_DIR — path to your AUGMENTRUM-COWS-DATA folder

Usage: ./step_3_batch_create_bids_for_osprey.sh

---

### step_4_batch_bids_rename.sh

Renames the copied _conj.nii.gz files inside each mrs/ folder to BIDS-compliant filenames:

| Before | After |
|--------|-------|
| VAPOR_7_Occipital_Metab_conj.nii.gz | sub-01_ses-01_OCC.nii.gz |
| VAPOR_7_Occipital_Metab_Water_conj.nii.gz | sub-01_ses-01_OCC_Water.nii.gz |
| VAPOR_7_Parietal_Metab_conj.nii.gz | sub-01_ses-01_PAR.nii.gz |
| VAPOR_7_PFC_Metab_conj.nii.gz | sub-01_ses-01_PFC.nii.gz |

Skips any file that has already been renamed.

Before running, update:
- OSPREY_DIR — path to your OSPREY-FILES folder

Usage: ./step_4_batch_bids_rename.sh

---

## Running the Full Pipeline

    Step 1 - Convert .mat to .raw
    ./step_1_batch_convert_mat_to_raw.sh

    Step 2 - Convert .raw to .nii.gz and apply conjugate correction
    ./step_2_batch_convert_raw_to_nifti.sh

    Step 3 - Build BIDS structure and copy conj files
    ./step_3_batch_create_bids_for_osprey.sh

    Step 4 - Rename files to BIDS-compliant names
    ./step_4_batch_bids_rename.sh

All scripts are safe to re-run — they skip any output that already exists and will never overwrite files.

---

## Notes

- COWS7 and COWS8 (and any other subjects) must have their region folders nested under a MAT/ subfolder to match the expected structure: COWS*/MAT/OCCIPITAL, COWS*/MAT/PARIETAL, COWS*/MAT/PFC
- The _conj.nii.gz outputs from fsl_mrs_proc are folders containing the actual .nii.gz file inside — step 3 handles this automatically
