#!/bin/bash

#SBATCH -J EMACount
#SBATCH -p day
#SBATCH --mem=5000
#SBATCH -t 0-05:00
#SBATCH -c 20
#SBATCH -e errs/EMACount-%j.err
#SBATCH -o outs/EMACount-%j.out

fastqDir=$1
whiteList=$2

cd $fastqDir

parallel -j40 --bar 'paste <(pigz -c -d {} | paste - - - -) <(pigz -c -d {= s:_R1_:_R2_: =} | paste - - - -) | tr "\t" "\n" | \
  ema count -w $whiteList -o {/.} 2>{/.}.log' ::: *_R1_*.gz
