# Tiki Kitchen Appliances Market Analytics

End-to-end data analytics project: from crawling Tiki web data, data cleaning, building a SQL Server data warehouse, to Power BI dashboarding and insight reporting — supporting decision-making for a Category Manager in the Kitchen Appliances category.

> **Assumed Role:** Data Analyst supporting the Category Manager in optimizing pricing strategies, supplier negotiations, and marketing budget allocation.

---

## Business Problem

The Kitchen Appliances category on Tiki contains thousands of SKUs across many brands, with widely varying prices and discount levels. The Category Manager needs to answer: which price segments sell best, which brands/sellers lead the market, whether promotions are actually effective, which subcategories have assortment gaps, which products should be prioritized for marketing, and what customers are complaining about behind low ratings.

Full details: [`docs/business_requirements_eng.md`](docs/business_requirements_eng.md)
[`docs/business_question_eng.md`](docs/business_question_eng.md),
s

## Business Questions

| Group | Key Question |
|---|---|
| BQ1 - Pricing & Discount | Which price/discount segments sell best? At what discount level does the effect of additional discounting diminish? |
| BQ2 - Brand & Seller | Which brands/sellers hold market share? Which sellers have untapped potential? |
| BQ3 - Customer Perception | How does rating differ across price segments? Which products present quality risks? |
| BQ4 - Assortment | Which subcategories have assortment gaps in mainstream price segments? |
| BQ5 - Marketing Priority | Which products/brands should be prioritized for marketing? |
| BQ6 - Customer Voice | What are customers actually complaining about in negative reviews? |

---

## Data Pipeline
![Data Pipeline](/docs/images/tiki_data_pipeline.png)


**Star schema:** `dim_product`, `dim_brand`, `dim_subcategory`,
`dim_seller`, `dim_date` (role-playing) — `fact_product_metrics`,
`fact_reviews`.

![Data Pipeline](/docs/images/tiki_kitchen_appliances_dw.png)
---

## Project Structure

```
├── docs/                     # Business problem, requirements, dashboard design
├── data_collection/          # Crawler (product IDs, product detail, reviews)
├── data/
│   ├── raw/                     # Dữ liệu thô từ crawler
│   └── processed/                # products_cleaned.csv, reviews_cleaned.csv
├── data_cleaning/             # cleaning.ipynb + audit report
├── eda/                      # Exploratory analysis
├── analysis/                 # SQL answering each Business Question + BQ6 notebook
├── data_warehouse/            # SQL Server: staging → dimension → fact → view
├── dashboard/                 # Power BI file + screenshots
└── insights/                  # Final insights & recommendations report
```

---

## Tech Stack

- **Data Collection:** Python (`requests`, `pandas`), Tiki internal API
- **Cleaning & EDA:** Python (`pandas`, `numpy`, `matplotlib`), Jupyter
- **Text Analysis:** `underthesea` (Vietnamese tokenization), n-gram frequency + distinctiveness scoring
- **Data Warehouse:** SQL Server (star schema, T-SQL)
- **Visualization:** Power BI Desktop, DAX

---

## Key Insights

Full details by Business Question:
[`insights/Insights_Recommendations_v1.pdf`](insights/Insights_Recommendations_v1.pdf)

Selected highlights:

- **After-sales issues > product defects:** n-gram analysis of negative reviews shows that the most distinctive keywords (`trả`, `giải quyết`, `trả
  lại`, `thu hồi`) revolve around return/refund/complaint-handling processes rather than technical product defects — an issue that is difficult to identify by looking only at average ratings.
- **The seller market is overwhelmingly dominated by first-party channels**
  (Seller CR5 = 96.42%) - all third-party seller competition analyses are separated to prevent this concentration from masking differences among other sellers.
- **Discount saturation is clearly visible at 30–50%** - pushing discounts higher does not generate proportional sales growth.
- **41 SKUs are on the quality-risk watchlist** (review nhiều,
  rating thấp) - these should be prioritized because they may affect a large number of customers.

## Dashboard Preview

7 pages: Overview · Pricing & Discount · Brand & Seller · Customer
Perception · Assortment/Merchandising · Marketing Priority · Customer
Voice. Screenshots: [`dashboard/screenshots/`](dashboard/screenshots/).

---

## Notable Challenges (important when reading the code)

- **Hard API limit of 2,000 products/query** - handled by recursively splitting the crawl into smaller price ranges (crawl_product_ids.py) until each range falls below the safe threshold.
- **Detected incorrect `discount_rate`** values displayed by Tiki for 2 real products
  (`id 234`, `479`) - the product page reported a `0%` dù thực tế lệch
  tới 15.29 điểm %; detected by validating against
  `discount_rate_calc` trong `cleaning.ipynb`.
- **Fact-to-fact join in Power BI:** `Dim_Seller` không nối trực
  tiếp với `Fact_Reviews` - handled using `TREATAS` in DAX, while
  the model was redesigned so that `brand`/`subcategory` are stored in `Dim_Product` and shared across both fact tables instead of being duplicated in each fact table.
- **Incorrect alert threshold units:** the initial price discrepancy detection rule (> 5 percentage points) was more than 10 times looser than the actual rounding error in the source data - changed to 1.0 percentage points to detect genuine errors.

## Data Limitations & Assumptions

- The data is a **single-point-in-time snapshot**, not a time series.
- `subcategory_name` is a heuristic classification based on product-name keywords (15.44% of SKUs could not be classified), not Tiki's official taxonomy.
- Customer names in reviews were anonymized (hashed) before processing/publication.

Full details: [`docs/business_requirements.md`](00_docs/business_requirements.md#assumptions--limitations)

---

## How to Reproduce

```bash
git clone <repo-url>
cd tiki-kitchen-appliances-market-analytics
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env   # fill in TIKI_ACCESS_TOKEN, TIKI_GUEST_TOKEN, TIKI_TRACKITY_ID
```

1. **Crawl data:** run sequentially `data_collection/crawler/crawl_product_ids.py`
   → `crawl_product_data.py` → `crawl_comments.py`
2. **Clean data:** run `data_cleaning/cleaning.ipynb`
3. **Build the warehouse:** run `data_warehouse/load_csv_to_staging.py`,
   then execute the 3 `.sql` files in SQL Server Management Studio in sequence
4. **Open the dashboard:** `dashboard/*.pbix`, point Data source settings to your SQL Server instance, then Refresh

---

## 📄 Documentation

| File | Description |
|---|---|
| [`docs/business_requirements.md`](docs/business_requirements_eng.md) | Scope, stakeholder, success criteria |
| [`docs/business_question.md`](docs/business_question_eng.md) | Business problem + 6 question groups |
| [`docs/pdf/data_cleaning`](docs/pdf/data_cleaning.pdf) | Detailed data cleaning process |
| [`dashboard/dashboard_design.md`](dashboard/dashboard_design.md) | Design of each dashboard page |
| [`insights/Insights_Recommendations_v1.pdf`](insights/Insights_Recommendations_v1.pdf) | Final insights & recommendations |
