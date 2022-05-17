#!/bin/bash

#SBATCH -J writeGTF
#SBATCH -p day,week,bigmem
#SBATCH --mem=50G
#SBATCH -t 1-00:00
#SBATCH -e errs/writeGTF-%j.err
#SBATCH -o outs/writeGTF-%j.out

inVCF=$1
outGTF=$2

whatshap stats --gtf=$outGTF $inVCF
