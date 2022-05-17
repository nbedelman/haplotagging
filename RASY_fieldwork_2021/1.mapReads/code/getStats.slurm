#!/bin/bash


#SBATCH -J getStats
#SBATCH -p day
#SBATCH --mem=10000
#SBATCH -t 0-10:00
#SBATCH -e errs/getStats-%j.err
#SBATCH -o outs/getStats-%j.out

bam=$1
moleculeFile=${bam/.bam/.linked_reads.full.bed}

mkdir -p stats
mkdir -p statPlots
mkdir -p molecules

samtools stats $bam > stats/$(basename $bam).stats
plot-bamstats -p statPlots/$(basename $bam) stats/$(basename $bam).stats
samtools flagstat $bam > stats/$(basename $bam).flagstat
code/bed_write.pl $bam
python3 code/getMoleculeStats.py $moleculeFile stats/$(basename $bam).molecule.stats
