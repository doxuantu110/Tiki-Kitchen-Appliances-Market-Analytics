USE tiki_dw;

-- 1. Số dòng phải khớp staging <-> fact
SELECT
    (SELECT COUNT(*) FROM stg_products) AS staging_count,
    (SELECT COUNT(*) FROM fact_product_metrics) AS fact_count;

SELECT
    (SELECT COUNT(*) FROM stg_reviews) AS staging_count,
    (SELECT COUNT(*) FROM fact_reviews) AS fact_count;

-- 2. possibly_delisted phải đúng 8 (số đã biết từ cleaning)
SELECT COUNT(*) AS possibly_delisted_count
FROM fact_product_metrics WHERE possibly_delisted = 1;

-- 3. discount_rate_mismatch phải đúng 2 (id 234, 479)
SELECT COUNT(*) AS mismatch_count
FROM fact_product_metrics WHERE discount_rate_mismatch = 1;

-- 4. Orphan check: fact có product_key không tồn tại trong dim_product?
SELECT COUNT(*) AS orphan_facts
FROM fact_product_metrics f
LEFT JOIN dim_product dp ON f.product_key = dp.product_key
WHERE dp.product_key IS NULL;