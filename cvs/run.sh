#!/bin/bash

for subj in $(ls ~/dropbox/UVMdata | grep -v x22)
do
    mkdir -p ~/dropbox/jordan/${subj}
    qsub -b y -cwd -l h_vmem=512G -pe threaded 1-20 -o ~/sge/\$JOB_ID -e ~/sge/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS singularity run --cleanenv \
    -B ~/dropbox/jordan/code/cvs:/code:ro \
    -B ~/dropbox/UVMdata/${subj}/flair.nii.gz:/flair.nii.gz:ro \
    -B ~/dropbox/UVMdata/${subj}/mprage.nii.gz:/t1.nii.gz:ro \
    -B ~/dropbox/UVMdata/${subj}/T2star.nii.gz:/epi.nii.gz:ro \
    -B ~/dropbox/jordan/${subj}:/out \
    --pwd /code \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript run.R
done


for subj in $(ls ~/bids/datasets/2020-06-07/Nifti_all_combined | grep ^sub)
do
    mkdir -p ~/dropbox/jordan_new/${subj}
    qsub -b y -cwd -l h_vmem=512G -pe threaded 1-20 -o ~/sge/\$JOB_ID -e ~/sge/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS singularity run --cleanenv \
    -B ~/dropbox/jordan/code/cvs:/code:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T2w.nii.gz:/flair.nii.gz:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T1w.nii.gz:/t1.nii.gz:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T2star1.nii.gz:/epi.nii.gz:ro \
    -B ~/dropbox/jordan_new/${subj}:/out \
    --pwd /code \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript run.R
done

