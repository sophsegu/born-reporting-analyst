library(tidyverse)
library(DBI)
library(RPostgres)

cleaned <- read_csv("data/processed/natal_cleaned.csv")

# Connect to PostgreSQL
con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "postgres",
  host     = "localhost",
  port     = 5432,
  user     = "postgres",
  password = "1234"
)

# --- dim_maternal ---
maternal_distinct <- cleaned %>%
  select(
    age_group    = maternal_age_group,
    race_eth,
    education,
    bmi_cat,
    prior_preterm,
    diabetes
  ) %>%
  distinct()

dbAppendTable(con, "dim_maternal", maternal_distinct)
maternal_db <- dbReadTable(con, "dim_maternal")

# --- dim_delivery ---
delivery_distinct <- cleaned %>%
  select(c_section) %>%
  distinct()
dbAppendTable(con, "dim_delivery", delivery_distinct)
delivery_db <- dbReadTable(con, "dim_delivery")

# --- dim_infant ---
infant_distinct <- cleaned %>%
  select(sex) %>%
  distinct()
dbAppendTable(con, "dim_infant", infant_distinct)
infant_db <- dbReadTable(con, "dim_infant")

# --- dim_date (skip if no dob_yy/dob_mm) ---
# date_distinct <- cleaned %>%
#   select(year = dob_yy, month = dob_mm) %>%
#   distinct()
# dbAppendTable(con, "dim_date", date_distinct)
# date_db <- dbReadTable(con, "dim_date")

# 4. Build fact table with foreign keys
fact <- cleaned %>%
  left_join(maternal_db,
            by = c("maternal_age_group" = "age_group",
                   "race_eth", "education", "bmi_cat",
                   "prior_preterm", "diabetes")) %>%
  left_join(delivery_db, by = "c_section") %>%
  left_join(infant_db,      by = "sex") %>%
  select(
    maternal_id,
    delivery_id,
    infant_id,
    # date_id,            # uncomment if you have dim_date
    preterm_flag,
    birth_weight   = dbwt,
    apgar5,
    lbw_flag       = lbw,
    nicu_flag      = nicu,
    smoking_pattern,
    smoke_before,
    smoke_tri1,
    smoke_tri2,
    smoke_tri3
  )

# 5. Write fact table
dbAppendTable(con, "fact_births", fact)

cat("Rows in fact_births:", dbGetQuery(con, "SELECT COUNT(*) FROM fact_births")[1,1], "\n")

# 6. Disconnect
dbDisconnect(con)
cat("ETL completed successfully.\n")