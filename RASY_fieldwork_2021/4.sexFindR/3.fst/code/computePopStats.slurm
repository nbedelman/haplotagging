#!/bin/bash

#SBATCH -J computePopStats
#SBATCH -p day
#SBATCH -t 0-05:00
#SBATCH --mem=10G
#SBATCH -c 20
#SBATCH -o outs/computePopStats.%j.out
#SBATCH -e errs/computePopStats.%j.err

genomeDir=$1
genofile=$2
popfile=$3
popgenStats=$4


included=$(head -1 $genofile | sed 's:\t:,:g')
popString=$(code/makePopList.py $popfile "$included")

#code/makePseudoChrom.py $genofile $pseudoChromFile

echo $popString


python $genomeDir/popgenWindows.py -g $genofile $popString -o $popgenStats -f phased -w 1000000 -T 20
