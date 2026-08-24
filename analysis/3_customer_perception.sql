USE tiki_dw;

-- BUSINESS QUESTION

-- C. CUSTOMER PERCEPTION
-- 5. Rating trung bình theo phân khúc giá có sự khác biệt không?
SELECT price_bucket, round(avg(rating_average), 2) as avg_rating
FROM fact_product_metrics
WHERE rating_average <> 0
GROUP BY price_bucket
ORDER BY avg_rating;

-- Tạo view vw_quanlity_risk_products để vụ phụ cho các câu truy vấn sau
CREATE VIEW vw_quality_risk_products AS
SELECT vp.*
FROM vw_product_full vp
WHERE vp.review_count >= (
    SELECT TOP 1 PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY review_count)
    OVER ()
    FROM fact_product_metrics
)
AND vp.rating_average < 3.5;

-- 6. Sản phẩm nào có review count cao nhưng rating thấp? rủi ro chất lượng cảnh báo.
SELECT TOP 10 p.product_name, fp.crawled_review_count, fp.rating_average, fp.quantity_sold_value
FROM vw_quality_risk_products v
JOIN dim_product p on v.product_key = p.product_key
JOIN fact_product_metrics fp on p.product_key = fp.product_key
ORDER BY fp.crawled_review_count desc;
