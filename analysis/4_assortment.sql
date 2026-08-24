USE tiki_dw;

-- BUSINESS QUESTION

-- D. ASSORTMENT / MERCHANDISING
-- 7. Danh mục con nào đang thiếu hàng ở phân khúc giá phổ thông (gap in assortment).
SELECT
    s.subcategory_name,
    COUNT(fp.product_key) AS product_count,
    SUM(fp.quantity_sold_value) AS total_units_sold,
    CAST(SUM(fp.quantity_sold_value) * 1.0
        / NULLIF(COUNT(fp.product_key), 0) AS DECIMAL(18,2)
    ) AS units_per_sku
FROM dim_subcategory s
JOIN dim_product p on s.subcategory_id = p.subcategory_id
JOIN fact_product_metrics fp on p.product_key = fp.product_key
WHERE fp.price_bucket IN ('<100K', '100-300K')
GROUP BY s.subcategory_name
ORDER BY units_per_sku desc;
