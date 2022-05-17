#!/usr/bin/env Rscript

library(dplyr)
library(STITCH)

#output simple summary statistics for imputation

args = commandArgs(trailingOnly=TRUE)
outDir=args[1]
regionName=args[2]


file = file.path(
   outDir, "RData", paste0("EM.all.", regionName, ".RData")
)

load(file)

goodSamples <- which(info>0.4, hwe > 1e-6 )

m1 <- data.frame(orig=alleleCount[, 3], estim=estimatedAlleleFrequency)
m1 <- m1[goodSamples,] %>%
  dplyr::filter(estim <= 0.99, estim >= 0.01)

corr <- suppressWarnings(
  round(cor(m1$orig, m1$estim, use="complete.obs") ** 2, 3))


jointFrame <- data.frame(info=info, freq=estimatedAlleleFrequency) %>% dplyr::filter(freq <= 0.99, freq >= 0.01)

meanScore=mean(jointFrame$info)
medianScore=median(jointFrame$info)

write(round(c(dim(m1)[1], corr, meanScore, medianScore),3), stdout())
