USE tiki_dw;

-- BUSINESS QUESTION
-- A. PRICING & DISCOUNT
-- 1. Phân khúc giá nào có mật độ sản phẩm và số lượng bán cao nhất ?
SELECT price_bucket, count(*) as product_count, sum(quantity_sold_value) as total_units_sold, AVG(quantity_sold_value) AS avg_units_sold
FROM fact_product_metrics
GROUP BY price_bucket
ORDER BY sum(quantity_sold_value) desc;

-- 2. Mức giảm giá có tương quan với số lượng sản phẩm bán hay không? Tới ngưỡng nào thì hết hiệu lực.
SELECT discount_bucket, count(*) as product_count, sum(quantity_sold_value) as total_units_sold, AVG(quantity_sold_value) AS avg_units_sold
FROM fact_product_metrics
GROUP BY discount_bucket
ORDER BY sum(quantity_sold_value) desc;