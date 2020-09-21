# Central Vein Detection algorithm - Simple / pre-segmented lesions with noise weighting
# Code written by Jordan Dworkin (jordandworkin@gmail.com)

#Variable descriptions:
# **lesionmap** is a nifti mask in which voxels have been manually classified as either
# lesion voxels or not lesion voxels.
#---
# **veinmap** is an image of class nifti, containing the vesselness score for each voxel.
#---
# **epi** is an image of class nifti, containing the T2*-EPI volume in the same space as 
# 'lesionmap' and 'veinmap'.
#---
# **parallel** is a logical value that indicates whether the user's computer
# is Linux or Unix (i.e. macOS), and should run the code in parallel.
#---
# **cores** (if parallel = TRUE) is an integer value that indicates how many cores
# the function should be run on.
#---

# Function output:
# A list containing candidate.lesions (a nifti file with labeled lesions evaluated for CVS),
# cvs.probmap (a nifti file in which candidate lesions are labeled with their CVS probability), and
# cvs.biomarker (a numeric value representing the average CVS probability of a subject's lesions).
# cvs.biomarker.weighted (a numeric value representing the average CVS probability of a subject's lesions, weighted by lesion-level noise).

# Required packages:
library(neurobase) # for reading and writing nifti files
library(ANTsRCore) # for cluster labeling
library(extrantsr) # for transitioning between ants and nifti
library(parallel) # for working in parallel
library(pbmcapply) # for working in parallel

source("helperfunctions.R") # load necessary helper functions

getAnisoSmooth=function(im,smooth=.75){
  tempim=tempfile(pattern="file", tmpdir=tempdir(), fileext=".nii.gz")
  writenii(im,tempim)
  tempsm=tempfile(pattern="file", tmpdir=tempdir(), fileext=".nii.gz")
  system(paste0("c3d ",tempim," -ad ",smooth," 100 "," -o ",tempsm))
  
  smoothim=readnii(tempsm)
  return(smoothim)
}

# Simple CVS detection function:
centralveins_weighted_presegmented=function(lesionmap,veinmap,epi,parallel=F,cores=2){

  ###############################################################
  ####### Get distance to boundary for individual lesions #######
  ###############################################################
  dtb=dtboundary(lesionmap)
  
  ##################################################################
  ####### Get smoothed EPI map and perform noise calculation #######
  ##################################################################
  epi_sm=getAnisoSmooth(epi)
  epi_diff=(epi-epi_sm)
  
  ######################################################################
  ####### Perform permutation procedure to get CVS probabilities #######
  ######################################################################
  lables=ants2oro(labelClusters(oro2ants(lesionmap),minClusterSize=27))
  probles=lables
  avprob=NULL
  weights=NULL
  maxles=max(as.vector(lables))
  for(j in 1:maxles){
    # get true coherence for lesion j
    frangsub=veinmap[lables==j]
    if(max(frangsub>=.1)){
      centsub=dtb[lables==j]
      coords=which(lables==j,arr.ind=T)
      prod=frangsub*centsub
      score=sum(prod)
      # get 1000 null coherence values for lesion j
      if(parallel==T){
        nullscores=as.vector(unlist(mclapply(1:1000,getnulldist,
                                             centsub,coords,frangsub,
                                             mc.cores=cores)))
      }else{
        nullscores=as.vector(unlist(lapply(1:1000,getnulldist,
                                           centsub,coords,frangsub)))
      }
      
      # get CVS probability for lesion j
      lesprob=sum(nullscores<score)/length(nullscores)
    }else{
      lesprob=0
    }
    
    avprob=c(avprob,lesprob)
    probles[lables==j]<-lesprob
    
    ## Quantify lesion-level noise as the sum of squared diff b/w
    ## raw image and smoothed image (normalized by lesion size)
    twei=sum(epi_diff[lables==j]^2)/length(epi_diff[lables==j])
    weights=c(weights,twei)
    
    print(paste0("Done with lesion ",j," of ",maxles))
  }
  
  ## Invert noise vector to downweight internally variable lesions 
  weights=min(weights)/weights
  return(list(candidate.lesions=lables>0,cvs.probmap=probles,
              cvs.biomarker=mean(avprob),numles=maxles,
              cvs.biomarker.weighted=sum(avprob*weights)/sum(weights)))
}

