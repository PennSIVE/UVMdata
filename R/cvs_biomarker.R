library(ROCR)

### original subjects
setwd("~/dropbox/jordan/")
# unweighted
results <- list.files(".", pattern = "^centralveins$", recursive = TRUE)
subj = c()
i = 1
for (res in results) { subj[[i]] = readRDS(res); i = i + 1; }
cvs = numeric()
labels = c()
for (i in 1:length(results)) {
	cvs[i] = subj[[i]]$cvs.biomarker
	sid <- substr(results[[i]], start = 1, stop = 3)
	labels[i] = ifelse(sid %in% c("s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s16", "x01", "x02", "x03", "x04", "x05", "x06", "x07", "x08", "x10", "x13"), 1, 0)
}
pred = prediction(cvs,labels==0)
x<-performance(pred,measure = "auc")
message(paste("CVS AUC for original subjects", x@y.values[[1]]))
write.table(data.frame("subjects" = results, "cvs" = cvs), file = "csv_biomarker.csv", quote = FALSE, sep = ",")
# weighted
results <- list.files(".", pattern = "^centralveins_weighted$", recursive = TRUE)
subj = c()
i = 1
for (res in results) { subj[[i]] = readRDS(res); i = i + 1; }
cvs = numeric()
cvs_weighted = numeric()
labels = c()
for (i in 1:length(results)) {
	cvs[i] = subj[[i]]$cvs.biomarker
	cvs_weighted[i] = subj[[i]]$cvs.biomarker.weighted
	sid <- substr(results[[i]], start = 1, stop = 3)
	labels[i] = ifelse(sid %in% c("s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s16", "x01", "x02", "x03", "x04", "x05", "x06", "x07", "x08", "x10", "x13"), 1, 0)
}
pred = prediction(cvs,labels==0)
x<-performance(pred,measure = "auc")
message(paste("CVS (un)weighted AUC for original subjects", x@y.values[[1]]))
pred = prediction(cvs_weighted,labels==0)
x<-performance(pred,measure = "auc")
message(paste("CVS weighted AUC for original subjects", x@y.values[[1]]))
write.table(data.frame("subjects" = results, "cvs_weighted_unweighted" = cvs, "cvs_weigted" = cvs_weighted), file = "csv_biomarker_weighted.csv", quote = FALSE, sep = ",")


### new subjects
setwd("~/dropbox/jordan_new")
# unweighted
results <- list.files(".", pattern = "^centralveins$", recursive = TRUE)
subj = c()
i = 1
for (res in results) { subj[[i]] = readRDS(res); i = i + 1; }
cvs = numeric()
for (i in 1:length(results)) {
	cvs[i] = subj[[i]]$cvs.biomarker
}
labels = c(0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,0)
pred = prediction(cvs,labels==0)
x<-performance(pred,measure = "auc")
message(paste("CVS AUC for new subjects", x@y.values[[1]]))
write.table(data.frame("subjects" = results, "cvs" = cvs), file = "csv_biomarker.csv", quote = FALSE, sep = ",")
# weighted
results <- list.files(".", pattern = "^centralveins_weighted$", recursive = TRUE)
subj = c()
i = 1
for (res in results) { subj[[i]] = readRDS(res); i = i + 1; }
cvs = numeric()
cvs_weighted = numeric()
for (i in 1:length(results)) {
	cvs[i] = subj[[i]]$cvs.biomarker.weighted
	cvs_weighted[i] = subj[[i]]$cvs.biomarker.weighted
}
pred = prediction(cvs,labels==0)
x<-performance(pred,measure = "auc")
message(paste("CVS (un)weighted AUC for new subjects", x@y.values[[1]]))
pred = prediction(cvs_weighted,labels==0)
x<-performance(pred,measure = "auc")
message(paste("CVS weighted AUC for new subjects", x@y.values[[1]]))
write.table(data.frame("subjects" = results, "cvs_weighted_unweighted" = cvs, "cvs_weigted" = cvs_weighted), file = "csv_biomarker_weighted.csv", quote = FALSE, sep = ",")

