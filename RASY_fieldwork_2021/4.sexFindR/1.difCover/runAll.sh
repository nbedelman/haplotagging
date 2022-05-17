#!/bin/bash

#run Phil Grayson's sex chromosome finder pipeline
#https://github.com/phil-grayson/SexFindR

###SETUP ENVIRONMENT###
module load miniconda
conda activate haplotagging
module load SAMtools/1.7-foss-2018a

mkdir -p errs
mkdir -p outs

###DEFINE VARIABLES###
#supposed to use a single male individual and single female...
#not sure it will really work with such low coverage, but will try
#should do some M-M and F-F comparisons as controls...maybe pick 50 or 100 random pairs?

bamDir=/home/nbe4/scratch60/haplotagging/1.mapReads/EMA_HiC/alignments/
bamList=bamFiles.txt
pairList=bamPairs.txt
numPairs=19
baseDir=$PWD
summaryFile=$baseDir/allPairs.difCover.DNAcopyout

###RUN CODE###
#first, make list of random pairs of samples
ls $bamDir/*.cutadapt.bam > $bamList
python code/makeRandomPairs.py $bamList $numPairs $pairList

#then, run difCover for each pair. Do this in separate directories.
while read line
do
fileOne=$(echo $line| cut -d " " -f 1)
baseOne=$(echo $(basename $fileOne) | cut -d "_" -f 1)
fileTwo=$(echo $line| cut -d " " -f 2)
baseTwo=$(echo $(basename $fileTwo) | cut -d "_" -f 1)

mkdir $baseOne\_$baseTwo
cp -r code $baseOne\_$baseTwo
cd $baseOne\_$baseTwo
mkdir errs
mkdir outs
sbatch code/run_difcover.sh $fileOne $fileTwo $summaryFile
cd ..
done < $pairList
