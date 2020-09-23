#!/bin/bash


qsub -b y -cwd -l h_vmem=512G -pe threaded 2-64 -o ~/sge/\$JOB_ID -e ~/sge/\$JOB_ID \
SINGULARITYENV_NSLOTS=\$NSLOTS singularity run --cleanenv \
-B ~/dropbox/repos/UVMdata/cvs:/code:ro --pwd /code \
/cbica/home/robertft/singularity_images/neuror_4.0.sif \
Rscript simple.R