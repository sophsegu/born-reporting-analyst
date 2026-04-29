library(tidyverse)
library(sandwich)
library(lmtest)

setwd("D:/born-reporting-analyst/")

cleaned <- read_csv("data/processed/natal_cleaned.csv")

# Adjusted model (same as your .Rmd)
model_adj <- glm(
  (preterm_flag == "preterm") ~ smoking_pattern + bmi_cat +
    maternal_age_group + education + prior_preterm + diabetes,
  data = cleaned, family = poisson
)

# Robust standard errors
cov_adj <- vcovHC(model_adj, type = "HC0")

# Risk ratios and CIs
rr_adj <- exp(coef(model_adj))
ci_adj <- exp(coefci(model_adj, vcov = cov_adj, level = 0.95))

# Combine into a clean table
result <- data.frame(
  risk_factor = names(coef(model_adj)),
  rr = round(rr_adj, 2),
  ci_lower = round(ci_adj[,1], 2),
  ci_upper = round(ci_adj[,2], 2)
)

# Remove intercept
result <- result %>% filter(risk_factor != "(Intercept)")

# View it
print(result, row.names = FALSE)