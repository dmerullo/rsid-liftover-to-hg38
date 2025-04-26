# Abstract

**SPUR: A tool for updating SNP locations from rsIDs across different reference builds.**

Single nucleotide polymorphisms (SNPs), which are changes to individual base pairs in the human genome that occur in more than 1% of a sampled population, underlie the discovery of novel biomarkers for genomic medicine. Current advances in computational methods are well-placed to leverage the breadth of SNP data accessible in published studies and databases to uncover new patterns and insights from genomic variation, but differences in genomic reference builds over the span of several decades hinder the integration of datasets. Since a unique reference SNP identification number (rsID) from the public SNP Database (dbSNP) is assigned to each SNP independent of its genomic position, rsIDs are stable across genome builds. However, since rsIDs can be dropped or merged with subsequent revisions to dbSNP, a given SNP is not always associated with the same rsID. This disconnect generates inconsistences when trying to analyze datasets that incorporate rsIDs and genomic positions on different builds of either dbSNP or the human genome. SPUR ("SNP Position Update from rsIDs") is a software package written in R, Python, and Bash that addresses this issue by updating SNP positions from a non-current build to a current build through the stable, trackable history of rsIDs. First, SPUR identifies the rsIDs in the original data that map to the current dbSNP build without issue, and those that do not. Then, SPUR differentiates between the non-mapping rsIDs that have been merged to a different rsID in the current build, and the rsIDs that have been dropped completely. Finally, SPUR updates the SNP positions in the original dataset by linking the mapped and merged rsIDs with current genome positions. The pipeline is fully automated and can be used for any type of file with SNP positions and rsIDs. In a sample genome-wide association study containing 1,663,453 rsIDs, only SNP locations for 253 rsIDs (0.015%) could not be updated from the original build (hg18, released in 2006) to the current build (dbSNP 155 on hg38, released in 2021). All updates to the 153 files of this dataset, totaling 16 GB, ran to completion in a few hours. SPUR could apply to at least 2,000 files not harmonized in the NHGRI-EBI GWAS Catalog, and likely many more. By facilitating the synchronization of datasets generated from different resources, SPUR can enhance the utilization of rare data sources to enable increased power during analysis and aid exploratory and applied biomedical research for improving patient health outcomes.

# Lift over rsids from hg36/hg37 to hg38

This is a pipeline to lift over datasets from human genome build 36 or 37 to build 38 when the original data contain rsids. There are two precursor steps before liftover: the first to map the positions for the rsids that are stable from hg36/hg37 to hg38, and the second to get the positions for the rsids that were merged from hg36/hg37 to hg38. Completing this pipeline also identifies the rsids that cannot be used from hg36/hg37 to h38.

# Steps to run

## Prepare external tools
1. Download dbSnp155 from UCSC with the command `wget http://hgdownload.soe.ucsc.edu/gbdb/hg38/snp/dbSnp155.bb`. It is a large file (67.5 GB), so put it on HPC scratch.
2. Download the tool `bigBedNamedItems` from UCSC: `wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigBedNamedItems`.
    - You will need to modify permissions with `chmod +x` to make this executable.
3. Download the file `RsMergeArch.bcp.gz` (necessary to run liftRsNumber) from NCBI: `wget ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606/database/organism_data/RsMergeArch.bcp.gz`
4. Download the file `SNPHistory.bcp.gz` (necessary to run liftRsNumber) from NCBI: `wget ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606/database/organism_data/SNPHistory.bcp.gz`

## Identify mapped and merged rsids
5. Download the script `liftRsNumber.py` in this repository. It originates from UMichigan (source below), but I modified it slightly to alter the output format.
6. For your target build, download either the script `table-hg36-hg38.R` or `table-hg37-hg38.R` from this repository.
7. Modify the filepaths (beginning with `$PATH_TO`) in the following files for your filesystem:
    - `liftRsNumber.py`
    - either `table-hg36-hg38.R` or `table-hg37-hg38.R`
    - `01-uniq-rsids.sh`
    - `02-mapped-dbSnp155.sh`
    - `03-merged-dbSnp155.sh`
8. Run `sbatch 01-uniq-rsids.sh` to get the uniq rsids present in your dataset. This step can take some time to complete.
9. Run `sbatch 02-mapped-dbSnp155.sh` to get the rsids that map to dbSnp155.
10. Run `sbatch 03-merged-dbSnp155.sh` to get the rsids that have been merged in dbSnp155.
    - The final output of this step contains the mapped and merged rsids in a single table.

## Lift over source data
11. For your target build, download either the script `liftover-hg36-hg38.R` or `liftover-hg37-hg38.R` from this repository, modify the filepaths (beginning with `$PATH_TO`) for your filesystem, and edit the final codeblock as described in the comment.
12. For your target build, run either `sbatch 04-liftover-hg36-hg38.sh` or `sbatch 04-liftover-hg37-hg38.sh`.

# Sources

Info on UCSC tools: http://www.genome.ucsc.edu/FAQ/FAQdownloads.html

Info on UMichigan tools: https://genome.sph.umich.edu/w/index.php?title=LiftOver&mobileaction=toggle_view_desktop

Source for liftRsNumber.py: https://genome.sph.umich.edu/wiki/LiftRsNumber.py \
***but use my edited version in this repository, NOT the one at the link***
