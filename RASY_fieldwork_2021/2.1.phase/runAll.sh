#trying to phase with beagle instead of HAPCUT2 so I can use population data

#### SETUP ENVIRONMENT ###
module load miniconda
conda activate haplotagging
module load SAMtools/1.7-foss-2018a
module load HTSlib/1.9-foss-2018b
module load VCFtools/0.1.16-foss-2018b-Perl-5.28.0


mkdir -p errs
mkdir -p outs

### DEFINE VARIABLES ###
BEAGLE=~/project/software/bin/beagle.19Apr22.7c0.jar
STITCH_VCF=/home/nbe4/palmer_scratch/haplotagging/2.callHaplotypes/EMA_HiC_fieldwork/STITCH_K38_04/stitch.HiC_scaffold_9.filtered.vcf.gz
outBase=HiC_scaffold_9

### RUN CODE ###
sbatch code/runBeagle.slurm $BEAGLE $STITCH_VCF $outBase
