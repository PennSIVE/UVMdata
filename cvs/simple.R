
source("helperfunctions.R")
source("centralveins_presegmented.R")
setwd("/cbica/projects/UVMdata/dropbox/repro7_jordan_new")
files=list.files()
newdf=data.frame(id=NULL,biomarker=NULL)
for(i in files){
  frangi=readnii(paste0(i,"/frangi.nii.gz"))
  lesions=readnii(paste0(i,"/mimosa_mask_30.nii.gz"))
  out=centralveins_presegmented(lesions,frangi,TRUE,as.numeric(Sys.getenv("NSLOTS")))
  writenii(out$cvs.probmap,paste0("/cbica/projects/UVMdata/dropbox/repro7_jordan_new_iter_n/",i,".unclean.cvs.probmap.nii.gz"))
  newdf=rbind(newdf,data.frame(id=i,biomarker=out$cvs.biomarker))
  print(c(i,out$cvs.biomarker))
  write.csv(newdf,"/cbica/projects/UVMdata/dropbox/repro7_jordan_new_iter_n/unclean_results.csv")
}
