#!/bin/bash

#SBATCH -J mergeBams   # job name
#SBATCH -p day
#SBATCH -t 0-10:00  # walltime
#SBATCH -c 36   # number of processor cores (i.e. tasks)
#SBATCH -N 1
#SBATCH --mem=100G   # memory per CPU core
#SBATCH -e errs/mergeBams.%j.err
#SBATCH -o outs/mergeBams.%j.out

outBam=$1
fofn=$2


#samtools merge -f -@ 36 -b $fofn $outBam
#samtools sort -@ 36 $outBam > ${outBam/.bam/.sorted.bam}
samtools index -c -@ 36 ${outBam/.bam/.sorted.bam}
