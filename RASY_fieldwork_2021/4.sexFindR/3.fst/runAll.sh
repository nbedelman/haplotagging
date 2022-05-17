#!/bin/bash

mkdir -p data
mkdir -p errs
mkdir -p outs
mkdir -p geno
mkdir -p results

#ln -s /home/nbe4/palmer_scratch/haplotagging/2.callHaplotypes/EMA_HiC_fieldwork/STITCH_K38_04/stitch.HiC_scaffold_9.filtered.vcf.gz data/

module load miniconda

conda activate ipyrad
###DEFINE VARIABLES###
genomeDir=/home/nbe4/project/software/genomics_general/
popfile=data/individuals.txt
vcfFile=data/stitch.HiC_scaffold_9.filtered.vcf.gz
genofile=geno/stitch.HiC_scaffold_9.filtered.subset.geno
popgenStats=results/stitch.HiC_scaffold_9.filtered.subset.1M.stats

###RUN CODE###
#first, convert vcf to geno
#makeGeno=`sbatch code/makeGeno.slurm $genomeDir $vcfFile $genofile|cut -d " " -f 4`

#then, get popgen stats
# sbatch --dependency=afterok:$makeGeno code/computePopStats.slurm $genomeDir $genofile $popfile $popgenStats
sbatch code/computePopStats.slurm $genomeDir $genofile $popfile $popgenStats
