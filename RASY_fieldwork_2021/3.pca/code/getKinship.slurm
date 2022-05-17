#!/bin/bash

#SBATCH -J kinship
#SBATCH -p day
#SBATCH --mem=10G
#SBATCH -c 24
#SBATCH -t 0-05:00
#SBATCH -e errs/kinship-%j.err
#SBATCH -o outs/kinship-%j.out

module load PLINK/2.00-alpha2.3
module load SAMtools
module load VCFtools

vcfFile=$1

plink2 --vcf $vcfFile --double-id --allow-extra-chr \
--set-missing-var-ids @:# \
--make-king-table --out $(basename $vcfFile .vcf.gz)
