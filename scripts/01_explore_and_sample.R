
library(tidyverse)
library(data.table)

setwd("D:/born-reporting-analyst/")

raw <- fread("./data/raw/natl2018us.csv")

# Print column names to map them
cat("Column names in file:\n")
cat(names(raw), sep = "\n")

cols_keep <- c(
  "mager", "mracehisp", "meduc", "mar_p", "precare", "wic",
  "priorlive", "priordead", "priorterm",
  "illb_r11", "ilop_r11", "ilp_r11",
  "cig_0", "cig_1", "cig_2", "cig_3",
  "m_ht_in", "bmi",
  "rf_cesar", "rf_ghype", "rf_ehype", "rf_ppterm", "rf_pdiab", "rf_gdiab",
  "ld_indl", "ld_augm", "ld_anes",
  "me_pres", "me_rout",
  "rdmeth_rec", "dmeth_rec",
  "dbwt", "apgar5", "apgar10", "gestrec3", "sex",
  "ab_nicu", "ab_surf", "bfed", "ilive"
)

natal <- raw %>% select(any_of(cols_keep))

natal <- natal %>% filter(ilive == "Y")

# Derive preterm flag
natal <- natal %>%
  mutate(
    preterm_flag = case_when(
      gestrec3 == 1 ~ "preterm",
      gestrec3 %in% c(2, 3) ~ "term",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(preterm_flag))

# Stratified sampling
set.seed(123)
group_counts <- natal %>% count(preterm_flag)
n_preterm_total <- group_counts[group_counts$preterm_flag == "preterm", "n"][[1]]
n_term_total   <- group_counts[group_counts$preterm_flag == "term", "n"][[1]]

n_preterm <- min(250000, n_preterm_total)
n_term    <- min(250000, n_term_total)

sample_preterm <- natal %>%
  filter(preterm_flag == "preterm") %>%
  slice_sample(n = n_preterm, replace = FALSE)

sample_term <- natal %>%
  filter(preterm_flag == "term") %>%
  slice_sample(n = n_term, replace = FALSE)

natal_sample <- bind_rows(sample_preterm, sample_term) %>%
  slice_sample(prop = 1)   # shuffle

write_csv(natal_sample, "data/processed/natal_2018_sample.csv")

cat("Sample saved with", nrow(natal_sample), "rows.\n")
cat("Preterm rows:", sum(natal_sample$preterm_flag == "preterm"), "\n")
cat("Term rows:", sum(natal_sample$preterm_flag == "term"), "\n")