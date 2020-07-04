#!/bin/bash

cd /cbica/projects/UVMdata/dropbox/UVMdata-upload-2020-06-07
mkdir unzipped
ls | grep ^M | xargs -I {} unzip "{}" -d unzipped
cd unzipped
mv 'MRIs, prelim analyses MSDC' MRIs_prelim_analyses_MSDC
cd MRIs_prelim_analyses_MSDC
for x in $(ls | tr "_" "\n"); do mkdir "$x"; done
rmdir MSDC
for x in $(ls | grep ^0); do unzip -o "MSDC_$x/*" -d $x; done

