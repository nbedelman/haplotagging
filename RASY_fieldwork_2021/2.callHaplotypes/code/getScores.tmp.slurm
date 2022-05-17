#!/bin/bash

#SBATCH -J getScores
#SBATCH -p day
#SBATCH --mem=1000
#SBATCH -c 1
#SBATCH -t 0-01:00
#SBATCH -e errs/getScores-%j.err
#SBATCH -o outs/getScores-%j.out

split=$1
bamList=$2
posFile=$3
genFile=$4

#preliminary analysis found that the best K for this data was 10-14.
#now need to optimize number of iterations and generations.
#chromList=$(awk '{print $1}' $posFile|uniq)
chrom=scaffold_1
Klist=$(echo 15 20 30 35)
genList=$(echo 10 50 100 500 1000)
iterList=$(echo 50)
expRate=$(echo 0.25 5)

thisPos=STITCH_optimize/$(basename $posFile .pos).$chrom.pos
awk -v chrom=$chrom '$1==chrom' $posFile > $thisPos

for K in $Klist
do
  for gen in $genList
  do
    for iter in $iterList
    do
      for exp in $expRate
      do
      # mkdir STITCH_optimize/K$K\_gen$gen\_iter$iter\_exp$exp
      # STITCH.R --chr=$chrom --bamlist=$bamList --posfile=$thisPos \
      # --outputdir=STITCH_optimize/K$K\_gen$gen\_iter$iter\_exp$exp --K=$K --method=diploid --nGen=$gen --nCores=24 --readAware=TRUE --keepInterimFiles=FALSE \
      # --shuffle_bin_radius=500 --expRate=$exp --iSizeUpperLimit=500000 \
      # --plot_shuffle_haplotype_attempts=TRUE --niterations=$iter --plotAfterImputation=TRUE
      #
      # tabix -p vcf STITCH_optimize/K$K\_gen$gen\_iter$iter\_exp$exp/stitch.scaffold_1.vcf.gz
      bcftools query -f '%CHROM %POS %INFO_SCORE\n' STITCH_optimize/K$K\_gen$gen\_iter$iter\_exp$exp/stitch.scaffold_1.vcf.gz |awk -v K=$K -v gen=$gen -v iter=$iter -v rate=$exp '{print $1,$2,$3,$4=K, $5=gen, $6=iter, $7=rate}' > STITCH_optimize/K$K\_gen$gen\_iter$iter\_exp$exp/stitch.$chrom.score.K$K\_gen$gen\_iter$iter\exp$exp.txt
done
done
done
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
