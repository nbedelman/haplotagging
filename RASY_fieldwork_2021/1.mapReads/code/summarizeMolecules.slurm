#!/bin/bash


#SBATCH -J Molecules
#SBATCH -p day
#SBATCH --mem=10G
#SBATCH -c 1
#SBATCH -t 0-05:00
#SBATCH -e errs/Molecules-%j.err
#SBATCH -o outs/Molecules-%j.out

alignment=$1


code/bed_write.pl $alignment 
