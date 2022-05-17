#!/bin/bash

#SBATCH -J sortBams
#SBATCH -p day
#SBATCH -N 1
#SBATCH --mem=100000
#SBATCH -c 12
#SBATCH -t 0-05:00
#SBATCH -e errs/sortBams-%j.err
#SBATCH -o outs/sortBams-%j.out

bamFile=$1

outList=$(basename $bamFile .txt).sorted.txt

while read bam
do echo $bam
if [ ! -f ${bam/.bam/.sorted.bam} ]; then
samtools sort -o ${bam/.bam/.sorted.bam} --threads 12 $bam
samtools index -c ${bam/.bam/.sorted.bam}
echo ${bam/.bam/.sorted.bam} >> $outList
fi;
done < $bamFile
