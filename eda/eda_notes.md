
EDA Summary Notes
==================
- 57.7% of SKUs have at least one recorded sale.
- 31.9% of SKUs are currently discounted; average discount
  among discounted SKUs is 30.8%.
- 41 products flagged on the quality-risk watchlist
  (top-quartile review volume, rating < 3.5).
- 366 high-price products (top price quartile) show
  zero recorded sales — worth checking for pricing or listing issues.
- category_name is constant (top-level only) in this dataset — BQ5
  (sub-category assortment gap) uses a keyword-based proxy
  (subcategory_proxy) as an interim workaround; recommend re-crawling
  breadcrumbs for a production-grade version.
