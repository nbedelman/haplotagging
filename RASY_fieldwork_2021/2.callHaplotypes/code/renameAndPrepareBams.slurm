#!/bin/bash

#SBATCH -J prepareBams
#SBATCH -p day,week,bigmem
#SBATCH --mem=10G
#SBATCH -c 12
#SBATCH -t 1-00:00
#SBATCH -e errs/prepareBams-%j.err
#SBATCH -o outs/prepareBams-%j.out

bamList=$1

while read line; do base=$(basename $line); sample=$(echo $base|cut -d "_" -f 1,2); echo $sample; samtools view -H $line | sed "s/SM:[^\t]*/SM:$sample/g"| samtools reheader - $line | samtools sort -@ 12 - > data/correctSampleBams/$base ;  samtools index -@ 12 -c data/correctSampleBams/$base ;done < $bamList
