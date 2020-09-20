setwd("~/dropbox/jordan/")
results <- list.files(".", pattern = "^centralveins$", recursive = TRUE)
subj = c()
i = 1
for (res in results) { subj[[i]] = readRDS(res); i = i + 1; }
cvs = numeric()
labels = c()
for (i in 1:length(results)) {
	cvs[i] = subj[[i]]$cvs.biomarker
	sid <- substr(results[[i]], start = 1, stop = 3)
	message(sid)
	labels[i] = ifelse(sid %in% c("s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s16", "x01", "x02", "x03", "x04", "x05", "x06", "x07", "x08", "x10", "x13"), 1, 0)
}
library(ROCR)
pred = prediction(cvs,labels==0)

x<-performance(pred,measure = "auc")
x@y.values[[1]]

write.table(data.frame("subjects" = results, "cvs" = cvs), file = "csv_biomarker.csv", quote = FALSE, sep = ",")


setwd("~/dropbox/jordan_new")
results <- list.files(".", pattern = "^centralveins$", recursive = TRUE)
subj = c()
i = 1
for (res in results) { subj[[i]] = readRDS(res); i = i + 1; }
cvs = numeric()
for (i in 1:length(results)) {
	cvs[i] = subj[[i]]$cvs.biomarker
}
labels = c(0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,0)
library(ROCR)
pred = prediction(cvs,labels==0)

x<-performance(pred,measure = "auc")
x@y.values[[1]]

write.table(data.frame("subjects" = results, "cvs" = cvs), file = "csv_biomarker.csv", quote = FALSE, sep = ",")




