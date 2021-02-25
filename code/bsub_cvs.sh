#!/bin/bash

cd $(dirname $0)/..
export DSLOCKFILE=$PWD/.git/datalad_lock
touch $DSLOCKFILE
for sub in $(ls sourcedata | grep MSDC | grep -Eo "[0-9]+"); do
    bsub -o logs -e logs ./code/cvs.sh $sub
done
