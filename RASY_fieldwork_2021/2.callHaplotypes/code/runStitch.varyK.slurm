#!/bin/bash

#SBATCH -J STITCH
#SBATCH -p day
#SBATCH --mem=200G
#SBATCH -c 24
#SBATCH -t 0-05:00
#SBATCH -e errs/runStitch-%j.err
#SBATCH -o outs/runStitch-%j.out

split=$1
bamList=$2
posFile=$3
genFile=$4

#stitch can only handle one chromosome at a time, but we're giving it several. Split here and run by chromosome.

#chromList=$(awk '{print $1}' $posFile|uniq)
chrom=scaffold_1
Klist=$(echo 8 12 14 16)

thisPos=STITCH_$split/$(basename $posFile .pos).$chrom.pos
awk -v chrom=$chrom '$1==chrom' $posFile > $thisPos

for K in $Klist
do
STITCH.R --chr=$chrom --bamlist=$bamList --posfile=$thisPos \
--outputdir=STITCH_Ktest/$K --K=$K --method=diploid --nGen=500 --nCores=24 --readAware=TRUE --keepInterimFiles=FALSE \
--shuffle_bin_radius=500 --expRate=5 --iSizeUpperLimit=500000 \
--plot_shuffle_haplotype_attempts=TRUE

bcftools query -f '%CHROM %POS %INFO_SCORE\n' STITCH_${split}/stitch.$chrom.vcf.gz |awk -v K=$K '$4=K' > STITCH_${chrom}/stitch.$chrom.score.txt

done

# --genfile=$genFile \

# We anticipate that in using STITCH, the majority of users will achieve desired results, both in terms of accuracy and computational speed, through varying K, G, the method (diploid or pseudo-haploid), and the number of pseudohaploid iterations.
# In the absence of external validation
# data, we recommend the info score distribution or its average. If, for the diploid
# method and a choice of K, results start to deteriorate, then choose the diploid
# mode and K that gave optimal performance. If results do not deteriorate but become computationally impractical, we recommend applying the pseudo-haploid
# method for a range of pseudo-haploid and diploid iterations (as was done here for
# CONVERGE), and choosing the combination that gives optimal results under
# the given computational constraints.
