USE tiki_dw;

-- BUSINESS QUESTION

-- B. BRAND / SELLER ANALYSIS
-- 3. Top thương hiệu / seller nào chiếm thị phần lớn nhất (theo số lượng bán) trong dataset?
SELECT TOP 10 brand_name, sum(quantity_sold_value) as total_sold_value, count(fp.product_key) as product_count, 
			avg(fp.rating_average) as avg_rating, SUM(fp.quantity_sold_value) * 100.0/ SUM(SUM(fp.quantity_sold_value)) OVER ()
        AS market_share_pct
FROM dim_brand b 
JOIN dim_product p on b.brand_id = p.brand_id
JOIN fact_product_metrics fp on p.product_key = fp.product_key
GROUP BY brand_name
ORDER BY market_share_pct desc;

-- Toàn thị trường
SELECT TOP 10 seller_name, sum(quantity_sold_value) as total_sold_value, 
			count(fp.product_key) as product_count, 
			avg(fp.rating_average) as avg_rating, SUM(fp.quantity_sold_value) * 100.0/ SUM(SUM(fp.quantity_sold_value)) OVER ()
        AS market_share_pct
FROM dim_seller s 
JOIN fact_product_metrics fp on s.seller_id = fp.seller_id
GROUP BY seller_name
ORDER BY market_share_pct desc;

-- Không tính Seller là Tiki Trading 
SELECT TOP 10 seller_name, sum(quantity_sold_value) as total_sold_value, count(fp.product_key) as product_count, 
			avg(fp.rating_average) as avg_rating, SUM(fp.quantity_sold_value) * 100.0/ SUM(SUM(fp.quantity_sold_value)) OVER ()
        AS market_share_pct
FROM dim_seller s 
JOIN fact_product_metrics fp on s.seller_id = fp.seller_id
WHERE seller_name <> 'Tiki Trading'
GROUP BY seller_name
ORDER BY market_share_pct desc;

-- 4. Seller nào có rating cao nhưng volume thấp -> tiềm năng chưa được khai thác.
SELECT seller_name, AVG(fp.rating_average) AS avg_rating,
    SUM(fp.quantity_sold_value) AS total_units_sold,
    COUNT(fp.product_key) AS product_count
FROM dim_seller s
JOIN fact_product_metrics fp
    ON s.seller_id = fp.seller_id
WHERE fp.rating_average > 0
GROUP BY s.seller_name
HAVING AVG(fp.rating_average) >= 4.5 AND SUM(fp.quantity_sold_value) <= 50
ORDER BY total_units_sold;