# Data Quality Report

## Dataset Overview

| Dataset | Rows | Unique IDs |
|---|---:|---:|
| Product IDs | 2,001 | 2,001 |
| Products | 2,001 | 2,001 |
| Reviews | 48,649 | 48,649 (comment_id) |

## Quality Findings

### Product Data

- No duplicate product IDs were found (0/2,001).
- All 2,001 product IDs from the discovery stage were successfully matched
  to product detail records (0 missing, 0 unexpected).
- `meta_title` is 100% missing (0/2,001 non-null).
- `quantity_sold_value` / `all_time_quantity_sold` are missing for ~851/847
  records (~42.5%) — this reflects products with no recorded sales, not a
  data error.
- `stock_item_qty`, `seller_id`, `seller_name`, `category_id` etc. are
  missing for 8 records — likely products that became unavailable/delisted
  between crawl steps.
- No invalid values found for price, list_price, original_price,
  discount_rate, or rating_average (all checks returned 0 invalid records).
- `original_price >= price` holds for all 2,001 records (0 logic errors).

### Review Data

- Reviews were collected for 655 products (`review_count > 0` in product
  data).
- 48,649 review records were collected in total.
- No invalid review ratings found (all within 1-5 range).
- **Known discrepancy:** `review_count` (declared on product page) and
  the actual number of reviews crawled (`crawled_review_count`) do not
  always match. Most products show a small, expected gap (crawl happened
  after the product-count snapshot), but at least one product
  (`id 392842`) shows a large mismatch (declared: 3, crawled: 170) -
  likely due to product variants sharing a review pool. This needs
  further investigation before deciding which count to trust for
  review-based KPIs (recommendation: trust `crawled_review_count` as the
  ground truth, since it reflects actual scraped data).

### Validity Issues

- 0 products have invalid price values.
- 0 products have invalid discount values.
- 0 products have invalid rating values.
- 0 products have invalid review_count or quantity_sold values.


## Action Plan

The following issues will be addressed during data cleaning:

1. Drop `meta_title` (100% missing, no analytical value).
2. Standardize numeric fields (already validated as clean; no coercion
   needed beyond dtype checks).
3. Handle missing values based on business meaning:
   - `quantity_sold_value` missing -> treat as "no recorded sales"
     (`has_sold = False`), not imputed as 0 blindly without a flag.
   - `seller_id`/`category_id` missing (8 records) -> flag as
     `possibly_delisted`, review manually before deciding to drop.
4. Validate price and discount relationships (already confirmed clean;
   re-run after cleaning as a regression check).
5. Standardize brand and seller names (trim whitespace, casing).
6. Create analytical price segments (`price_bucket`) and discount
   segments (`discount_bucket`) for KPI/EDA use.
7. Investigate the `review_count` vs `crawled_review_count` mismatch
   pattern before finalizing which field drives review-based KPIs.