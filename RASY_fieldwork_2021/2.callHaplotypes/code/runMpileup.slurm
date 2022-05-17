#!/bin/bash

#SBATCH -p day,week
#SBATCH -N 1
#SBATCH -c 48
#SBATCH --mem=10000
#SBATCH -t 1-00:00
#SBATCH -e errs/runMpileup-%j.err
#SBATCH -o outs/runMpileup-%j.out


refGenome=$1
base=$2
bamList=$3
chromFile=$4


bcftools mpileup --threads=48 -Ou -a INFO/AD,AD,DP,DV,DPR,INFO/DPR,DP4,SP -q 10 -Q 20 -f $refGenome --ignore-RG -F 1024 -b $bamList -R $chromFile | bcftools call --threads=48 -f GQ,GP -O v -v -m -o $base.vcf

#parse output into pos and gen files
vcftools --vcf $base.vcf --min-alleles 2 --max-alleles 2 --recode --out $base

grep -v "#" $base.recode.vcf |awk '{OFS="\t"}{print $1,$2,$4,$5}' > $base.pos

python code/getGen.py $base.recode.vcf $base.gen
