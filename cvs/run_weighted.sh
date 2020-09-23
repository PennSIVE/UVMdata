#!/bin/bash

for subj in $(ls ~/dropbox/UVMdata | grep -v x22)
do
    mkdir -p ~/dropbox/jordan/${subj}
    qsub -b y -cwd -l h_vmem=512G -pe threaded 1-20 -o ~/sge/\$JOB_ID -e ~/sge/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS singularity run --cleanenv \
    -B ~/repos/UVMdata/cvs:/code:ro \
    -B ~/dropbox/jordan/${subj}/candidate.lesions.nii.gz:/lesmap.nii.gz:ro \
    -B ~/dropbox/jordan/${subj}/frangi.nii.gz:/veinmap.nii.gz:ro \
    -B ~/dropbox/jordan/${subj}/epi_brain.nii.gz:/epi.nii.gz:ro \
    -B ~/dropbox/jordan/${subj}:/out \
    --pwd /code \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript run_weighted.R
done


for subj in $(ls ~/bids/datasets/2020-06-07/Nifti_all_combined | grep ^sub)
do
    mkdir -p ~/dropbox/repro_jordan_new/${subj}
    qsub -b y -cwd -l h_vmem=512G -pe threaded 1-20 -o ~/sge/\$JOB_ID -e ~/sge/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS singularity run --cleanenv \
    -B ~/repos/UVMdata/cvs:/code:ro \
    -B ~/dropbox/repro_jordan_new/${subj}/candidate.lesions.nii.gz:/lesmap.nii.gz:ro \
    -B ~/dropbox/repro_jordan_new/${subj}/frangi.nii.gz:/veinmap.nii.gz:ro \
    -B ~/dropbox/repro_jordan_new/${subj}/epi_brain.nii.gz:/epi.nii.gz:ro \
    -B ~/dropbox/repro_jordan_new/${subj}:/out \
    --pwd /code \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript run_weighted.R
done

