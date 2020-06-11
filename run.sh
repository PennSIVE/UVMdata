#!/bin/bash

# need to run heudiconv.sh to convert dicoms to niftis
# need to run hcppipelines.sh to run HCP pipelines
wd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # https://stackoverflow.com/a/246128/2624391

# copy MNINonLinear dirs for each subject
cd /cbica/projects/UVMdata
ls ./bids/output/2020-06-07 | grep ^sub- | tr "-" "\n" | grep -v sub | xargs -I {} \
cp -R /cbica/projects/UVMdata/bids/output/2020-06-07/sub-{}/MNINonLinear /cbica/projects/UVMdata/analysis/sub-{}/ # might want to qsub this cp as well

# zscore GIFTIs
zscore_jid=$(qsub -terse -b y -o zscore.log -e zscore.err -cwd singularity exec -B /cbica/projects/UVMdata/bids/output/2020-06-07:/input:ro -B /cbica/projects/UVMdata/analysis:/output -B $wd/R/zscore.R:/zscore.R /cbica/home/robertft/singularity_images/neuror_4.0.1.sif Rscript /zscore.R)
# note: need to run splice_gifti_metadata.sh to fix GIFTI meta data if using old (but actually currently current) version of writegii otherwise wb_command will complain

# regenerate all CIFTIs from GIFTIs
cd /cbica/projects/UVMdata/analysis
ls | grep ^sub- | tr "-" "\n" | grep -v sub | xargs -I {} \
qsub -hold_jid $zscore_jid -b y -cwd -l short singularity exec -B $PWD/sub-{}/MNINonLinear:/input -B $wd/shell/gifti2cifti.sh:/gifti2cifti.sh /cbica/home/robertft/singularity_images/hcppipelines_latest.sif /gifti2cifti.sh /input {}
