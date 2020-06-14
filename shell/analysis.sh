#!/bin/bash

set -euf -o pipefail

echo "Starting analysis at `date`"

# need to run heudiconv.sh to convert dicoms to niftis
# need to run hcppipelines.sh to run HCP pipelines
wd="/cbica/projects/UVMdata/repos/UVMdata/shell"

# copy MNINonLinear dirs for each subject
cd /cbica/projects/UVMdata
mkdir analysis
ls ./bids/output/2020-06-07 | grep ^sub- | xargs -I {} mkdir analysis/{}
ls ./bids/output/2020-06-07 | grep ^sub- | tr "-" "\n" | grep -v sub | xargs -I {} \
cp -R /cbica/projects/UVMdata/bids/output/2020-06-07/sub-{}/MNINonLinear /cbica/projects/UVMdata/analysis/sub-{}/ # might want to qsub each iteration

# zscore GIFTIs
zscore_jid=$(qsub -terse -b y -o zscore.log -e zscore.err -cwd singularity exec -B /cbica/projects/UVMdata/bids/output/2020-06-07:/input:ro -B /cbica/projects/UVMdata/analysis:/output -B $wd/R/zscore.R:/zscore.R /cbica/home/robertft/singularity_images/neuror_4.0.1.sif Rscript /zscore.R)
# only need to run splice_gifti_metadata.sh if using old (but actually currently current) version of writegii to fix GIFTI meta data
splice_jid=$(qsub -terse -hold_jid $zscore_jid -o splice.log -e splce.err -cwd $wd/splice_gifti_metadata.sh)

# regenerate all CIFTIs from GIFTIs
cd /cbica/projects/UVMdata/analysis
ls | grep ^sub- | tr "-" "\n" | grep -v sub | xargs -I {} \
qsub -hold_jid $splice_jid -b y -cwd -l short singularity exec -B $PWD/sub-{}/MNINonLinear:/input -B $wd/gifti2cifti.sh:/gifti2cifti.sh /cbica/home/robertft/singularity_images/hcppipelines_latest.sif /gifti2cifti.sh /input {}
