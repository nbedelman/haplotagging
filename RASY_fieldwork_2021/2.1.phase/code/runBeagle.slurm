#!/bin/bash

#SBATCH -J beagle
#SBATCH -p day,week,bigmem
#SBATCH --mem=100G
#SBATCH -t 1-00:00
#SBATCH -c 24
#SBATCH -e errs/beagle-%j.err
#SBATCH -o outs/beagle-%j.out

beagleJar=$1
inVCF=$2
outBase=$3

java -Xmx90000m -jar $beagleJar gt=$inVCF out=$outBase nthreads=24
