#!/bin/bash

#trying to develop haplotagging pipeline from meier el al data

#### SETUP ENVIRONMENT ###
module load miniconda
conda activate haplotagging
module load SAMtools/1.7-foss-2018a
module load HTSlib/1.9-foss-2018b
module load VCFtools/0.1.16-foss-2018b-Perl-5.28.0


mkdir -p errs
mkdir -p outs
mkdir -p data
mkdir -p data/correctSampleBams
mkdir -p STITCH_optimize



### DEFINE VARIABLES ###
homeDir=~/scratch60/haplotagging/2.callHaplotypes/EMA_HiC_fieldwork
refGenome=$homeDir/data/aRanSyl1_s2_polished2.wrap.FINAL.chroms.fasta
correctBamList=samples.correctNames.bam.txt
summaryFile=stitchOptimize.summary.txt

### RUN CODE ###

#list=$(seq -w 01 13)
list=08 #

for split  in $list
  do
  refPiece=${refGenome/fasta/$split.fasta}

  base=$(basename $refGenome .fa)\_$split

  #run STITCH optimization
  for K in $(echo 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50)
  #for K in 10
  do
  stitch=`sbatch code/runStitch.optimize.slurm $correctBamList $homeDir/MPILEUP_$split/$base.pos $summaryFile $K|cut -d " " -f 4`
done
done
