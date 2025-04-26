#!/bin/bash
#SBATCH --job-name 01-uniq-rsids
#SBATCH -N 1
#SBATCH --mem 253952
#SBATCH -t 1-0:0:00
#SBATCH -o 01-uniq-rsids_%j.out
#SBATCH -e 01-uniq-rsids_%j.err

echo "Starting..."

# get rsids present in source data
for i in $PATH_TO_SOURCE_DATA/*; do
  zcat $i | tail -n +2 | cut -f 1
done > rsids.txt

# get only unique rsids
sort rsids.txt | uniq > uniq-rsids.txt

echo "Finished!"
