#!/bin/bash
# regenerate CIFTI from GIFTIs
# usage: singularity exec -B output/sub-01/MNINonLinear:/input ~/singularity_images/hcppipelines_latest.sif ./gifti2cifti.sh /input 01

CARET7DIR=/opt/workbench/bin_linux64
Folder=$1
Subject=sub-$2
ROIFolder=/orig
Map=MyelinMap_BC
Mesh=164k_fs_LR
Ext=func
ROI=atlasroi # not 100% sure about this one -- could be any of `find . -name 'sub-01.L.*.164k_fs_LR.shape.gii'`?

# https://www.humanconnectome.org/software/workbench-command/-cifti-create-dense-scalar
# https://github.com/Washington-University/HCPpipelines/blob/master/PostFreeSurfer/scripts/CreateMyelinMaps.sh#L254
# func.gii is a metric for left/right surface, shape.gii is a roi of vertices to use from left/right surface
${CARET7DIR}/wb_command -cifti-create-dense-scalar "$Folder"/"$Subject".${Map}."$Mesh".dscalar.nii \
	-left-metric "$Folder"/real-"$Subject".L.${Map}."$Mesh"."$Ext".gii -roi-left "$ROIFolder"/"$Subject".L."$ROI"."$Mesh".shape.gii \
	-right-metric "$Folder"/real-"$Subject".R.${Map}."$Mesh"."$Ext".gii -roi-right "$ROIFolder"/"$Subject".R."$ROI"."$Mesh".shape.gii
#                           ^ 'real-' because that's what splice_gifti_metadata.sh calls them
