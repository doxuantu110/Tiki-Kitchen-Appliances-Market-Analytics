USE tiki_dw;

-- BUSINESS QUESTION

-- D. 
-- 8. Sản phẩm hay thương hiệu/seller nào có sự kết hợp mạnh nhất về số lượng bán, 
-- đánh giá khách hàng và sức hấp dẫn của các chương trình khuyến mãi cho chiến dịch marketing tương lai?

-- Xác định: Marketing Score = 40% Sales Score + 30% Rating Score + 30% Discount Score
-- Do giá trị của quantity_sold_value rất lớn và sẽ áp đảo hoàn toàn 2 giá trị kia -> normalize giá trị log.
-- và Normalize về 0–100 bằng cách sử dụng Min-Max normalization: Score = [(value - min) / (max - min)] × 100

-- a. SẢN PHẨM có sự kết hợp mạnh về số lượng bán + đánh giá + chương trình giảm giá
-- Lấy dữ liệu cần thiết
WITH ProductMetrics AS (
    SELECT fp.product_key, p.product_name, fp.quantity_sold_value, fp.rating_average, fp.discount_rate,
	LOG(1.0 + quantity_sold_value)
    FROM fact_product_metrics fp
    JOIN dim_product p on fp.product_key = p.product_key
    WHERE fp.quantity_sold_value IS NOT NULL
      AND fp.rating_average IS NOT NULL
      AND fp.rating_average > 0
      AND fp.discount_rate IS NOT NULL
),
-- tính min/max
MinMax AS (
    SELECT
        MIN(quantity_sold_value) AS min_sales,
        MAX(quantity_sold_value) AS max_sales,

        MIN(rating_average) AS min_rating,
        MAX(rating_average) AS max_rating,

        MIN(discount_rate) AS min_discount,
        MAX(discount_rate) AS max_discount
    FROM ProductMetrics
),
-- tính từng score
Scores AS (
    SELECT pm.*,
        (
            (quantity_sold_value - mm.min_sales) * 100.0
            / NULLIF(mm.max_sales - mm.min_sales, 0)
        ) AS sales_score,
        (
            (rating_average - mm.min_rating) * 100.0
            / NULLIF(mm.max_rating - mm.min_rating, 0)
        ) AS rating_score,
        (
            (discount_rate - mm.min_discount) * 100.0
            / NULLIF(mm.max_discount - mm.min_discount, 0)
        ) AS discount_score
    FROM ProductMetrics pm
    CROSS JOIN MinMax mm
),
-- tính Marketing Opportunity Score
MarketingScore AS (
    SELECT *, ( 0.4 * sales_score + 0.3 * rating_score + 0.3 * discount_score) AS marketing_score
    FROM Scores
)
SELECT TOP 20 product_key, product_name, quantity_sold_value, rating_average, discount_rate,
    round(sales_score, 2) AS sales_score,
    round(rating_score, 2) AS rating_score,
    round(discount_score, 2) AS discount_score,
    round(marketing_score, 2) AS marketing_score
FROM MarketingScore
ORDER BY marketing_score desc;

-- b. THƯƠNG HIỆU có sự kết hợp mạnh về số lượng bán + đánh giá + chương trình giảm giá
-- Lấy dữ liệu cần thiết
WITH ProductMetrics AS (
    SELECT fp.product_key, p.product_name, fp.quantity_sold_value, fp.rating_average, fp.discount_rate
    FROM fact_product_metrics fp
    JOIN dim_product p on fp.product_key = p.product_key
    WHERE fp.quantity_sold_value IS NOT NULL
      AND fp.rating_average IS NOT NULL
      AND fp.rating_average > 0
      AND fp.discount_rate IS NOT NULL
),
-- tính min/max
MinMax AS (
    SELECT
        MIN(quantity_sold_value) AS min_sales,
        MAX(quantity_sold_value) AS max_sales,

        MIN(rating_average) AS min_rating,
        MAX(rating_average) AS max_rating,

        MIN(discount_rate) AS min_discount,
        MAX(discount_rate) AS max_discount
    FROM ProductMetrics
),
-- tính từng score
Scores AS (
    SELECT pm.*,
        (
            (quantity_sold_value - mm.min_sales) * 100.0
            / NULLIF(mm.max_sales - mm.min_sales, 0)
        ) AS sales_score,
        (
            (rating_average - mm.min_rating) * 100.0
            / NULLIF(mm.max_rating - mm.min_rating, 0)
        ) AS rating_score,
        (
            (discount_rate - mm.min_discount) * 100.0
            / NULLIF(mm.max_discount - mm.min_discount, 0)
        ) AS discount_score
    FROM ProductMetrics pm
    CROSS JOIN MinMax mm
),
-- tính Marketing Opportunity Score
MarketingScore AS (
    SELECT *, ( 0.4 * sales_score + 0.3 * rating_score + 0.3 * discount_score) AS marketing_score
    FROM Scores
)
SELECT TOP 20 brand_name, quantity_sold_value, rating_average, discount_rate,
    round(sales_score, 2) AS sales_score,
    round(rating_score, 2) AS rating_score,
    round(discount_score, 2) AS discount_score,
    round(marketing_score, 2) AS marketing_score
FROM MarketingScore ms
JOIN dim_product p
    ON ms.product_key = p.product_key
JOIN dim_brand b
    ON p.brand_id = b.brand_id
ORDER BY marketing_score desc;
