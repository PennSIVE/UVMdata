source("centralveins_weighted_presegmented.R")
library(neurobase)

setwd("/out")
result = centralveins_weighted_presegmented(readnii("/lesmap.nii.gz"), readnii("/veinmap.nii.gz"), readnii("/epi.nii.gz"), parallel=T, cores=as.numeric(Sys.getenv("NSLOTS")))
saveRDS(result, file = "centralveins_weighted")
