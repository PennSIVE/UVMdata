datasets <- c("/cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all_combined", "/cbica/projects/UVMdata/bids/datasets/Migraine", "/cbica/projects/UVMdata/bids/datasets/MS", "/cbica/projects/UVMdata/bids/datasets/MSc", "/cbica/projects/UVMdata/bids/datasets/Misdiag")
for (dataset in datasets) {
    setwd(dataset)
    volumes = numeric()
    files = c()
    i = 1
    message(dataset)
    for (file in list.files(".", pattern = "jlf_thalamus.nii.gz", recursive = TRUE)) {
        volumes[[i]] = sum(neurobase::readnii(file))
        files[i] = file
        i = i + 1
    }
    write.table(data.frame("subject" = files, "volumes" = volumes), file = "thalamic_volumes.csv", sep = ",", quote = FALSE)

}