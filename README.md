# Irish Fuel Price Analytics

Pass-through, tax impact, and price-response analysis for the Irish fuel
market — built for a banking / treasury / procurement audience.

**Dashboard:** [Power BI — Irish Fuel Price Analytics](#) *(add link or screenshot)*

## Business Problem

Fuel is a volatile input cost. Two questions matter to anyone budgeting
around it:

1. When oil prices move, how fast and how much does that show up at the
   pump — and does it show up faster on the way up than on the way down?
2. When the government changes fuel excise duty, how does the retail
   price actually respond around that date?

This project answers both with real, publicly sourced data, and turns
the answers into a short lead-time window that treasury/procurement
teams can use for budgeting and hedging decisions.

## Data Sources

- **Brent crude (daily)** — Yahoo Finance (`BZ=F`), from 2007-07
- **EUR/USD (daily)** — Yahoo Finance (`EURUSD=X`), from 2003-12
- **Irish pump prices, with and without tax (weekly)** — EU Weekly Oil
  Bulletin (European Commission)
- **Irish excise duty rates (event-based)** — EU Weekly Oil Bulletin, 38
  recorded changes since ~2005

All loaded into PostgreSQL via `notebooks/00_data_pull_and_load.ipynb`.
Annual consumption data was excluded — its frequency doesn't match the
weekly granularity used elsewhere in the analysis.

## Data Limitations

- **Reporting frequency improved over time.** Roughly 40% of weekly pump
  price records before 2019 repeat the prior week's value unchanged —
  the source didn't update every week in earlier years. From 2023
  onward this is effectively zero. The pass-through and asymmetry
  analysis is restricted to **2019 onward** to avoid this noise.
- **Units.** Brent is USD/barrel; Irish pump prices are EUR/1000L in the
  raw source. Kept in original units in the model; the dashboard's
  context chart labels each axis with its own unit rather than forcing
  a shared scale.
- **Correlation, not isolated causation**, in the excise event study —
  excise changes can coincide with broader oil price movements, so the
  price pattern around those dates reflects the general market
  response, not a cleanly isolated tax effect.

## Method

- **Pass-through & asymmetry:** weekly % change (`pct_change`) in Brent,
  EUR/USD, and pump price, regressed with `statsmodels` OLS across
  0/1/2-week lags. Asymmetry tested by splitting Brent's % change into
  separate rise/fall regressors per lag.
- **Excise event study:** for each of the 38 recorded excise changes
  (16 petrol, 16 diesel with full data coverage), a ±4-week window
  around the event date, price normalized to the event-week value, then
  averaged across all events.

Full working — including the stationarity/cointegration checks that
were tested and ruled out an Error Correction Model — is documented in
the notebooks.

## Key Findings

**1. Pass-through is delayed, not instant.** A same-week Brent move
isn't a significant driver of pump prices (p=0.13). The effect becomes
significant and grows over the following two weeks — a 10% Brent rise
corresponds to roughly a 1.1% pump price rise after 1 week, and ~1.5%
after 2 weeks. **Practical read: there's a 1–2 week window between an
oil price move and its full effect at the pump.**

**2. Rise and fall pass through on different timelines ("rockets and
feathers").** Rising Brent prices show up faster (significant at 1
week); falling Brent prices show up slower but land harder (significant
and stronger at 2 weeks). Retailers appear to pass on cost increases
faster than cost decreases.

**3. Diesel is roughly twice as sensitive to excise changes as petrol.**
Around a typical excise change, diesel prices show a ~5.4 percentage
point swing (from -2.7% four weeks before to +2.7% four weeks after);
petrol shows about half that (~2.3pp). Both move gradually rather than
jumping on the effective date.

## Tech Stack

PostgreSQL · Python (pandas, statsmodels, sqlalchemy, yfinance) · Power
BI (Import mode, DAX) · SQL

## Repository Structure

```
data/processed/          — cleaned, model-ready datasets (parquet)
notebooks/
  00_data_pull_and_load.ipynb
  01_pass_through_analysis.ipynb
  02_asymmetry_analysis.ipynb
  03_excise_event_study.ipynb
dashboards/               — Power BI .pbix file
```

## What's Next

A Streamlit app with a natural-language query layer (LLM-backed) is
planned as a follow-on, for questions the dashboard doesn't visualize
directly.