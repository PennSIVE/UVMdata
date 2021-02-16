#!/bin/bash

# fail whenever something is fishy, use -x to get verbose logfiles
set -e -u -x

ds_path=$(realpath $(dirname $0)/..)
sub=$1
# $TMPDIR is a more performant local filesystem
wrkDir=$TMPDIR/$LSB_JOBID
mkdir -p $wrkDir
cd $wrkDir
# get the output/input datasets
# flock makes sure that this does not interfere with another job
# finishing at the same time, and pushing its results back
# we clone from the location that we want to push the results too
flock $DSLOCKFILE datalad clone $ds_path ds
# all following actions are performed in the context of the superdataset
cd ds
# obtain datasets
datalad get -r sourcedata/MSDC_${sub}/dicoms
datalad get nifti
datalad get -r nifti/sub-${sub}
datalad get simg/heudiconv_latest.sif
# let git-annex know that we do not want to remember any of these clones
# (we could have used an --ephemeral clone, but that might deposite data
# of failed jobs at the origin location, if the job runs on a shared
# filesystem -- let's stay self-contained)
git submodule foreach --recursive git annex dead here

# checkout new branches
# this enables us to store the results of this job, and push them back
# without interference from other jobs
git -C nifti checkout -b "sub-${sub}"
git -C nifti/sub-$sub checkout -b "sub-${sub}"

# yay time to run
datalad run -i "sourcedata/MSDC_${sub}" -i "simg" -o "nifti" -m "converted MSDC $sub" \
    singularity run --cleanenv \
    -B /project \
    $PWD/simg/heudiconv_latest.sif \
    -d "$PWD/sourcedata/MSDC_{{subject}}/dicoms/*/*.dcm" \
    -o $PWD/nifti -f $PWD/code/UVMheuristic.py -s $sub -ss 01 -c dcm2niix -b

# selectively push outputs only
# ignore root dataset, despite recorded changes, needs coordinated
# merge at receiving end
flock $DSLOCKFILE datalad push -r -d nifti --to origin

cd ..
chmod -R 777 $wrkDir
rm -rf $wrkDir
