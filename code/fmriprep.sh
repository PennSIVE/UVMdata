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
datalad get nifti
datalad get -r nifti/sub-${sub}
datalad get fmriprep
datalad get -r fmriprep/sub-${sub}
datalad get -r templateflow
datalad get simg/fmriprep_20.0.5.sif
datalad get licenses/license.txt
# let git-annex know that we do not want to remember any of these clones
# (we could have used an --ephemeral clone, but that might deposite data
# of failed jobs at the origin location, if the job runs on a shared
# filesystem -- let's stay self-contained)
git submodule foreach --recursive git annex dead here

# checkout new branches
# this enables us to store the results of this job, and push them back
# without interference from other jobs
git -C fmriprep checkout -b "sub-${sub}"
git -C fmriprep/sub-$sub checkout -b "sub-${sub}"
mkdir -p .git/tmp/wdir

export SINGULARITYENV_TMPDIR=$TMPDIR
export SINGULARITYENV_TEMPLATEFLOW_HOME=/opt/templateflow
# yay time to run
datalad run -i "nifti" -i "nifti/sub-${sub}" -i "templateflow" -i "simg/fmriprep_20.0.5.sif" -o "fmriprep" -m "fMRIprep $sub" \
    singularity run --cleanenv \
    -B /project -B $TMPDIR -B $PWD/templateflow:/opt/templateflow -B $PWD/licenses/license.txt:/opt/freesurfer/license.txt \
    $PWD/simg/fmriprep_20.0.5.sif \
    ./nifti . participant \
    --participant-label $sub \
    --n_cpus 1 \
    --skip-bids-validation \
    -w .git/tmp/wdir \
    --skull-strip-fixed-seed \
    --anat-only \
    --fs-no-reconall \
    --notrack \
    --fs-license-file /opt/freesurfer/license.txt \
    --output-spaces MNI152NLin2009cAsym \
    --skull-strip-template OASIS30ANTs


# selectively push outputs only
# ignore root dataset, despite recorded changes, needs coordinated
# merge at receiving end
flock $DSLOCKFILE datalad push -r -d fmriprep --to origin

cd ../..
chmod -R 777 $wrkDir
rm -rf $wrkDir
