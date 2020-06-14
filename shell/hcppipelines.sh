#!/bin/bash

set -euf -o pipefail

mkdir /cbica/projects/UVMdata/bids/output/2020-06-07
cd /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti
for x in $(ls | grep ^sub | cut -c 5-)
do
    qsub -b y -pe threaded 1-8 -l h_vmem=6G -cwd \
        -o /cbica/projects/UVMdata/bids/datasets/2020-06-07/hcp_output/\$JOB_ID.stdout \
        -e /cbica/projects/UVMdata/bids/datasets/2020-06-07/hcp_output/\$JOB_ID.stderr env -i singularity run \
        -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti:/bids_dataset:ro \
        -B /cbica/projects/UVMdata/bids/output/2020-06-07:/output \
        /cbica/home/robertft/singularity_images/hcppipelines_latest.sif \
        /bids_dataset /output participant --participant_label $x --license_key "46946"
done
