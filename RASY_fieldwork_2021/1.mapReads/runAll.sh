#!/bin/bash

#map haplotagging reads to reference genome


### SETUP ENVIRONMENT ###
mkdir -p errs
mkdir -p outs
mkdir -p data
mkdir -p alignments
mkdir -p data/rawReads


module load miniconda
conda activate EMA
module load BWA/0.7.17-foss-2018a
module load SAMtools/1.7-foss-2018a
module load Perl/5.32.0-GCCcore-10.2.0

ln -s /home/nbe4/project/RASY_assembly/VGP/data/aRanSyl1_s2_polished2.wrap.FINAL.fasta data/

### DEFINE VARIABLES ###
rawReadsDir=$PWD/data/rawReads
refGenome=$PWD/data/aRanSyl1_s2_polished2.wrap.FINAL.fasta
fileList=$PWD/data/readOneNames.txt

### RUN CODE ###
#make samtools index
#make sure to make BWA index first
# samtools faidx $refGenome
# index=`sbatch code/makeBWAindex.slurm $refGenome|cut -d " " -f 4`
ls $rawReadsDir/*R1*cutadapt.fastq.gz > $fileList
numFiles=$(wc -l $fileList|cut -f 1 -d " ")

sbatch --array=1-$numFiles code/ema_prep_array.sh $fileList alignments $refGenome
#sbatch --dependency=afterok:$index code/ema_prep.sh $readOne alignments $refGenome | cut -d " " -f 4`
  #sbatch --dependency=afterok:$map code/getStats.slurm alignments/$(basename $readOne .fastq.gz).sorted.bam
  #sbatch code/getStats.slurm alignments/$(basename $readOne .fastq.gz).sorted.bam
