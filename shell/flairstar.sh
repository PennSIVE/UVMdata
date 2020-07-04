#!/bin/bash

for subj in $(ls /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all | grep ^sub)
do
    lastT2star=$(/cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat/${subj}_ses-001_run-*_lastT2star1.nii.gz | tail -n1)
    lastFlair=$(ls /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat/${subj}_ses-001_run-*_T2w.nii.gz | tail -n1)
    echo "Making ${subj}_ses-001_FLAIRstar.nii.gz from ${lastT2star} and ${lastFlair}"
    qsub -b y -cwd -l h_vmem=12G -l short -o flairstar.\$JOB_ID -e flairstar.\$JOB_ID singularity run \
    -B $lastFlair:/flair.nii.gz:ro \
    -B $lastT2star:/epi.nii.gz:ro \
    -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat:/out \
    /cbica/home/robertft/singularity_images/flairstar_latest.sif --out ${subj}_ses-001_FLAIRstar.nii.gz
done