USE tiki_dw;

-- load dimensions
-- dim_date: tự sinh

WITH DateRange AS (
	SELECT CAST('2014-01-01' AS DATE) AS full_date
	UNION ALL
	SELECT DATEADD(DAY, 1, full_date) FROM DateRange
	WHERE full_date < '2030-12-31'
)

INSERT INTO dim_date(date_key, full_date, year, quarter, month, week, day_of_week)
SELECT
    CONVERT(INT, FORMAT(full_date, 'yyyyMMdd')),
    full_date, YEAR(full_date), DATEPART(QUARTER, full_date),
    MONTH(full_date), DATEPART(WEEK, full_date), DATENAME(WEEKDAY, full_date)
FROM DateRange
OPTION (MAXRECURSION 0);

-- dim_brand: distinct từ staging
INSERT INTO dim_brand (brand_name, brand_slug)
SELECT DISTINCT brand_name, brand_slug
FROM stg_products
WHERE brand_name IS NOT NULL;

-- dim_subcategory
INSERT INTO dim_subcategory (subcategory_name)
SELECT DISTINCT subcategory_proxy
FROM stg_products
WHERE subcategory_proxy IS NOT NULL;

-- dim_seller
INSERT INTO dim_seller (seller_id, seller_name, seller_store)
SELECT DISTINCT seller_id, seller_name, seller_store
FROM stg_products
WHERE seller_id IS NOT NULL;

-- dim_product: load SAU CÙNG, vì cần tra cứu surrogate key brand_id/subcategory_id
INSERT INTO dim_product (id, sku, product_name, brand_id, subcategory_id)
SELECT
    p.id, p.sku, p.product_name,
    b.brand_id,
    sc.subcategory_id
FROM stg_products p
LEFT JOIN dim_brand b ON p.brand_name = b.brand_name
LEFT JOIN dim_subcategory sc ON p.subcategory_proxy = sc.subcategory_name;

-- load fact tables
-- fact_product_metrics
INSERT INTO fact_product_metrics (
    product_key, seller_id, snapshot_date_key, price, original_price, discount,
    discount_rate, rating_average, review_count, quantity_sold_value,
    has_sold, inventory_status, inventory_type, possibly_delisted,
    discount_rate_calc, discount_rate_mismatch, price_bucket,
    discount_bucket, crawled_review_count
)
SELECT
    dp.product_key, p.seller_id, 
	CONVERT(INT, FORMAT(p.snapshot_date, 'yyyyMMdd')),
	p.price, p.original_price,
    p.discount, p.discount_rate, p.rating_average, p.review_count,
    p.quantity_sold_value,
    CASE WHEN p.has_sold = 'True' THEN 1 ELSE 0 END,
    p.inventory_status, p.inventory_type,
    CASE WHEN p.possibly_delisted = 'True' THEN 1 ELSE 0 END,
    p.discount_rate_calc,
    CASE WHEN p.discount_rate_mismatch = 'True' THEN 1 ELSE 0 END,
    p.price_bucket, p.discount_bucket, p.crawled_review_count
FROM stg_products p
JOIN dim_product dp ON p.id = dp.id;


-- fact_reviews
INSERT INTO fact_reviews (
    comment_id, product_key, content, rating, thank_count,
    customer_name_hash, purchased_date_key, created_date_key,
    purchased_at, created_at, has_content
)
SELECT
    r.comment_id, dp.product_key, r.content, r.rating, r.thank_count,
    r.customer_name_hash,
    CONVERT(INT, FORMAT(r.purchased_at, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(r.created_at, 'yyyyMMdd')),
    r.purchased_at, r.created_at,
    CASE WHEN LOWER(LTRIM(RTRIM(r.has_content))) LIKE '%true%' THEN 1 ELSE 0 END
FROM stg_reviews r
JOIN dim_product dp ON r.product_id = dp.id;

