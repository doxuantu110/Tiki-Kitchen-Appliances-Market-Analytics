CREATE DATABASE tiki_dw;
USE tiki_dw;

-- create staging
CREATE TABLE stg_products(
    id BIGINT,
    sku VARCHAR(100),
    product_name NVARCHAR(MAX),
    price FLOAT,
    original_price FLOAT,
    discount FLOAT,
    discount_rate FLOAT,
    rating_average FLOAT,
    review_count FLOAT,
    quantity_sold_value FLOAT,
    inventory_status VARCHAR(50),
    inventory_type VARCHAR(50),
    brand_id BIGINT,
    brand_name NVARCHAR(255),
    brand_slug VARCHAR(255),
    seller_id FLOAT,
    seller_name NVARCHAR(255),
    seller_store FLOAT,
    category_id FLOAT,
    category_name NVARCHAR(255),
    snapshot_date DATE,
    has_sold VARCHAR(10),
    quantity_sold_value_filled FLOAT,
    possibly_delisted VARCHAR(10),
    reference_price FLOAT,
    discount_rate_calc FLOAT,
    discount_rate_diff FLOAT,
    discount_rate_mismatch VARCHAR(10),
    price_bucket NVARCHAR(50),
    discount_bucket NVARCHAR(50),
    subcategory_proxy NVARCHAR(255),
    crawled_review_count FLOAT
)

CREATE TABLE stg_reviews(
	comment_id BIGINT,
	product_id BIGINT,
	title NVARCHAR(MAX),
	content NVARCHAR(MAX),
	rating INT,
	thank_count INT,
	customer_id BIGINT,
	customer_name_hash VARCHAR(255),
	purchased_at DATETIME2,
	created_at DATETIME2,
	has_content VARCHAR(10)
)

-- Insert Data
BULK INSERT dbo.stg_products
FROM 'D:\WorkSpace\Tiki-Kitchen-Appliances-Market-Analytics\data\processed\products_cleaned.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT dbo.stg_reviews
FROM 'D:\WorkSpace\Tiki-Kitchen-Appliances-Market-Analytics\data\processed\reviews_cleaned.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);

SELECT COLUMN_NAME, DATA_TYPE, DATETIME_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'stg_reviews'
  AND COLUMN_NAME IN ('purchased_at', 'created_at');

-- type casting for datetime type columns
ALTER TABLE stg_reviews
ALTER COLUMN purchased_at DATETIME2(0);

ALTER TABLE stg_reviews
ALTER COLUMN created_at DATETIME2(0);


