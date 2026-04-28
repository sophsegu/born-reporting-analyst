library(tidyverse)
library(data.table)

setwd("D:/born-reporting-analyst/")

data <- fread("./data/processed/natal_2018_sample.csv")

cig_0 <- data$cig_0
cig_1 <- data$cig_1
cig_2 <- data$cig_2
cig_3 <- data$cig_3

cleaned <- data %>%
  mutate(
    preterm_flag = case_when(
      gestrec3 == 1 ~ "preterm",
      gestrec3 %in% c(2, 3) ~ "term"
    ),
    
    bmi_cat = case_when(
      bmi < 18.5 ~ "Underweight",
      bmi >= 18.5 & bmi < 25 ~ "Normal",
      bmi >= 25 & bmi < 30 ~ "Overweight",
      bmi >= 30 ~ "Obese"
    ),
    
    # --- Create smoking categories ---
    smoke_before = case_when(
      cig_0 >= 98 ~ NA_character_,
      cig_0 == 0 ~ "none",
      cig_0 >= 1 & cig_0 <= 9 ~ "light",
      cig_0 >= 10 ~ "heavy"
    ),
    
    smoke_tri1 = case_when(
      cig_1 >= 98 ~ NA_character_,
      cig_1 == 0 ~ "none",
      cig_1 >= 1 & cig_1 <= 9 ~ "light",
      cig_1 >= 10 ~ "heavy"
    ),
    
    smoke_tri2 = case_when(
      cig_2 >= 98 ~ NA_character_,
      cig_2 == 0 ~ "none",
      cig_2 >= 1 & cig_2 <= 9 ~ "light",
      cig_2 >= 10 ~ "heavy"
    ),
    
    smoke_tri3 = case_when(
      cig_3 >= 98 ~ NA_character_,
      cig_3 == 0 ~ "none",
      cig_3 >= 1 & cig_3 <= 9 ~ "light",
      cig_3 >= 10 ~ "heavy"
    ),
    # Other confounders
    maternal_age_group = case_when(
      mager < 20 ~ "<20",
      mager >= 20 & mager <= 34 ~ "20-34",
      mager >= 35 ~ "35+"
    ),
    race_eth = recode_factor(mracehisp,
                             `1` = "Non-Hispanic White",
                             `2` = "Non-Hispanic Black",
                             `3` = "Hispanic",
                             `4` = "Non-Hispanic Other",
                             .default = "Unknown"),
    
    sex = case_when(
      sex == "M" ~ "Male",
      sex == "F" ~ "Female",
      TRUE ~ "Unknown"
    ),
    education = recode_factor(meduc, `1`="<High school", `2`="High school", `3`="Some college", 
                              `4`="College grad", `5`="Advanced degree", .default = "Unknown"),
    prior_preterm = if_else(rf_ppterm == "Y", "Yes", "No"),
    diabetes = if_else(rf_gdiab == "Y" | rf_pdiab == "Y", "Yes", "No"),
    c_section = if_else(dmeth_rec == 2, "C-section", "Vaginal"),
    lbw = if_else(dbwt < 2500, "Yes", "No"),
    nicu = if_else(ab_nicu == "Y", "Yes", "No")
  ) %>%
  
  # --- Improved trajectory variable ---
  mutate(
    smoking_pattern = case_when(
      
      # Never smoked at any time
      smoke_before == "none" & smoke_tri1 == "none" &
        smoke_tri2 == "none" & smoke_tri3 == "none" ~ "never",
      
      # Quit early (stopped by trimester 1)
      !is.na(smoke_before) & smoke_before != "none" &
        smoke_tri1 == "none" & smoke_tri2 == "none" & smoke_tri3 == "none" ~ "quit_early",
      
      # Quit late (smoked into pregnancy but not in tri3)
      !is.na(smoke_before) & smoke_before != "none" &
        (smoke_tri1 != "none" | smoke_tri2 != "none") &
        smoke_tri3 == "none" ~ "quit_late",
      
      # Started during pregnancy
      smoke_before == "none" &
        (smoke_tri1 != "none" | smoke_tri2 != "none" | smoke_tri3 != "none") ~ "started",
      
      # Persistent smokers (smoked at all time points)
      !is.na(smoke_before) & smoke_before != "none" &
        smoke_tri1 != "none" & smoke_tri2 != "none" & smoke_tri3 != "none" ~ "persistent",
      
      # Everything else (missing / weird patterns)
      TRUE ~ NA_character_
    )
  )

# Check smoking categories
table(cleaned$smoking_pattern, useNA = "ifany")
table(cleaned$smoke_before, useNA = "ifany")
table(cleaned$smoke_tri1, useNA = "ifany")
table(cleaned$smoke_tri2, useNA = "ifany")
table(cleaned$smoke_tri3, useNA = "ifany")

# Cross-tab: smoking pattern vs preterm flag
table(cleaned$smoking_pattern, cleaned$preterm_flag)

# Preterm prevalence by smoking pattern (row proportions)
prop.table(table(cleaned$smoking_pattern, cleaned$preterm_flag), margin = 1)

# If you want the same for smoke_before vs preterm
prop.table(table(cleaned$smoke_before, cleaned$preterm_flag), margin = 1)

# Save the cleaned data
write_csv(cleaned, "data/processed/natal_cleaned.csv")

library(gtsummary)
cleaned %>%
  select(preterm_flag, smoking_pattern, bmi_cat, maternal_age_group, education, 
         prior_preterm, diabetes, c_section) %>%
  tbl_summary(by = preterm_flag) %>%
  add_p()

# Poisson regression with robust variance (or log-binomial)
library(sandwich)
library(lmtest)
mod <- glm((preterm_flag == "preterm") ~ smoking_pattern, 
           data = cleaned, family = poisson)
exp(coefci(mod, vcov = sandwich))

mod_adj <- glm((preterm_flag == "preterm") ~ smoking_pattern + bmi_cat + 
                 maternal_age_group + education + prior_preterm + diabetes, 
               data = cleaned, family = poisson)
# robust SEs
coeftest(mod_adj, vcov = sandwich)

library(ggplot2)
cleaned %>%
  filter(!is.na(smoking_pattern)) %>%
  group_by(smoking_pattern) %>%
  summarise(preterm_rate = mean(preterm_flag == "preterm")) %>%
  ggplot(aes(x = smoking_pattern, y = preterm_rate)) +
  geom_col() +
  labs(y = "Preterm birth proportion")


