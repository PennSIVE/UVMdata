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
datalad get -r preprocessed/sub-${sub}
datalad get -r mimosa/sub-${sub}
datalad get simg/mimosa_latest.sif
# let git-annex know that we do not want to remember any of these clones
# (we could have used an --ephemeral clone, but that might deposite data
# of failed jobs at the origin location, if the job runs on a shared
# filesystem -- let's stay self-contained)
git submodule foreach --recursive git annex dead here

# checkout new branches
# this enables us to store the results of this job, and push them back
# without interference from other jobs
git -C mimosa/sub-$sub checkout -b "sub-${sub}"

# yay time to run
datalad run -i preprocessed/sub-$sub -i simg/mimosa_latest.sif -o mimosa/sub-$sub \
    singularity run --cleanenv \
    -B /project -B $TMPDIR -B $TMPDIR:/tmp \
    $PWD/simg/mimosa_latest.sif \
    $PWD/preprocessed $PWD/mimosa/sub-${sub} participant --participant_label $sub --t1_label T1wBrainWS --flair_label FLAIRregBrainWS --skip_bids_validator

# selectively push outputs only
# ignore root dataset, despite recorded changes, needs coordinated
# merge at receiving end
flock $DSLOCKFILE datalad push -d mimosa/sub-${sub} --to origin

cd ../..
chmod -R 777 $wrkDir
rm -rf $wrkDir

