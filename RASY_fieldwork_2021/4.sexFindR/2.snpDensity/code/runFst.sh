vcftools --gzvcf /home/nbe4/palmer_scratch/haplotagging/2.callHaplotypes/EMA_HiC_fieldwork/STITCH_K38_04/stitch.HiC_scaffold_9.filtered.vcf.gz --weir-fst-pop data/males.txt --weir-fst-pop data/females.txt --fst-window-size 1000 --out biallelic_fst.1kb