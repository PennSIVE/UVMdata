
setwd("~/dropbox/jordan_new")
results <- sort(list.files(".", pattern = "centralveins", recursive = TRUE))
subj = c()
i = 1
for (res in results) { subj[[i]] = readRDS(res); i = i + 1; }
lesion_count = numeric()
for (i in 1:length(results)) {
	lesion_count[i] = subj[[i]]$numles
}
mask_files <- sort(
setdiff(
list.files(".", pattern = "mimosa_mask_30.nii.gz", recursive = TRUE),
c("sub-027/mimosa_mask_30.nii.gz", "sub-076/mimosa_mask_30.nii.gz"))
)

volumes = numeric()
for (i in 1:length(mask_files)) {
	volumes[i] = sum(neurobase::readnii(mask_files[[i]]))
}
sizes = numeric()
for (i in 1:length(volumes)) {
	sizes[i] = volumes[i] / lesion_count[i]
}
write.table(data.frame("subject" = mask_files, "count" = lesion_count, "volumes" = volumes, "sizes" = sizes), file = "lesion_info.csv", quote = FALSE, sep = ",")


