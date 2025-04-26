library(tidyverse)

# load file that was output from pipeline step 02
`uniq-dbSnp155` <-
  read_tsv(
    file.path(
      "$PATH_TO/uniq-dbSnp155.bed"
    ),
    col_names = c(
      "chr",
      "start",
      "end",
      "rsid_hg38"
    )
  ) %>%
  mutate(rsid_hg37 = rsid_hg38)

# load file that was output from pipeline step 03
table_hg37_hg38 <-
  read_tsv(
    file.path(
      "$PATH_TO/table_hg37_hg38.tsv"
    )
  )

# create table of mapped and merged rsids
final_hg37_hg38 <-
  bind_rows(`uniq-dbSnp155`, table_hg37_hg38)

# specify location of source data
input_dir <-
  "$PATH_TO_SOURCE_DATA"

# specify location for output data
output_dir <-
  "$PATH_TO_OUTPUT_DIR"

# get list of filenames in input directory
files <-
  list.files(input_dir, pattern = "*.tsv.gz")

# for each source file, modify with the appropriate rsid and position in hg38
# you need to use the name in the source data that equates to `rsid_hg37` and `position_hg37`
# here that is `variant_id` and `base_pair_location`, but will differ for your dataset
lapply(files, function(x) {
  read_tsv(paste0(input_dir, x)) %>%
    left_join(final_hg37_hg38, by = c("variant_id" = "rsid_hg37")) %>%
    relocate("variant_id", "rsid_hg38", "chromosome", "end") %>%
    select(-chr) %>%
    rename(
      rsid_hg37 = variant_id,
      position_hg37 = base_pair_location,
      position_hg38 = end
    ) %>%
    filter(!is.na(rsid_hg38)) %>%
    write_tsv(., paste0(output_dir, "hg38_", basename(x)))
})
