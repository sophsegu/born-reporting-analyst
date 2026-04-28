
library(tidyverse)

setwd("C:/Users/sophs/OneDrive/Desktop/born-reporting-analyst")

raw <- read_csv("./data/raw/natl2018us.csv", guess_max=10000)

# Print column names to map them
cat("Column names in file:\n")
cat(names(raw), sep = "\n")

