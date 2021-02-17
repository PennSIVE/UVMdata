#!/bin/bash

cd $(dirname $0)/..
for sub in $(ls sourcedata | grep MSDC | grep -Eo "[0-9]+"); do
    outdir=./thalamus/sub-${sub}
    stripped=./preprocessed/sub-${sub}/anat/sub-${sub}_ses-01_run-001_T1wBrain.nii.gz
    mkdir -p ${outdir}/{oasis_to_t1,oasis_thalamus_to_t1,thalamus} # make dir for tmp files

    bsub -J "${sub}_jlfpre[1-10]%1" -o ../logs -e ../logs \
        SINGULARITYENV_INDEX=\$LSB_JOBINDEX singularity run --cleanenv \
        -B ${stripped}:/N4_T1_strip.nii.gz:ro \
        -B ${outdir}:/out \
        ./simg/jlf_latest.sif --out /out --type preprocessing --atlas thalamus
    bsub -w "done(${sub}_jlfpre)" -o ../logs -e ../logs \
        singularity run --cleanenv -B ${stripped}:/N4_T1_strip.nii.gz:ro -B ${outdir}:/out \
        ./simg/jlf_latest.sif --out /out --type processing --atlas thalamus
done
