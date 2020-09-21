library(ROCR)


merged <- read.csv("~/big_spreadsheet.csv")

pred = prediction(merged$lesion_volumes,merged$"group..A...MS.B..non.MS"=="A")
x<-performance(pred,measure = "auc")
x@y.values[[1]]

pred = prediction(merged$thalamic_volumes,merged$"group..A...MS.B..non.MS"=="A")
x<-performance(pred,measure = "auc")
x@y.values[[1]]

pred = prediction(merged$count,merged$"group..A...MS.B..non.MS"=="A")
x<-performance(pred,measure = "auc")
x@y.values[[1]]

pred = prediction(merged$sizes,merged$"group..A...MS.B..non.MS"=="A")
x<-performance(pred,measure = "auc")
x@y.values[[1]]

pred = prediction(merged$cvs,merged$"group..A...MS.B..non.MS"=="A")
x<-performance(pred,measure = "auc")
x@y.values[[1]]
pred = prediction(merged$cvs_weighted,merged$"group..A...MS.B..non.MS"=="A")
x<-performance(pred,measure = "auc")
x@y.values[[1]]
pred = prediction(merged$cvs_weighted_unweighted,merged$"group..A...MS.B..non.MS"=="A")
x<-performance(pred,measure = "auc")
x@y.values[[1]]
