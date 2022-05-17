#!/bin/bash

#SBATCH -J makeGeno
#SBATCH -p day
#SBATCH -t 0-05:00
#SBATCH --mem=1000
#SBATCH -c 20
#SBATCH -o outs/makeGeno.%j.out
#SBATCH -e errs/makeGeno.%j.err

genomeDir=$1
vcfFile=$2
genoFile=$3

python $genomeDir/VCF_processing/parseVCF.py -i $vcfFile -o $genoFile
