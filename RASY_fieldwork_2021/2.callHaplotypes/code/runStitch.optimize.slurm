#!/bin/bash

#SBATCH -J STITCH
#SBATCH -p day,week,bigmem
#SBATCH --mem=300G
#SBATCH -c 6
#SBATCH -t 1-00:00
#SBATCH -e errs/runStitch-%j.err
#SBATCH -o outs/runStitch-%j.out


bamList=$1
posFile=$2
summaryFile=$3
K=$4

#will optimize based on a 5MB chunk on chromosome 1


chrom=$(awk '{print $1}' $posFile|uniq)

genList=$(echo 100)

start=95000000
end=100000000

#thisPos=STITCH_optimize/$(basename $posFile .pos).$chrom.pos
#awk -v chrom=$chrom '$1==chrom' $posFile > $thisPos

outDir=STITCH_optimize/$chrom\_K$K\_gen$gen


for gen in $genList
  do
      outDir=STITCH_optimize/$chrom\_K$K\_gen$gen
      mkdir $outDir
      STITCH.R --chr=$chrom --bamlist=$bamList --posfile=$posFile \
      --outputdir=$outDir --K=$K --splitReadIterations=NULL --method=diploid --nGen=$gen --nCores=6 --readAware=TRUE --keepInterimFiles=FALSE --tempdir=/tmp \
      --shuffle_bin_radius=500 --expRate=0.25 --iSizeUpperLimit=50000  --regionStart=$start --regionEnd=$end --buffer=25000 --keepSampleReadsInRAM=FALSE \
      --plot_shuffle_haplotype_attempts=TRUE --niterations=40 --plotAfterImputation=TRUE --output_haplotype_dosages=TRUE --outputSNPBlockSize=50000

      tabix -p vcf $outDir/stitch.$chrom.$start.$end.vcf.gz
      bcftools query -f '%CHROM %POS %INFO_SCORE\n' $outDir/stitch.$chrom.$start.$end.vcf.gz |awk -v K=$K -v gen=$gen '{print $1,$2,$3,$4=K, $5=gen}' > $outDir/stitch.$chrom.score.K$K\_gen$gen.txt

      stats=$(Rscript code/summarizeStitch.R $outDir $chrom.$start.$end)
      echo $K $gen $stats >> $summaryFile
done



# We anticipate that in using STITCH, the majority of users will achieve desired results, both in terms of accuracy and computational speed, through varying K, G, the method (diploid or pseudo-haploid), and the number of pseudohaploid iterations.
# In the absence of external validation
# data, we recommend the info score distribution or its average. If, for the diploid
# method and a choice of K, results start to deteriorate, then choose the diploid
# mode and K that gave optimal performance. If results do not deteriorate but become computationally impractical, we recommend applying the pseudo-haploid
# method for a range of pseudo-haploid and diploid iterations (as was done here for
# CONVERGE), and choosing the combination that gives optimal results under
# the given computational constraints.
