#!/bin/bash

#SBATCH -J STITCH
#SBATCH -p day,week,bigmem
#SBATCH --mem=300G
#SBATCH -c 6
#SBATCH -t 1-00:00 
#SBATCH -e errs/runStitch-%j.err
#SBATCH -o outs/runStitch-%j.out

split=$1
bamList=$2
posFile=$3
K=$4
chrom=$5
summaryFile=$6

start=$(awk -v i=${SLURM_ARRAY_TASK_ID} 'BEGIN {print i * 10000000}' )

end=$(awk -v start=$start 'BEGIN {print start + 10000000}')

outDir=STITCH_K$K\_${split}

if [ ! -s $outDir/stitch.$chrom.score.K$K.$chrom.$start.$end.txt ]; then #added this line because some of the windows didnt finish but most did. re-ran the array with this.

thisPos=$outDir/$chrom.pos

grep $chrom $posFile > $thisPos

STITCH.R --chr=$chrom --bamlist=$bamList --posfile=$thisPos \
  --outputdir=$outDir --K=$K --splitReadIterations=NULL --method=diploid --nGen=100 --nCores=6 --readAware=TRUE --keepInterimFiles=FALSE --tempdir=/tmp \
  --shuffle_bin_radius=500 --expRate=.25 --iSizeUpperLimit=500000 \
  --plot_shuffle_haplotype_attempts=TRUE --niterations=50 --output_haplotype_dosages=TRUE \
  --regionStart=$start --regionEnd=$end --buffer=500000 --keepSampleReadsInRAM=FALSE --plotAfterImputation=TRUE --outputSNPBlockSize=50000


tabix -p vcf -C $outDir/stitch.$chrom.$start.$end.vcf.gz

bcftools query -f '%CHROM %POS %INFO_SCORE\n' $outDir/stitch.$chrom.$start.$end.vcf.gz |awk -v K=$K -v gen=$gen '{print $1,$2,$3,$4=K, $5=gen}' > $outDir/stitch.$chrom.score.K$K.$chrom.$start.$end.txt

bcftools filter --threads 24 -e 'INFO/INFO_SCORE<=0.4'  $outDir/stitch.$chrom.$start.$end.vcf.gz  | bcftools view --threads 24 -m2 -M2 -q 0.01:minor -Oz -o $outDir/stitch.$chrom.$start.$end.filter.vcf.gz

tabix -p vcf -C $outDir/stitch.$chrom.$start.$end.filter.vcf.gz

stats=$(Rscript code/summarizeStitch.R $outDir $chrom.$start.$end)
echo $chrom $start $K $stats >> $summaryFile

fi
