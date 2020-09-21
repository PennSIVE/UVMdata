

key <- read.csv("~/key_xlsx.csv")
stopifnot(length(key$"group..A...MS.B..non.MS") == 49)
key$study.ID <- lapply(key$study.ID, function(x) {substr(x, 6, 8)})
names(key)[names(key) == 'study.ID'] <- 'subject'
key$"group..A...MS.B..non.MS" <- lapply(key$"group..A...MS.B..non.MS",function(x) {gsub('\\s+', '',x)})

lesion_info <- read.csv("~/dropbox/jordan_new/lesion_info.csv")
lesion_info$subject <- lapply(lesion_info$subject, function(x) {substr(x, 5, 7)})
names(lesion_info)[names(lesion_info) == 'volumes'] <- 'lesion_volumes'
stopifnot(length(lesion_info$subject) == 47) # we're missing 2 subjects

merged <- dplyr::full_join(lesion_info, key, by = "subject")

cvs <- read.csv("~/dropbox/jordan_new/csv_biomarker.csv")
cvs$subjects <- lapply(cvs$subjects, function(x) {substr(x, 5, 7)})
names(cvs)[names(cvs) == 'subjects'] <- 'subject'
merged <- dplyr::full_join(merged, cvs, by = "subject")
cvs <- read.csv("~/dropbox/jordan_new/csv_biomarker_weighted.csv")
cvs$subjects <- lapply(cvs$subjects, function(x) {substr(x, 5, 7)})
names(cvs)[names(cvs) == 'subjects'] <- 'subject'
merged <- dplyr::full_join(merged, cvs, by = "subject")

thalamus <- read.csv("/cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all_combined/thalamic_volumes.csv")
thalamus$subject <- lapply(thalamus$subject, function(x) {substr(x, 17, 19)})
names(thalamus)[names(thalamus) == 'volumes'] <- 'thalamic_volumes'
merged <- dplyr::full_join(merged, thalamus, by = "subject")
merged <- na.omit(merged)

# write.csv(merged, file = "~/big_spreadsheet.csv", sep = ",")
data.table::fwrite(merged, file ="~/big_spreadsheet.csv")



#
# jordan <- read.csv("clean_results.csv")
# jordan$id <- lapply(jordan$id, function(x) {x})
# tim <- read.csv("~/dropbox/jordan_cvs2/csv_biomarker.csv")
# tim <- read.csv("~/dropbox/jordan_cvs/csv_biomarker.csv")
# tim$subjects <- lapply(tim$subjects, function(x) {substr(x, 1, 3)})
# names(tim)[names(tim) == 'subjects'] <- 'id'
# orig_merged <- dplyr::full_join(tim, jordan, by = "id")

# pred = prediction(orig_merged$biomarker,orig_merged$"ms"=="1")
# x<-performance(pred,measure = "auc")
# x@y.values[[1]]

# pred = prediction(orig_merged$cvs,orig_merged$"ms"=="1")
# x<-performance(pred,measure = "auc")
# x@y.values[[1]]