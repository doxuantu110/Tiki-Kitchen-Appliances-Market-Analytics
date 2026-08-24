USE tiki_dw;

CREATE VIEW vw_product_full AS
SELECT
    f.*, dp.product_name, dp.sku,
    b.brand_name, sc.subcategory_name, s.seller_name
FROM fact_product_metrics f
JOIN dim_product dp ON f.product_key = dp.product_key
LEFT JOIN dim_brand b ON dp.brand_id = b.brand_id
LEFT JOIN dim_subcategory sc ON dp.subcategory_id = sc.subcategory_id
LEFT JOIN dim_seller s ON f.seller_id = s.seller_id;

CREATE VIEW vw_review_full AS
SELECT
    fr.comment_id,
    dp.product_name,
    dp.sku,
    b.brand_name,
    sc.subcategory_name,
    fr.rating,
    CASE WHEN fr.rating <= 2 THEN 1 ELSE 0 END AS is_negative_review,
    fr.content,
    fr.thank_count,
    fr.customer_name_hash,
    fr.has_content,
    fr.created_at,
    cd.year        AS created_year,
    cd.quarter     AS created_quarter,
    cd.month       AS created_month,
    fr.purchased_at,
    pd.year        AS purchased_year,
    pd.month       AS purchased_month
FROM fact_reviews fr
JOIN dim_product dp ON fr.product_key = dp.product_key
LEFT JOIN dim_brand b ON dp.brand_id = b.brand_id
LEFT JOIN dim_subcategory sc ON dp.subcategory_id = sc.subcategory_id
LEFT JOIN dim_date cd ON fr.created_date_key = cd.date_key
LEFT JOIN dim_date pd ON fr.purchased_date_key = pd.date_key;

