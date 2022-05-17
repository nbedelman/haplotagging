#!/bin/bash

#SBATCH -J PCA
#SBATCH -p day
#SBATCH --mem=100G
#SBATCH -c 24
#SBATCH -t 0-10:00
#SBATCH -e errs/PCA-%j.err
#SBATCH -o outs/PCA-%j.out

module load PLINK/2.00-alpha2.3
module load SAMtools
module load VCFtools

vcfFile=/home/nbe4/palmer_scratch/haplotagging/2.callHaplotypes/EMA_HiC_fieldwork/STITCH_K38_04/stitch.HiC_scaffold_9.filtered.vcf.gz

#first, let's get a sense of the VCF and maybe do some filtering. this VCF is the output of the bwa-mpileup=stitch-hapcut pipeline

bcftools index -c $vcfFile


SUBSET_VCF=$vcfFile
OUT=$(basename $vcfFile .vcf.gz)


VCF_IN=$vcfFile
VCF_OUT=$(basename $vcfFile .vcf.gz).filtered.vcf.gz

MAF=0.05
MISS=0.9

vcftools --gzvcf $VCF_IN \
--remove-indels --maf $MAF --max-missing $MISS \
 --recode --stdout | gzip -c > \
$VCF_OUT

plink2 --vcf $VCF_OUT --double-id --allow-extra-chr \
--set-missing-var-ids @:# \
--freq --out $(basename $VCF_OUT .vcf.gz)

plink2 --vcf $VCF_OUT --double-id --allow-extra-chr \
--set-missing-var-ids @:# \
--pca biallelic-var-wts --read-freq $(basename $VCF_OUT .vcf.gz).afreq --out $(basename $VCF_OUT .vcf.gz)

#--indep-pairwise 50 10 0.1 \
