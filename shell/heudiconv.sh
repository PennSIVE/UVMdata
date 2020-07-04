#!/bin/bash

set -euf -o pipefail

echo "Running heudiconv at `date`"

# generate TSVs to write heuristic
# ls /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC | grep ^0 | xargs -I {} \
# singularity run -B /cbica/projects/UVMdata/bids/datasets/2020-06-07:/out -B /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC:/in:ro /cbica/home/robertft/singularity_images/heudiconv_latest.sif \
# 	-d "/in/{subject}/*/*.dcm" \
# 	-o /out -f convertall -s {} -c none --overwrite
# write heuristic, then
mkdir -p /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti
ls /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC | grep ^0 | xargs -I {} \
singularity run -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti:/out -B /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC:/in:ro -B /cbica/projects/UVMdata/repos/UVMdata/bids:/code /cbica/home/robertft/singularity_images/heudiconv_latest.sif \
	-d "/in/{subject}/*/*.dcm" \
	-o /out -f /code/heuristic.py -s {} -c dcm2niix -b --overwrite

# subject 55 has a different naming convention, process seperatly
singularity run -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti:/out -B /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC:/in:ro -B /cbica/projects/UVMdata/repos/UVMdata/bids:/code /cbica/home/robertft/singularity_images/heudiconv_latest.sif \
	-d "/in/{subject}/*/*/*.dcm" \
	-o /out -f /code/heuristic.py -s 055 -c dcm2niix -b --overwrite

echo "Finished heudiconv at `date`"








# 
# with heuristic_all.py
# 
# for subj in $(ls /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC | grep ^0)
# do
# qsub -cwd -b y singularity run -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all:/out -B /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC:/in:ro -B /cbica/projects/UVMdata/repos/UVMdata/bids:/code /cbica/home/robertft/singularity_images/heudiconv_latest.sif \
# 	-d "/in/{subject}/*/*.dcm" \
# 	-o /out -f /code/heuristic_all.py -s $subj -ss 001 -c dcm2niix -b --overwrite
# done
# singularity run -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all:/out -B /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC:/in:ro -B /cbica/projects/UVMdata/repos/UVMdata/bids:/code /cbica/home/robertft/singularity_images/heudiconv_latest.sif \
# 	-d "/in/{subject}/*/*/*.dcm" \
# 	-o /out -f /code/heuristic_all.py -s 055 -ss 001 -c dcm2niix -b --overwrite