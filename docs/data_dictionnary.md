# Data Dictionary – Perinatal Health Surveillance Dataset

| Variable | Description | Values / Coding | Source |
|----------|-------------|-----------------|--------|
| `preterm_flag` | Preterm birth (< 37 weeks) | `preterm`, `term` | Derived from `gestrec3` (1 = preterm, 2/3 = term) |
| `smoking_pattern` | Smoking trajectory across pregnancy | `never`, `quit_early`, `quit_late`, `started`, `persistent` | Derived from `cig_0`, `cig_1`, `cig_2`, `cig_3` |
| `smoke_before` | Smoking before pregnancy | `none`, `light`, `heavy` | Derived from `cig_0` |
| `smoke_tri1` | Smoking 1st trimester | `none`, `light`, `heavy` | Derived from `cig_1` |
| `smoke_tri2` | Smoking 2nd trimester | `none`, `light`, `heavy` | Derived from `cig_2` |
| `smoke_tri3` | Smoking 3rd trimester | `none`, `light`, `heavy` | Derived from `cig_3` |
| `bmi_cat` | Pre‑pregnancy BMI category | `Underweight`, `Normal`, `Overweight`, `Obese` | Derived from `bmi` using WHO cutoffs |
| `maternal_age_group` | Maternal age group | `<20`, `20-34`, `35+` | Derived from `mager` |
| `race_eth` | Race / Hispanic origin | `Non-Hispanic White`, `Non-Hispanic Black`, `Hispanic`, `Non-Hispanic Other`, `Unknown` | Recoded from `mracehisp` |
| `education` | Education level | `<High school`, `High school`, `Some college`, `College grad`, `Advanced degree`, `Unknown` | Recoded from `meduc` |
| `prior_preterm` | Previous preterm birth | `Yes`, `No` | `rf_ppterm` |
| `diabetes` | Any diabetes (pre‑pregnancy or gestational) | `Yes`, `No` | Derived from `rf_gdiab`, `rf_pdiab` |
| `c_section` | Caesarean section | `C-section`, `Vaginal` | Derived from `dmeth_rec` |
| `lbw` | Low birth weight (< 2500 g) | `Yes`, `No` | Derived from `dbwt` |
| `nicu` | NICU admission | `Yes`, `No` | `ab_nicu` |
| `dbwt` | Birth weight (grams) | Continuous | CDC Natality |
| `apgar5` | 5‑minute Apgar score | 0–10 | CDC Natality |
| `gestrec3` | Gestational age recode | 1 = preterm, 2 = early term, 3 = full term | CDC Natality |
| `sex` | Infant sex | `Male`, `Female`, `Unknown` | Recoded from `sex` |