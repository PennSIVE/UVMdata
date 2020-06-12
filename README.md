### Various scripts used to process UVMdata
---
Steps to reproduce:
1. Convert dicoms to niftis using `qsub -cwd ./shell/heudiconv.sh`
2. Process images with `qsub -cwd ./bash/hcppipelines.sh`
3. Copy output to analysis directory, z-score myelin maps, regenerate CIFTIs with `qsub -cwd ./run.sh`