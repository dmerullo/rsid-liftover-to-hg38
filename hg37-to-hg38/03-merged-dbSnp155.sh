#!/bin/bash
#SBATCH --job-name 03-merged-dbSnp155
#SBATCH -N 1
#SBATCH --mem 253952
#SBATCH -t 1-0:0:00
#SBATCH -o 03-merged-dbSnp155_%j.out
#SBATCH -e 03-merged-dbSnp155_%j.err

# load modules
module load R/4.0.2

echo "Starting..."

# keep only the first four columns of the above output file, and remove non-standard chromosome entries
cut -f 1,2,3,4 dbSnp155-raw.bed | grep -v _ > uniq-dbSnp155.bed

# get the rsids that did not map to dpSnp155
cut -f 4 uniq-dbSnp155.bed | grep -Fvwf - uniq-rsids.txt > unmatched.txt

# prepare the unmapped rsids in the right format for the UMichigan tool
sed 's/rs//g' unmatched.txt > input.rs

# use the UMichigan tool to get the merged rsids in hg38 for the unmapped rsids from hg37
python2 /hpc/scratch/hdd1/dm729431/gtx-data-ingestion/ds844-shrine/liftRsNumber.py input.rs > output.rs

# get the hg36 rsids that are no longer valid
grep unchanged output.rs | cut -f 1,3 > unchanged-list.txt

# get the hg36 rsids that have properly merged rsids
grep lifted output.rs | cut -f 1,3 > lifted-list.txt

# prepare the above output in the right format for the UCSC tool
cut -f 2 lifted-list.txt > lifted-use.txt

# use the UCSC tool to map the merged rsids to dbSnp155
/hpc/mydata/upt/dm729431/tools/rsid-hg38/bigBedNamedItems -nameFile /hpc/scratch/hdd1/dm729431/files/dbSnp155/dbSnp155.bb lifted-use.txt lifted-raw.bed

# keep only the first four columns of the above output file, and remove non-standard chromosome entries
cut -f 1,2,3,4 lifted-raw.bed | grep -v _ > lifted.bed

# get the rsids that have "_fix" in the chromosome entry
cut -f 4 lifted.bed | grep -Fvf - lifted-use.txt > fix.txt

# get a final list of rsids that properly merged from hg37 to hg38
cut -f 4 lifted.bed | grep -Fwf - lifted-list.txt > final-rsids.txt

# make a table of the rsids from the above step with their position info
Rscript $PATH_TO/table-hg37-hg38.R > 03-table.log 2> 03-table.err

echo "Finished!"
