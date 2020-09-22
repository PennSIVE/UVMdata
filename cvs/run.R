source("centralveins_full.R")
library(neurobase)

setwd("/out")
result = centralveins(readnii("/epi.nii.gz"), readnii("/t1.nii.gz"), readnii("/flair.nii.gz"), parallel=T, cores=as.numeric(Sys.getenv("NSLOTS"), c3d=T))
saveRDS(result, file = "centralveins")
