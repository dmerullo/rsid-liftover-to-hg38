library(tidyverse)

lifted <-
  read_tsv(
    file.path(
      "$PATH_TO/lifted.bed"
    ),
    col_names = c(
      "chr", 
      "start",
      "end",
      "rsid_hg38"
    )
  )
  
`final-rsids` <-
  read_tsv(
    file.path(
      "$PATH_TO/final-rsids.txt"
    ),
    col_names = c(
      "rsid_hg36",
      "rsid_hg38"
    )
  )

table_hg36_hg38 <-
  left_join(
    lifted, `final-rsids`, by = "rsid_hg38"
  )

write_tsv(
  table_hg36_hg38,
  file.path(
    "$PATH_TO/table_hg36_hg38.tsv"
  )
)
