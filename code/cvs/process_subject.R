source("centralveins.R")
library(neurobase)
load("/models/mimosa_model.RData")
args = commandArgs(TRUE)
sub = args[1]

setwd(paste0("../../nifti/sub-", sub, "/ses-01/anat"))
epi = readnii(paste0("sub-", sub, "_ses-01_run-001_part-mag_T2star.nii.gz"))
t1 = readnii(paste0("sub-", sub, "_ses-01_run-001_T1w.nii.gz"))
flair = readnii(paste0("sub-", sub, "_ses-01_run-001_FLAIR.nii.gz"))
# setwd(paste0("../../../../preprocessed/sub-", sub, "/anat"))
# t1 = readnii(paste0("/sub-", sub, "_ses-01_run-001_T1wBrainWS"))
# flair = readnii(paste0("/sub-", sub, "_ses-01_run-001_FLAIRregBrainWS"))
setwd("/out")
centralveins_preproc(epi, t1, flair, skullstripped = F, biascorrected = F)

epi_n4_brain = readnii('epi_brain.nii.gz')
t1_reg = readnii('t1_n4_reg_flair.nii.gz')
flair_n4_brain = readnii('flair_brain.nii.gz')
brainmask_reg = readnii('brainmask_reg_flair.nii.gz')
csf = readnii('csf.nii.gz')
flair_to_epi_filename = 'flair_to_epi'
centralveins_seg(epi_n4_brain, t1_reg, flair_n4_brain, brainmask_reg, csf, flair_to_epi_filename, mimosa_model = mimosa_model, probmap = NULL, parallel = T, cores = as.numeric(Sys.getenv("NSLOTS")), probthresh = 0.2)

result = centralveins(readnii("les_reg.nii.gz"), readnii("frangi.nii.gz"), readnii("dtb.nii.gz"), parallel = T, cores = as.numeric(Sys.getenv("NSLOTS")))

saveRDS(result, file = "centralveins")
