#!/bin/bash
#SBATCH --job-name 02-mapped-dbSnp155
#SBATCH -N 1
#SBATCH --mem 253952
#SBATCH -t 1-0:0:00
#SBATCH -o 02-mapped-dbSnp155_%j.out
#SBATCH -e 02-mapped-dbSnp155_%j.err

echo "Starting..."

# use UCSC tool to map the unique rsids to dbSnp155
$PATH_TO/bigBedNamedItems -nameFile $PATH_TO/dbSnp155.bb uniq-rsids.txt dbSnp155-raw.bed

echo "Finished!"
