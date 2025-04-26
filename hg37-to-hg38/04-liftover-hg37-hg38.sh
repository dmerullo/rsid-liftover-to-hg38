#!/bin/bash
#SBATCH --job-name 04-liftover-hg37-hg38
#SBATCH -N 1
#SBATCH --mem 253952
#SBATCH -t 1-0:0:00
#SBATCH -o 04-liftover-hg37-hg38_%j.out
#SBATCH -e 04-liftover-hg37-hg38_%j.err

# load modules
module load R
ulimit -l unlimited

echo "Starting..."

R --no-save --no-restore < liftover-hg37-hg38.R > liftover-hg37-hg38.log 2> liftover-hg37-hg38.err

echo "Finished!"
