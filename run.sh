#!/bin/bash

set -euf -o pipefail

# Unzip dicom directories
$unzip=$(qsub -cwd -terse -o unzip.1 -e unzip.2 ./shell/unzip.sh)
# Convert dicoms to niftis using
$dcm2nii=$(qsub -hold_jid $unzip -cwd -terse -o heudiconv.1 -e heudiconv.2 ./shell/heudiconv.sh)
# Process images with
$processed=$(qsub -hold_jid $dcm2nii -cwd -terse ./bash/hcppipelines.sh)
# Copy output to analysis directory, z-score myelin maps, regenerate CIFTIs
# qsub -hold_jid $processed -cwd ./shell/analysis.sh