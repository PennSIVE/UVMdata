#!/bin/bash

# generate TSVs to write heuristic
ls /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC | grep ^0 | xargs -I {} \
singularity run -B /cbica/projects/UVMdata/bids/datasets/2020-06-07:/out -B /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC:/in:ro /cbica/home/robertft/singularity_images/heudiconv_latest.sif \
	-d "/in/{subject}/*/*.dcm" \
	-o /out -f convertall -s {} -c none --overwrite
# write heuristic, then
ls /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC | grep ^0 | xargs -I {} \
singularity run -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti:/out -B /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07/unzipped/MRIs_prelim_analyses_MSDC:/in:ro /cbica/home/robertft/singularity_images/heudiconv_latest.sif \
	-d "/in/{subject}/*/*.dcm" \
	-o /out -f heuristic.py -s {} -c dcm2niix -b --overwrite
