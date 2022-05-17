#!/bin/bash

#modified from https://github.com/evolgenomics/HeliconiusHaplotagging/blob/main/PopGen/NGSadmix.sh

#SBATCH -J cleanup
#SBATCH -p day
#SBATCH --mem=10000
#SBATCH -t 0-5:00
#SBATCH -e errs/cleanup-%j.err
#SBATCH -o outs/cleanup-%j.out

for i in $(seq -w 00 30);
do echo $i;
bcftools merge -O z -o HAPCUT_K20_$i/$i.hapcut2.threshold_30.errAn.output.phased.vcf.gz HAPCUT_K20_$i/*.VCF.gz;
tabix -p vcf HAPCUT_K20_$i/$i.hapcut2.threshold_30.errAn.output.phased.vcf.gz
done
