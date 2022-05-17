#!/bin/bash

#SBATCH -J collectResults
#SBATCH -p day
#SBATCH --mem=5000
#SBATCH -t 0-05:00
#SBATCH -c 12
#SBATCH -e errs/collectResults-%j.err
#SBATCH -o outs/collectResults-%j.out


resultDir=$1
collectDir=$2

results=$(ls $resultDir|grep outdir)

for sample in $results
do
echo $sample
base=$(basename $sample _outdir)
samtools merge --threads 12 $collectDir/$base.bam $resultDir/$sample/*.bam
done
