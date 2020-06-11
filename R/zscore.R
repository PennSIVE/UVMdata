# to run:
# qsub -b y -o zscore.log -e zscore.err -cwd singularity exec -B /cbica/projects/UVMdata/bids/output/2020-06-07:/input:ro -B /cbica/projects/UVMdata/analysis:/output -B $PWD/zscore.R:/zscore.R /cbica/home/robertft/singularity_images/neuror_4.0.1.sif Rscript /zscore.R
library(gifti)
writegii = function(gifti, outfile, encoding, datatype, endian) {
  doc <- xml2::xml_new_document()
  root <- xml2::xml_add_child(doc, "GIFTI")
  darray <- xml2::xml_add_child(root, "DataArray")
  if (class(gifti) == "gifti") {
    len <- length(gifti$data)
    dat <- gifti$data
  } else {
    len <- 1
    dat <- gifti
  }
  # for (i in 1:len) {
    encoded <- data_encoder(
      values = as.vector(dat),
      encoding = encoding,
      datatype = datatype,
      endian = endian
    )
    xml2::xml_set_text(xml2::xml_add_child(darray, "Data"), encoded)
  # }
  xml2::write_xml(doc, outfile)
}
library(ROCR)


setwd('/input')
r.maps <- list.files(pattern = "*.R.MyelinMap_BC.164k_fs_LR.func.gii", recursive = TRUE)
r.mat <- matrix(NA, 163842, length(r.maps))
for (j in 1:length(r.maps)) {
  r.mat[, j] <- readgii(r.maps[j])$data[[1]]
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

setwd('/output')
for (j in 1:length(r.maps)) {
  dir <- dirname(r.maps[j])
  if (dir.exists(dir) == FALSE) {
    dir.create(dir, recursive = TRUE)
  }
  writegii(r.norm.mat[, j], r.maps[j], "GZipBase64Binary", "NIFTI_TYPE_FLOAT32", "little")
  writegii(l.norm.mat[, j], l.maps[j], "GZipBase64Binary", "NIFTI_TYPE_FLOAT32", "little")
}

