# Business Questions — Tiki Kitchen Appliances Market Analytics

## 1. Business Problem

The Kitchen Appliances category on Tiki contains thousands of SKUs across a wide range of brands, prices, and discount levels. The Category Manager needs to understand:

- Which price segments have the highest sales performance?
- Which brands and sellers have the strongest market presence?
- Is the level of discount actually associated with sales volume and customer ratings? If so, to what extent?
- Which types of products are underrepresented in popular price segments?
- Which products, brands, or sellers should be prioritized for upcoming marketing campaigns?
- What are customers actually complaining about behind low product ratings?

**→ Objective:** Optimize pricing strategies, improve supplier and seller negotiations, and allocate the marketing budget more effectively for the upcoming quarter.

---

## 2. Business Questions

Each question is assigned a unique Business Question (BQ) code for consistent reference throughout the EDA, KPI analysis, and dashboard development.

### Group 1 — Pricing & Discount

*Primary data source: `products_cleaned.csv`*

| Code | Business Question |
|---|---|
| BQ1.1 | Which price segments have the highest SKU count and sales volume? |
| BQ1.2 | Is the discount rate associated with the number of units sold? At what discount level does the effect appear to diminish? |

### Group 2 — Brand/Seller

*Primary data source: `products_cleaned.csv`*

| Code | Business Question |
|---|---|
| BQ2.1 | Which brands and sellers have the largest market share in the dataset based on units sold? |
| BQ2.2 | Which sellers have high customer ratings but low sales volume, indicating potential growth opportunities? |

### Group 3 — Customer Perception

*Primary data source: `products_cleaned.csv`*

| Code | Business Question |
|---|---|
| BQ3.1 | Does average product rating differ across price segments? |
| BQ3.2 | Which products have a high review count but low ratings, indicating potential quality risks that require attention? |

### Group 4 — Assortment/Merchandising

*Primary data source: `products_cleaned.csv` (`subcategory_proxy` field)*

| Code | Business Question |
|---|---|
| BQ4.1 | Which subcategories are underrepresented in popular price segments, indicating potential assortment gaps? |

> **Note:** `subcategory_proxy` is a heuristic classification based on keywords in product names rather than Tiki's official product taxonomy. Therefore, findings from this group should be treated as estimates, and this limitation should be clearly stated when presenting the results.

### Group 5 — Marketing Assortment

*Primary data source: `products_cleaned.csv`*

| Code | Business Question |
|---|---|
| BQ5.1 | Which products, brands, or sellers have the strongest combination of sales volume, customer ratings, and promotional attractiveness, making them suitable priorities for upcoming marketing campaigns? |

### Group 6 — Customer Voice

*Primary data source: `reviews_cleaned.csv` (`content` field, filtered by `has_content = True`)*

| Code | Business Question |
|---|---|
| BQ6.1 | Which keywords or topics appear most frequently in negative reviews (rating ≤ 2)? |
| BQ6.2 | Among products on the "quality risk watchlist" identified in BQ3.2, what are customers actually complaining about in their review comments? |

---

## 3. Cross-Reference

- For detailed business requirements, including project scope, constraints, assumptions, and success criteria, refer to `business_requirements.md`.