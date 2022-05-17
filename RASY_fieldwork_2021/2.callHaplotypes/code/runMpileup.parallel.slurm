#!/bin/bash

#SBATCH -p day
#SBATCH -N 1
#SBATCH --mem=10000
#SBATCH  -c 24
#SBATCH -t 0-10:00
#SBATCH -e errs/runMpileup-%j.err
#SBATCH -o outs/runMpileup-%j.out

refGenome=$1
base=$2
bamList=$3
genomeIndex=$4

parallel --colsep '\t' -g -t INFO/AD,AD,DP,DV,DPR,INFO/DPR,DP4,SP -F 1024 -b $bamList -q 10 -Q 20 -f $refGenome -R -r {1} --jobs=24 :::: $genomeIndex > $base.vcf

vcftools --vcf $base.vcf --min-alleles 2 --max-alleles 2 --recode --out $base

grep -v "#" $base.recode.vcf |awk '{OFS="\t"}{print $1,$2,$4,$5}' > $base.pos

python code/getGen.py $base.recode.vcf $base.gen
