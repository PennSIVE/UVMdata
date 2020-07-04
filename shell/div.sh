#!/bin/bash

for dir in $(find /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/derivatives -name flair_n4_reg2t1n4_brain_ws.nii.gz | xargs dirname)
do
    singularity exec -B $dir /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript -e "library(neurobase); writenii(readnii('${dir}/t1_n4_brain.nii.gz') / readnii('${dir}/flair_n4_reg2t1n4_brain_ws.nii.gz'), filename = '${dir}/T1DivByFlair.nii.gz')"

    singularity exec -B $dir /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript -e "library(neurobase); writenii(readnii('${dir}/t1_n4_brain_ws.nii.gz') / readnii('${dir}/flair_n4_reg2t1n4_brain_ws.nii.gz'), filename = '${dir}/T1WsDivByFlair.nii.gz')"
done