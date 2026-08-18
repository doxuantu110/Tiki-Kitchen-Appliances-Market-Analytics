# Business Requirements - Tiki Kitchen Appliances Market Analytics

## 1. Project Overview

This project analyzes the Kitchen Appliances category on Tiki to provide data-driven insights for decision-making related to pricing, promotions, brand/seller partnerships, and marketing prioritization.

For detailed business problems and the complete list of business questions, please refer to `business_question.md`.

## 2. Stakeholder (Assumed)

**Category Manager — Kitchen Appliances, Tiki**

The Category Manager is responsible for making decisions regarding:

- Pricing strategies across different product segments.
- Negotiating terms and partnerships with brands and sellers.
- Allocating quarterly marketing budgets.

## 3. Business Objectives

- Identify price segments and discount levels associated with stronger sales performance.
- Identify leading brands and sellers, as well as potentially underexploited sellers with growth opportunities.
- Detect products and brands with potential quality risks for early warning.
- Identify gaps in the product assortment.
- Recommend priority products and brands for upcoming marketing campaigns.
- Understand the actual customer feedback behind low product ratings.

## 4. Scope
- Publicly available product and review data from Tiki's Kitchen Appliances category (Category ID: `1884`).
- Descriptive analysis, including distributions, correlations, and KPIs by relevant groups.
- Basic text analysis of review content, including keyword extraction and word-frequency analysis.
- A visualization dashboard providing relevant KPIs and insights for the Category Manager.

## 5. Data Requirements

| Dataset | Source | Primary Purpose |
|---|---|---|
| `products_cleaned.csv` | Crawled from the Tiki API (`v2/products/{id}`) | Pricing, Discount, Brand/Seller, Rating, and Assortment analysis |
| `reviews_cleaned.csv` | Crawled from the Tiki API (`v2/reviews`) | Customer Voice analysis and review count validation |

For details on data collection and cleaning procedures, please refer to `data_collection/` and `data_cleaning/`.

## 6. Deliverables

1. Cleaned datasets (`data/processed/`).
2. EDA notebooks and KPI calculations (`eda/`, `analysis/`).
3. A Power BI dashboard covering the business questions defined in `business_question.md`.
4. An Insights & Recommendations report (`insights/`).

## 7. Success Criteria

- Each Business Question (BQ1–BQ6) is supported by at least one KPI and one corresponding visualization on the dashboard.
- Every reported insight is supported by quantitative evidence and includes a specific actionable recommendation rather than merely describing the observed data.

## 8. Assumptions & Limitations

- **Sub-category (`subcategory_proxy`)** is inferred from keywords in product names rather than obtained from Tiki's official category hierarchy. Therefore, findings related to BQ4 are estimates and should not be interpreted as completely accurate official category-level figures.
- **`review_count`** displayed on a product page may differ from the actual number of reviews collected during the crawling process (`crawled_review_count`). Therefore, the analysis prioritizes the actual crawled review count where applicable.
- Reviews are collected only for products with `review_count > 0` at the time of crawling. Reviews added after the crawling process are not captured. Therefore, the dataset represents a snapshot of the market at a specific point in time rather than real-time data.
- Customer names in reviews are anonymized before processing and publication to protect personal data.