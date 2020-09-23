#!/bin/bash

for i in $(seq 1 10)
do
    # mkdir ~/dropbox/repro7_jordan_new_iter_${i}
    qsub -b y -cwd -l h_vmem=416G -pe threaded 2-64 -o ~/sge/\$JOB_ID -e ~/sge/\$JOB_ID \
    SINGULARITYENV_NSLOTS=\$NSLOTS singularity run --cleanenv \
    --pwd ~/dropbox/repos/UVMdata/cvs \
    -B ~/dropbox/repro7_jordan_new_iter_${i}:/cbica/projects/UVMdata/dropbox/repro7_jordan_new_iter_n \
    /cbica/home/robertft/singularity_images/neuror_4.0.sif \
    Rscript simple.R
done