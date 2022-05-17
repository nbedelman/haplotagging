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
#didn't really show anything by doing 20 random pairs, will try to make combined BAM files of all the males and compare to all the females

bamDir=~/scratch60/haplotagging/1.mapReads/EMA_HiC_fieldwork/alignments/
sampleFile=$PWD/data/individuals.txt
maleFiles=$PWD/maleBams.txt
maleBam=$PWD/allMales.bam
femaleFiles=$PWD/femaleBams.txt
femaleBam=$PWD/allFemales.bam
summaryFile=$PWD/male.female.difCover.DNAcopyout

###RUN CODE###
maleIDs=$(awk '$2=="M" {print $1}' $sampleFile)
for i in $maleIDs
do
ls $bamDir/${i}*.cutadapt.bam >> $maleFiles
done
maleMerge=`sbatch code/mergeBams.slurm $maleBam $maleFiles|cut -d " " -f 4`


femaleIDs=$(awk '$2=="F" {print $1}' $sampleFile)
for i in $femaleIDs
do
ls $bamDir/${i}*.cutadapt.bam >> $femaleFiles
done
femaleMerge=`sbatch code/mergeBams.slurm $femaleBam $femaleFiles|cut -d " " -f 4`


mkdir male_female_combined
cp -r code male_female_combined
cd male_female_combined
mkdir errs
mkdir outs
sbatch --dependency=afterok:$femaleMerge:$maleMerge code/run_difcover.sh ${femaleBam/.bam/.sorted.bam} ${maleBam/.bam/.sorted.bam} $summaryFile
