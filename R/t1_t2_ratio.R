# to run:
# qsub -b y -o zscore.log -e zscore.err -cwd singularity exec -B /cbica/projects/UVMdata/bids/output/2020-06-07:/input -B ~/tmp.R:/tmp.R /cbica/home/robertft/singularity_images/neuror_4.0.sif Rscript /tmp.R
library(gifti)
library(ROCR)


setwd('/input')
files <- c()
r.maps <- list.files(pattern = "*.R.MyelinMap_BC.164k_fs_LR.func.gii", recursive = TRUE)
r.mat <- matrix(NA, 163842, length(r.maps))
for (j in 1:length(r.maps)) {
  r.mat[, j] <- readgii(r.maps[j])$data[[1]]
  files[[j]] <- r.maps[j]
  print(j)
}
r.norm.mat <- matrix(NA, 163842, length(r.maps))
for (j in 1:length(r.maps)) {
  r.norm.mat[, j] <- (r.mat[, j] - apply(r.mat[, - j], 1, mean)) / apply(r.mat[, - j], 1, sd)
  print(j)
}
l.maps <- list.files(pattern = "*.L.MyelinMap_BC.164k_fs_LR.func.gii", recursive = TRUE)
l.mat <- matrix(NA, 163842, length(r.maps))
for (j in 1:length(l.maps)) {
  l.mat[, j] <- readgii(l.maps[j])$data[[1]]
  print(j)
}
l.norm.mat <- matrix(NA, 163842, length(l.maps))
for (j in 1:length(l.maps)) {
  l.norm.mat[, j] <- (l.mat[, j] - apply(l.mat[, - j], 1, mean)) / apply(l.mat[, - j], 1, sd)
  print(j)
}

pothole.mat<-matrix(1*(r.norm.mat<(-3)),nrow=dim(r.norm.mat)[1],ncol=dim(r.norm.mat)[2]) + matrix(1*(l.norm.mat<(-3)),nrow=dim(l.norm.mat)[1],ncol=dim(l.norm.mat)[2])
marker<-apply(pothole.mat,2,sum,na.rm=TRUE)

subject_labels <- unlist(lapply(files, function(x) {substr(x, start = 1, stop = 7)}), use.names=FALSE)

data.table::fwrite(data.frame("subject" = subject_labels, "ratio" = marker), file = "t1_t2_ratio.csv", sep = ",", quote = FALSE)
