library(neurobase)
library(ANTsR)
library(extrantsr)
library(WhiteStripe)

args = commandArgs(TRUE)

t1 = readnii(args[1])
t1_brainmask = readnii(args[2])
t1_brain = t1 * t1_brainmask
flair = readnii(args[3])
outdir = args[4]
fn = sub('_FLAIR\\.nii\\.gz$', '', basename(args[3]))

writenii(t1_brain, file.path(outdir, paste0(fn, "_T1wBrain")))
ind = whitestripe(t1_brain, "T1")
img_ws = whitestripe_norm(t1_brain, ind$whitestripe.ind)
writenii(img_ws, file.path(outdir, paste0(fn, "_T1wBrainWS.nii.gz")))

flair_reg2t1 = registration(filename = flair, template.file = t1,
              typeofTransform = "Rigid", interpolator = "Linear")
save(flair_reg2t1,file = file.path(outdir, paste0(fn, "reg.RData")))

flair_reg = antsApplyTransforms(fixed = oro2ants(t1), moving = oro2ants(flair),
            transformlist = flair_reg2t1$fwdtransforms, interpolator = "welchWindowedSinc")
antsImageWrite(flair_reg, file.path(outdir, paste0(fn, "_FLAIRreg.nii.gz"))) # write out registered t1 image

# apply brain mask to registered flair
flair_reg_brain = flair_reg * t1_brainmask
antsImageWrite(flair_reg_brain, file.path(outdir, paste0(fn, "_FLAIRregBrain.nii.gz")))

flair_reg_brain.oro = ants2oro(flair_reg_brain)
ind = whitestripe(flair_reg_brain.oro, "T2")
img_ws = whitestripe_norm(flair_reg_brain.oro, ind$whitestripe.ind)
writenii(img_ws, file.path(outdir, paste0(fn, "_FLAIRregBrainWS.nii.gz")))
