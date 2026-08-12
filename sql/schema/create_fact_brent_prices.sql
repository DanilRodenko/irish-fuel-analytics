CREATE TABLE IF NOT EXISTS fact_brent_prices (
    obs_date DATE PRIMARY KEY,
    close_price NUMERIC(10,4) NOT NULL
);