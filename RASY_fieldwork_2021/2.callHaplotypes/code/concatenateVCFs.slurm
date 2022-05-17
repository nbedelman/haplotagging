#!/bin/bash


#SBATCH -J concatVCF
#SBATCH -p day
#SBATCH --mem=5G
#SBATCH -t 1-00:00
#SBATCH -c 24
#SBATCH -e errs/concatVCF-%j.err
#SBATCH -o outs/concatVCF-%j.out

vcfList=$1
outFile=$2

bcftools concat --threads 24 -f $vcfList | bcftools sort -Oz > $outFile

tabix -p vcf -C $outFile
