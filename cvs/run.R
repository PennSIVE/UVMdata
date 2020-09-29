source("centralveins_full.R")
library(neurobase)

setwd("/out")
result = centralveins(readnii("/epi.nii.gz"), readnii("/t1.nii.gz"), readnii("/flair.nii.gz"), parallel=F, cores=as.numeric(Sys.getenv("NSLOTS")), c3d=T, seed=as.numeric(Sys.getenv("ANTS_RANDOM_SEED")))
saveRDS(result, file = "centralveins")
