USE tiki_dw;

-- BUSINESS QUESTION
-- F. Customer Voice 

-- 9. Những từ khóachủ đề nào xuất hiện nhiều trong các đánh giá tiêu cực (rating=2) 
SELECT
    SUM(CASE WHEN LOWER(content) LIKE N'%không nóng%' THEN 1 ELSE 0 END) AS heating_problem,
    SUM(CASE WHEN LOWER(content) LIKE N'%không hoạt động%' THEN 1 ELSE 0 END) AS product_failure,
    SUM(CASE WHEN LOWER(content) LIKE N'%hỏng%' THEN 1 ELSE 0 END) AS broken,
    SUM(CASE WHEN LOWER(content) LIKE N'%ồn%' THEN 1 ELSE 0 END) AS noisy,
    SUM(CASE WHEN LOWER(content) LIKE N'%giao hàng%' THEN 1 ELSE 0 END) AS delivery,
    SUM(CASE WHEN LOWER(content) LIKE N'%đóng gói%' THEN 1 ELSE 0 END) AS packaging
FROM fact_reviews
WHERE rating <= 2
  AND content IS NOT NULL;

-- 10. Trong nhóm sản phẩm nằm trong watchlist rủi ro chất lượng, nội dung comment thực sự phàn nàn về điều gì
SELECT p.product_name, r.comment_id, r.rating, r.content
FROM vw_quality_risk_products v
JOIN dim_product p ON v.product_key = p.product_key
JOIN fact_reviews r ON v.product_key = r.product_key
WHERE r.rating <= 2 AND r.content IS NOT NULL AND LTRIM(RTRIM(r.content)) <> ''
ORDER BY p.product_name, r.rating;