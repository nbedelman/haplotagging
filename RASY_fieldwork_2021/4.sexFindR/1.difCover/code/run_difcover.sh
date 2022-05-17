#!/bin/bash

#SBATCH -J diffCover
#SBATCH -p day
#SBATCH -t 1-00:00
#SBATCH --mem=50G
#SBATCH -e errs/diffCover-%j.err
#SBATCH -o outs/diffCover-%j.out

FOLDER_PATH=/home/nbe4/project/software/DifCover/dif_cover_scripts/

BAM1=$1
baseOne=$(echo $(basename $BAM1) | cut -d "_" -f 1)
BAM2=$2
baseTwo=$(echo $(basename $BAM2) | cut -d "_" -f 1)

summaryFile=$3

a=1		# minimum coverage for sample1
A=20		# maximum coverage for sample1
b=1		# minimum coverage for sample2
B=20		# maximum coverage for sample2
v=1000		# target number of valid bases in the window
l=500		# minimum size of window to output
#AC=1	# Adjustment Coefficient (set 1 if modal coverage is equal)
p=1		# enrichment scores threshold (when p=2 will report regions with coverage in sample1 being roughly 4 times larger than coverage in sample2)
bin=1		# for auxiliary stage (5), generates enrichment scores histogram with scores in bins with floating precision 1. For more detailed histogram use 10, 100

#calculate Adjustment Coefficient
# echo "Calculating Adjustment Coefficient"
# modCov_1=$(code/getModalDepth.sh $BAM1)
# modCov_2=$(code/getModalDepth.sh $BAM2)
#
# AC=$(echo "scale=4 ; $modCov_2 / $modCov_1" | bc)
#
# echo "AC: $AC"
AC=1
#subset bam files
samtools view -h -F2308 -q1 $BAM1 HiC_scaffold_9 > $baseOne.chrom9.bam
samtools view -h -F2308 -q1 $BAM2 HiC_scaffold_9 > $baseTwo.chrom9.bam

## run stage (1)
echo "stage 1"
$FOLDER_PATH/from_bams_to_unionbed.sh $baseOne.chrom9.bam $baseTwo.chrom9.bam

## run stage (2)
echo "stage 2"
$FOLDER_PATH/from_unionbed_to_ratio_per_window_CC0 sample1_sample2.unionbedcv $a $A $b $B $v $l
#
# ## run stage (3)
echo "stage 3"
$FOLDER_PATH/from_ratio_per_window__to__DNAcopy_output.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l $AC
#
# ## run stage (4)
echo "stage 4"
$FOLDER_PATH/get_DNAcopyout_with_length_of_intervals.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout" ref.length.Vk1s_sorted
#
$FOLDER_PATH/generate_DNAcopyout_len_histogram.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout.len" $bin
#
# ## run stage (5)
echo "stage 5"
$FOLDER_PATH/from_DNAcopyout_to_p_fragments.sh "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout" $p


awk -v one=$baseOne -v two=$baseTwo 'BEGIN{OFS="\t"} {print $1,$2,$3,$4,$5,one,two}' sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout > sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout.label

cat sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l".log2adj_"$AC".DNAcopyout.label  >> $summaryFile
