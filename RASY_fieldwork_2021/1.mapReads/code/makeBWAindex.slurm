#!/bin/bash

#SBATCH -J BWAIndex
#SBATCH -p day
#SBATCH --mem=75000
#SBATCH -t 0-05:00
#SBATCH -e errs/BWAIndex-%j.err
#SBATCH -o outs/BWAIndex-%j.out

refGenome=$1

bwa index -b 500000000 $refGenome
