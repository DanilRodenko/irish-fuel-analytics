CREATE TABLE IF NOT EXISTS fact_eur_usd_rates (
    obs_date DATE PRIMARY KEY,
    close_rate NUMERIC(10,6) NOT NULL
);