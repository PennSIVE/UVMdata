#!/bin/bash

seed=123
for subj in $(ls ~/dropbox/UVMdata | grep -v x22)
do
    rm -rf ~/dropbox/10_9_2020_seed${seed}_orig_builtin/${subj}
    mkdir -p ~/dropbox/10_9_2020_seed${seed}_orig_builtin/${subj}
    qsub -b y -cwd -l h_vmem=512G -pe threaded 1-32 -o ~/dropbox/10_9_2020_seed${seed}_orig_builtin/${subj}/\$JOB_ID -e ~/dropbox/10_9_2020_seed${seed}_orig_builtin/${subj}/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS \
    SINGULARITYENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=\$NSLOTS \
    SINGULARITYENV_ANTS_RANDOM_SEED=${seed} \
    singularity run --cleanenv \
    -B ~/dropbox/code/cvs:/code:ro \
    -B ~/dropbox/UVMdata/${subj}/flair.nii.gz:/flair.nii.gz:ro \
    -B ~/dropbox/UVMdata/${subj}/mprage.nii.gz:/t1.nii.gz:ro \
    -B ~/dropbox/UVMdata/${subj}/T2star.nii.gz:/epi.nii.gz:ro \
    -B ~/dropbox/10_9_2020_seed${seed}_orig_builtin/${subj}:/out \
    --pwd /code \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript run.R
done
for subj in $(ls ~/dropbox/UVMdata | grep -v x22)
do
    rm -rf ~/dropbox/10_9_2020_seed${seed}_orig_mm/${subj}
    mkdir -p ~/dropbox/10_9_2020_seed${seed}_orig_mm/${subj}
    qsub -b y -cwd -l h_vmem=512G -pe threaded 1-32 -o ~/dropbox/10_9_2020_seed${seed}_orig_mm/${subj}/\$JOB_ID -e ~/dropbox/10_9_2020_seed${seed}_orig_mm/${subj}/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS \
    SINGULARITYENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=\$NSLOTS \
    SINGULARITYENV_ANTS_RANDOM_SEED=${seed} \
    SINGULARITYENV_MIMOSA_MODEL=~/phaserim/mimosa_models/melissa_mimosa_model.RData \
    singularity run --cleanenv \
    -B ~/dropbox/code/cvs:/code:ro \
    -B ~/dropbox/UVMdata/${subj}/flair.nii.gz:/flair.nii.gz:ro \
    -B ~/dropbox/UVMdata/${subj}/mprage.nii.gz:/t1.nii.gz:ro \
    -B ~/dropbox/UVMdata/${subj}/T2star.nii.gz:/epi.nii.gz:ro \
    -B ~/dropbox/10_9_2020_seed${seed}_orig_mm/${subj}:/out \
    --pwd /code \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript run.R
done


for subj in $(ls ~/bids/datasets/2020-06-07/Nifti_all_combined | grep ^sub)
do
    rm -rf ~/dropbox/10_9_2020_seed${seed}_new_builtin/${subj}
    mkdir -p ~/dropbox/10_9_2020_seed${seed}_new_builtin/${subj}
    qsub -b y -cwd -l h_vmem=512G -pe threaded 1-32 -o ~/dropbox/10_9_2020_seed${seed}_new_builtin/${subj}/\$JOB_ID -e ~/dropbox/10_9_2020_seed${seed}_new_builtin/${subj}/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS \
    SINGULARITYENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=\$NSLOTS \
    SINGULARITYENV_ANTS_RANDOM_SEED=${seed} \
    singularity run --cleanenv \
    -B ~/dropbox/code/cvs:/code:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T2w.nii.gz:/flair.nii.gz:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T1w.nii.gz:/t1.nii.gz:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T2star1.nii.gz:/epi.nii.gz:ro \
    -B ~/dropbox/10_9_2020_seed${seed}_new_builtin/${subj}:/out \
    --pwd /code \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript run.R
done
for subj in $(ls ~/bids/datasets/2020-06-07/Nifti_all_combined | grep ^sub)
do
    rm -rf ~/dropbox/10_9_2020_seed${seed}_new_mm/${subj}
    mkdir -p ~/dropbox/10_9_2020_seed${seed}_new_mm/${subj}
    qsub -b y -cwd -l h_vmem=512G -pe threaded 1-32 -o ~/dropbox/10_9_2020_seed${seed}_new_mm/${subj}/\$JOB_ID -e ~/dropbox/10_9_2020_seed${seed}_new_mm/${subj}/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS \
    SINGULARITYENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=\$NSLOTS \
    SINGULARITYENV_ANTS_RANDOM_SEED=${seed} \
    SINGULARITYENV_MIMOSA_MODEL=~/phaserim/mimosa_models/melissa_mimosa_model.RData \
    singularity run --cleanenv \
    -B ~/dropbox/code/cvs:/code:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T2w.nii.gz:/flair.nii.gz:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T1w.nii.gz:/t1.nii.gz:ro \
    -B ~/bids/datasets/2020-06-07/Nifti_all_combined/${subj}/ses-001/anat/${subj}_ses-001_run-001_T2star1.nii.gz:/epi.nii.gz:ro \
    -B ~/dropbox/10_9_2020_seed${seed}_new_mm/${subj}:/out \
    --pwd /code \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript run.R
done
