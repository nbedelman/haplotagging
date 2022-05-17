#!/bin/bash

#SBATCH -J STITCH
#SBATCH -p bigmem
#SBATCH --mem=1500G
#SBATCH -c 40
#SBATCH -t 1-00:00
#SBATCH -e errs/runStitch-%j.err
#SBATCH -o outs/runStitch-%j.out

split=$1
bamList=$2
posFile=$3
genFile=$4
K=$5

#stitch can only handle one chromosome at a time, but we're giving it several. Split here and run by chromosome.

chromList=$(awk '{print $1}' $posFile|uniq)


for chrom in $chromList
do
  thisPos=STITCH_K$K\_$split/$(basename $posFile .pos).$chrom.pos
  awk -v chrom=$chrom '$1==chrom' $posFile > $thisPos

STITCH.R --chr=$chrom --bamlist=$bamList --posfile=$thisPos \
--outputdir=STITCH_K$K\_${split} --K=$K --method=diploid --nGen=10 --nCores=40 --readAware=TRUE --keepInterimFiles=FALSE \
--shuffle_bin_radius=500 --expRate=.25 --iSizeUpperLimit=500000 \
--plot_shuffle_haplotype_attempts=TRUE --niterations=50 --output_haplotype_dosages=TRUE

tabix -p vcf STITCH_K$K\_${split}/stitch.$chrom.vcf.gz

bcftools query -f '%CHROM %POS %INFO_SCORE\n' STITCH_K$K\_${split}/stitch.$chrom.vcf.gz > STITCH_K$K\_${split}/stitch.$chrom.score.txt

done

bcftools concat -O z STITCH_K$K\_${split}/*scaffold_*.vcf.gz -o STITCH_K$K\_${split}/stitch.$split.vcf.gz
tabix -p vcf STITCH_K$K\_${split}/stitch.$split.vcf.gz

# --genfile=$genFile \

# We anticipate that in using STITCH, the majority of users will achieve desired results, both in terms of accuracy and computational speed, through varying K, G, the method (diploid or pseudo-haploid), and the number of pseudohaploid iterations.
# In the absence of external validation
# data, we recommend the info score distribution or its average. If, for the diploid
# method and a choice of K, results start to deteriorate, then choose the diploid
# mode and K that gave optimal performance. If results do not deteriorate but become computationally impractical, we recommend applying the pseudo-haploid
# method for a range of pseudo-haploid and diploid iterations (as was done here for
# CONVERGE), and choosing the combination that gives optimal results under
# the given computational constraints.
