#!/bin/bash

#SBATCH -J HapCut2
#SBATCH -p week
#SBATCH -N 1
#SBATCH --mem=50G
#SBATCH -t 2-00:00
#SBATCH -e errs/runHapCut-%j.err
#SBATCH -o outs/runHapCut-%j.out


bamList=$1
vcf=$2
outDir=$3
split=$4


while read bam
  do
    sample=$(echo $(basename $bam)|cut -d _ -f 1,2)

    out=$outDir/$(basename $bam .sorted.bam).$split.$sample

    tabix -f -C -p vcf $vcf

    bcftools view -s $sample $vcf | grep -v "\./\."> $vcf.$sample.vcf

    extractHAIRS --10X 1 --bam $bam --VCF $vcf.$sample.vcf --out $out.unlinked.fragments

    awk '!/[ABCD]00/' $out.unlinked.fragments > $out.no00.unlinked.fragments

    python3 /home/nbe4/project/software/HapCUT2/utilities/LinkFragments.py  --bam $bam --VCF $vcf.$sample.vcf --fragments $out.no00.unlinked.fragments --out $out.no00.linked.fragments -d 50000;

    HAPCUT2 --fragments $out.no00.linked.fragments --VCF $vcf.$sample.vcf --out $out.hapcut2.threshold_30.errAn.output --nf 1 --threshold 0.30
    bgzip $out.hapcut2.threshold_30.errAn.output.phased.VCF
    tabix -f -C -p vcf $out.hapcut2.threshold_30.errAn.output.phased.VCF.gz
    echo $out.hapcut2.threshold_30.errAn.output.phased.VCF.gz >> $outDir/outVCFList.txt
    whatshap stats --block-list $out.hapcut2.threshold_30.errAn.output.phased.blocks.txt $out.hapcut2.threshold_30.errAn.output.phased.VCF.gz
    code/summarizeBlocks.py $out.hapcut2.threshold_30.errAn.output.phased.blocks.txt $out.hapcut2.threshold_30.errAn.output.phased.blocks.stats
done < $bamList


bcftools merge -O z -l $outDir/outVCFList.txt -o $outDir/$split.hapcut2.threshold_30.errAn.output.phased.vcf.gz
