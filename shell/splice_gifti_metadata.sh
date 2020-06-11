#!/bin/bash

cd /cbica/projects/UVMdata/analysis
regex='<Data>(.|\n)*?<\/Data>' # https://stackoverflow.com/a/16880892/2624391
for subj in $(ls | grep ^sub- | tr "-" "\n" | grep -v sub)
do
    for hemi in L R
    do
        orig_gifti="/cbica/projects/UVMdata/bids/output/2020-06-07/sub-$subj/MNINonLinear/sub-$subj.$hemi.MyelinMap_BC.164k_fs_LR.func.gii"
        zscored_gifti="/cbica/projects/UVMdata/analysis/sub-$subj/MNINonLinear/sub-$subj.$hemi.MyelinMap_BC.164k_fs_LR.func.gii"
        zscored_data=$(egrep $regex $zscored_gifti)
        cat $orig_gifti | sed -e 's/$regex/$zscored_data/g' > "/cbica/projects/UVMdata/analysis/sub-$subj/MNINonLinear/real-sub-$subj.$hemi.MyelinMap_BC.164k_fs_LR.func.gii"
    done
done