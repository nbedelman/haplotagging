#!/bin/bash

#SBATCH -J ema_prep
#SBATCH -p day
#SBATCH --mem=350G
#SBATCH -t 1-00:00
#SBATCH -c 36
#SBATCH -e errs/ema_prep-%j.err
#SBATCH -o outs/ema_prep-%j.out

fileList=$1
outDir=$2
refGenome=$3

read1=$(head -n ${SLURM_ARRAY_TASK_ID} $fileList| tail -1)
read2=${read1/_R1/_R2}

echo "Adding 16 base barcode to $read1..."
echo "zcat $read1 | 16BaseBCGen ${read1/.fastq.gz} | bgzip -@ 16 > ${read1/.fastq/.16BCgen.fastq}"
zcat $read1 |sed 's/AC\tRX:/\tRX:/' | 16BaseBCGen ${read1/.fastq.gz} | bgzip -@ 16 > ${read1/.fastq/.16BCgen.fastq}
echo "Making symlink for $read2.";
echo "ln -s `pwd`/${read2} `pwd`/${read2/.fastq/.16BCgen.fastq}"
#ln -s `pwd`/${read2/.fastq/.16BCgen.fastq}
ln -s ${read2} ${read2/.fastq/.16BCgen.fastq}

cut -f 2 ${read1/.fastq.gz}_HaploTag_to_16BaseBCs | tail -n +2 > ${read1/.fastq.gz}_HaploTag_to_16BaseBCs.ema
stem=${read1/.fastq.gz/}

#Generate first command for ema count and preproc
paste <(pigz -c -d ${read1/.fastq/.16BCgen.fastq} | paste - - - - | awk '{print $1"\t"$5"\t"$6"\t"$7}') <(pigz -c -d ${read2/.fastq/.16BCgen.fastq} | paste - - - - | awk '{print $1"\t"$5"\t"$6"\t"$7}') | tr "\t" "\n" | ema count -w ${stem}_HaploTag_to_16BaseBCs.ema -o $stem.16BCgen 2>&1 | tee $stem.16BCgen.log; paste <(pigz -c -d ${read1/.fastq/.16BCgen.fastq} | paste - - - - | awk '{print $1"\t"$5"\t"$6"\t"$7}') <(pigz -c -d ${read2/.fastq/.16BCgen.fastq} | paste - - - - | awk '{print $1"\t"$5"\t"$6"\t"$7}') | tr "\t" "\n" | ema preproc -w ${stem}_HaploTag_to_16BaseBCs.ema -n 500 -t 20 -o ${stem}_outdir ${stem}.16BCgen.ema-ncnt 2>&1 | tee ${stem}_preproc.log

#Then generate the command for ema align
alignDir=$outDir/$(basename $stem)
mkdir -p $alignDir

parallel --bar -j9 "ema align -t 10 -d -r $refGenome -p 10x -s {} | samtools sort -@ 10 -O bam -l 0 -m 4G -o $alignDir/{/.}.bam -" ::: ${stem}_outdir/ema-bin-???

samtools merge -f -@ 24 $outDir/$(basename $stem).bam $alignDir/*.bam

samtools index -c -@ 24 $outDir/$(basename $stem).bam

samtools sort -t BX -@ 24 -o $outDir/$(basename $stem).sorted.bam $outDir/$(basename $stem).bam

samtools index -c -@ 24 $outDir/$(basename $stem).sorted.bam

code/bed_write.pl $outDir/$(basename $stem).sorted.bam

code/getStats.slurm $outDir/$(basename $stem).sorted.bam
