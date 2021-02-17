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
datalad get -r nifti/sub-${sub}
datalad get -r mimosa/sub-${sub}
datalad get -r flirt/sub-${sub}
datalad get simg/mimosa_latest.sif

# let git-annex know that we do not want to remember any of these clones
# (we could have used an --ephemeral clone, but that might deposite data
# of failed jobs at the origin location, if the job runs on a shared
# filesystem -- let's stay self-contained)
git submodule foreach --recursive git annex dead here

# checkout new branches
# this enables us to store the results of this job, and push them back
# without interference from other jobs
git -C flirt/sub-$sub checkout -b "sub-${sub}"

# register t1 to phase, save transformation matrix
datalad run -i "nifti/sub-${sub}" -i "simg/mimosa_latest.sif" -o "flirt/sub-${sub}" \
    singularity exec --cleanenv -B $TMPDIR simg/mimosa_latest.sif \
    flirt -in $PWD/nifti/sub-${sub}/ses-01/anat/sub-${sub}_ses-01_run-001_T1w.nii.gz \
    -ref $PWD/nifti/sub-${sub}/ses-01/anat/sub-${sub}_ses-01_run-001_part-phase_T2star_UNWRAPPED_lpi.nii.gz \
    -out $PWD/flirt/sub-${sub}/sub-${sub}_t1_r2_phasecorlpi.nii.gz \
    -omat $PWD/flirt/sub-${sub}/sub-${sub}_t1_r2_phasecorlpi.mat \
    -dof 6 -cost mutualinfo -searchcost mutualinfo -interp nearestneighbour
# apply registration to lesion probability map
datalad run -i "nifti/sub-${sub}" -i "mimosa/sub-${sub}" -i "simg/mimosa_latest.sif" -o "flirt/sub-${sub}" \
    singularity exec --cleanenv -B $TMPDIR simg/mimosa_latest.sif \
    flirt -in $PWD/mimosa/sub-${sub}/probability_map.nii.gz \
    -ref $PWD/nifti/sub-${sub}/ses-01/anat/sub-${sub}_ses-01_run-001_part-phase_T2star_UNWRAPPED_lpi.nii.gz \
    -out $PWD/flirt/sub-${sub}/sub-${sub}_probmap_r2_phasecorlpi.nii.gz \
    -init $PWD/flirt/sub-${sub}/sub-${sub}_t1_r2_phasecorlpi.mat \
    -applyxfm \
    -interp nearestneighbour
# apply registration to lesmask (undilated)
datalad run -i "nifti/sub-${sub}" -i "mimosa/sub-${sub}" -i "simg/mimosa_latest.sif" -o "flirt/sub-${sub}" \
    singularity exec --cleanenv -B $TMPDIR simg/mimosa_latest.sif \
    flirt -in $PWD/mimosa/sub-${sub}/mimosa_binary_mask_0.2.nii.gz \
    -ref $PWD/nifti/sub-${sub}/ses-01/anat/sub-${sub}_ses-01_run-001_part-phase_T2star_UNWRAPPED_lpi.nii.gz \
    -out $PWD/flirt/sub-${sub}/sub-${sub}_lesmask_r2_phasecorlpi.nii.gz \
    -init $PWD/flirt/sub-${sub}/sub-${sub}_t1_r2_phasecorlpi.mat \
    -applyxfm \
    -interp nearestneighbour



# selectively push outputs only
# ignore root dataset, despite recorded changes, needs coordinated
# merge at receiving end
flock $DSLOCKFILE datalad push -r -d flirt/sub-${sub} --to origin

cd ../..
chmod -R 777 $wrkDir
rm -rf $wrkDir

