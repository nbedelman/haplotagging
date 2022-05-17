#!/bin/bash

#SBATCH -J makePCA
#SBATCH -p day
#SBATCH --mem=50G
#SBATCH -t 0-02:00
#SBATCH -e errs/makePCA-%j.err
#SBATCH -o outs/makePCA-%j.out



vcfFile=$1

filteredVCF=$(basename $vcfFile .vcf.gz).filtered.vcf.gz

MAF=0.05
MISS=0.9
#
# vcftools --gzvcf $vcfFile \
# --remove-indels --maf $MAF --max-missing $MISS \
#  --recode --stdout | gzip -c > \
# $filteredVCF


plink2 --vcf $vcfFile --double-id --allow-extra-chr \
--freq --out $(basename $vcfFile .filtered.vcf.gz) --set-missing-var-ids @:#

plink2 --vcf $vcfFile --double-id --allow-extra-chr \
--read-freq $(basename $vcfFile .filtered.vcf.gz).afreq \
--pca --out $(basename $vcfFile .filtered.vcf.gz) --set-missing-var-ids @:#
# --indep-pairwise 50 10 0.1
