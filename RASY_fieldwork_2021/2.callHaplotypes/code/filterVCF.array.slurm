#!/bin/bash

#SBATCH -J filterVCF
#SBATCH -p day,week,bigmem
#SBATCH --mem=100M
#SBATCH -c 12
#SBATCH -t 0-01:00
#SBATCH -e errs/filterVCF-%j.err
#SBATCH -o outs/filterVCF-%j.out

split=$1
K=$2
chrom=$3

start=$(awk -v i=${SLURM_ARRAY_TASK_ID} 'BEGIN {print i * 10000000}' )

end=$(awk -v start=$start 'BEGIN {print start + 10000000}')

outDir=STITCH_K$K\_${split}

tabix -p vcf -C $outDir/stitch.$chrom.$start.$end.vcf.gz

bcftools filter --threads 24 -e 'INFO/INFO_SCORE<=0.4'  $outDir/stitch.$chrom.$start.$end.vcf.gz  | bcftools view --threads 24 -m2 -M2 -q 0.01:minor -Oz -o $outDir/stitch.$chrom.$start.$end.filter.vcf.gz

tabix -p vcf -C $outDir/stitch.$chrom.$start.$end.filter.vcf.gz
