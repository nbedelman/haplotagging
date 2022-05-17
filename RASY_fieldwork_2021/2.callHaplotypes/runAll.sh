#!/bin/bash

#trying to develop haplotagging pipeline from meier el al data

#### SETUP ENVIRONMENT ###
module load miniconda
conda activate haplotagging
module load SAMtools/1.7-foss-2018a
module load HTSlib/1.9-foss-2018b
module load VCFtools/0.1.16-foss-2018b-Perl-5.28.0


mkdir -p errs
mkdir -p outs
mkdir -p data
mkdir -p data/correctSampleBams

ln -s /home/nbe4/project/RASY_assembly/VGP/2.HiC/finalAssembly_r0.2.chrom/aRanSyl1_s2_polished2.wrap.FINAL.chroms.fasta data/

### DEFINE VARIABLES ###
homeDir=~/scratch60/haplotagging/2.callHaplotypes/EMA_HiC_fieldwork
refGenome=$homeDir/data/aRanSyl1_s2_polished2.wrap.FINAL.chroms.fasta
bamList=samples.bam.txt
bamDir=/home/nbe4/scratch60/haplotagging/1.mapReads/EMA_HiC_fieldwork/alignments/
correctBamList=samples.correctNames.bam.txt

K=38
summaryFile=stitch.K$K.summary.txt

### RUN CODE ###
#first, prepare bam files (sort them)
#ls $bamDir/*.bam > $bamList ##had an issue that EMA called every sample "sample1" in its mapping, so had to manually add sample names with the command:
# while read line; do base=$(basename $line); sample=$(echo $base|cut -d "_" -f 1,2); echo $sample; samtools view -H $line | sed "s/SM:[^\t]*/SM:$sample/g"| samtools reheader - $line |samtools sort - > data/correctSampleBams/$base ; samtools index -c data/correctSampleBams/$base; done < samples.bam.txt

#sbatch code/renameAndPrepareBams.slurm $bamList

#ls data/correctSampleBams/*.sorted.bam > $correctBamList
##prepare fasta
#samtools faidx $refGenome
#
#faSize -detailed $refGenome > $refGenome.faSize
#
# to improve speed, split genome into chromosomes
#pyfasta split -n 14 $refGenome

list=$(seq -w 01 11)
#list=00

for split  in $list
  do
  refPiece=${refGenome/fasta/$split.fasta}
  #samtools faidx $refPiece
  awk '{print $1}' $refPiece.fai > $refPiece.chroms
  base=$(basename $refGenome .fa)\_$split

  #run mpileup to determine SNPs in population.
  #the output from this will be used to create a .pos file and a .gen for STITCH

  # mkdir -p MPILEUP_$split
  # mPileup=`sbatch code/runMpileup.slurm $refPiece MPILEUP_$split/$base $correctBamList $refPiece.chroms|cut -d " " -f 4`

  # #impute genotypes with STITCH
  #rm -rf STITCH_K$K\_$split
  mkdir -p STITCH_K$K\_$split
  while read line
  do
  chrom=$(echo $line | awk '{print $1}')
  max=$(echo $line | awk '{print $2}')
  maxArray=$(echo "scale=0 ; $max / 10000000" | bc)
  #stitch=`sbatch --dependency=afterok:$mPileup code/runStitch.slurm $split $bamList MPILEUP_$split/$base.pos MPILEUP_$split/$base.gen $K|cut -d " " -f 4`
  stitch=`sbatch --array=0-$maxArray code/runStitch.array.slurm $split $correctBamList $homeDir/MPILEUP_$split/$base.pos $K $chrom $summaryFile|cut -d " " -f 4`
  #sbatch --array=0-$maxArray code/filterVCF.array.slurm $split $K $chrom
done < $refPiece.fai
  #
  # #infer haplotypes with HAPCUT2
  # while read line
  # do
  # chrom=$(echo $line | awk '{print $1}')
  # vcf=STITCH_K$K\_$split/stitch.$chrom.filtered.vcf.gz
  # rm -rf HAPCUT_K$K\_$split
  # mkdir HAPCUT_K$K\_$split
  # # sbatch --dependency=afterok:$stitch code/runHapCut.slurm $bamList $vcf HAPCUT_K$K\_$split $split
  # sbatch code/runHapCut.slurm $correctBamList $vcf HAPCUT_K$K\_$split $split
  # done < $refPiece.fai

done
