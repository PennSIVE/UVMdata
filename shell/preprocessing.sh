#!/bin/bash

set -euf

for subj in $(ls /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all | grep ^sub)
do
    lastT1=$(/cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat/${subj}_ses-001_run-*_T1w.nii.gz | tail -n1)
    lastT2=$(ls /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat/${subj}_ses-001_run-*_T2w.nii.gz | tail -n1)
    mkdir -p /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/derivatives/${subj}/ses-001 || true
    echo "Making /out/${subj}_flair_n4_reg2t1n4_brain_ws from ${lastT1} and ${lastT2}"
    qsub -b y -cwd -l h_vmem=8G -o \$JOB_ID.preproc -e \$JOB_ID.preproc env -i singularity run \
    -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat/${subj}_ses-001_run-001_T2w.nii.gz:/flair.nii.gz:ro \
    -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat/${subj}_ses-001_run-001_T1w.nii.gz:/T1.nii.gz:ro \
    -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/derivatives/${subj}/ses-001:/out \
    /cbica/home/robertft/singularity_images/preprocessing_latest.sif --out /out/${subj}_flair_n4_reg2t1n4_brain_ws
done