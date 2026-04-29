# Standard Operating Procedure – Data Validation Checklist

## ETL and Data Warehouse
- [x] Row counts after CSV import match source (500,000 rows)
- [x] Dimension tables populated with all distinct combinations
- [x] Fact table foreign keys correctly link to dimensions
- [x] No orphan records in fact table (all foreign keys have a match)

## Statistical Reporting (R Markdown)
- [x] Preterm birth prevalence by smoking pattern computed and matches expected values
- [x] Missing data handled consistently (excluded from tables or labelled “Unknown”)
- [x] Adjusted risk ratios calculated with robust standard errors
- [x] Report renders without errors (HTML/PDF)

## Cross‑validation with SAS
- [x] `natal_cleaned.csv` imported into SAS OnDemand
- [x] Key cross‑tabulations (preterm × smoking pattern) match R within 0.1%
- [x] Risk ratio estimates from `PROC GENMOD` align with R (within rounding)
- [x] SAS output saved and archived

## Power BI Dashboard
- [x] PostgreSQL data source connection successful
- [x] All DAX measures return expected values (e.g., Total Births = 500,000)
- [x] Slicers filter all intended visuals correctly
- [x] Blank/missing values filtered out where appropriate
- [x] Screenshots of all report pages captured

## Final Repository
- [x] All scripts run end‑to‑end without errors
- [x] Repository structure clean and documented
- [x] README includes reproduction steps and data source