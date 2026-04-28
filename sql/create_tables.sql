-- sql/create_tables.sql
CREATE TABLE dim_maternal (
    maternal_id SERIAL PRIMARY KEY,
    age_group           TEXT,
    race_eth            TEXT,
    education           TEXT,
    bmi_cat             TEXT,
    prior_preterm       TEXT,
    diabetes            TEXT
);

CREATE TABLE dim_delivery (
    delivery_id SERIAL PRIMARY KEY,
    c_section           TEXT
);

CREATE TABLE dim_infant (
    infant_id SERIAL PRIMARY KEY,
    sex                 TEXT
);

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    year                INTEGER,
    month               INTEGER
);

CREATE TABLE fact_births (
    birth_id            SERIAL PRIMARY KEY,
    maternal_id         INTEGER REFERENCES dim_maternal(maternal_id),
    delivery_id         INTEGER REFERENCES dim_delivery(delivery_id),
    infant_id           INTEGER REFERENCES dim_infant(infant_id),
    date_id             INTEGER REFERENCES dim_date(date_id),
    preterm_flag        TEXT,
    birth_weight        INTEGER,
    apgar5              INTEGER,
    lbw_flag            TEXT,
    nicu_flag           TEXT,
    smoking_pattern     TEXT,
    smoke_before        TEXT,
    smoke_tri1          TEXT,
    smoke_tri2          TEXT,
    smoke_tri3          TEXT
);