USE tiki_dw;

-- create dimension tables
CREATE TABLE dim_brand(
	brand_id INT IDENTITY(1,1) PRIMARY KEY,
	brand_name NVARCHAR(255),
	brand_slug VARCHAR(255)
);

CREATE TABLE dim_subcategory (
    subcategory_id INT IDENTITY(1,1) PRIMARY KEY,
    subcategory_name NVARCHAR(255) NOT NULL
);

CREATE TABLE dim_seller (
    seller_id BIGINT PRIMARY KEY,
    seller_name NVARCHAR(255),
    seller_store BIGINT
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT,
	quarter INT,
	month INT,
	week INT,
    day_of_week NVARCHAR(20)
);

CREATE TABLE dim_product (
	product_key INT IDENTITY(1,1) PRIMARY KEY,
	id BIGINT NOT NULL,
	sku VARCHAR(100),
	product_name NVARCHAR(500),
	brand_id INT,
	subcategory_id INT
)
ALTER TABLE dim_product ADD CONSTRAINT fk_product_brand FOREIGN KEY (brand_id) REFERENCES dim_brand(brand_id);
ALTER TABLE dim_product ADD CONSTRAINT fk_product_subcategory FOREIGN KEY (subcategory_id) REFERENCES dim_subcategory(subcategory_id);

-- create fact tables
CREATE TABLE fact_product_metrics(
	product_metrics_key INT IDENTITY(1,1) PRIMARY KEY,
    product_key INT FOREIGN KEY REFERENCES dim_product(product_key),
    seller_id BIGINT FOREIGN KEY REFERENCES dim_seller(seller_id),
    snapshot_date_key INT FOREIGN KEY REFERENCES dim_date(date_key),
    price DECIMAL(18,0),
    original_price DECIMAL(18,0),
    discount INT,
    discount_rate FLOAT,
    rating_average DECIMAL(2,1),
    review_count INT,
    quantity_sold_value INT,
    has_sold BIT,
    inventory_status VARCHAR(50),
    inventory_type VARCHAR(50),
    possibly_delisted BIT,
    discount_rate_calc FLOAT,
    discount_rate_mismatch BIT,
    price_bucket NVARCHAR(50),
    discount_bucket NVARCHAR(50),
    crawled_review_count INT
);

CREATE TABLE fact_reviews (
    comment_id BIGINT PRIMARY KEY,
    product_key INT FOREIGN KEY REFERENCES dim_product(product_key),
    content NVARCHAR(MAX),
    rating INT,
    thank_count INT,
    customer_name_hash VARCHAR(255),
    purchased_date_key INT FOREIGN KEY REFERENCES dim_date(date_key),
    created_date_key INT FOREIGN KEY REFERENCES dim_date(date_key),
    purchased_at DATETIME2(0),
    created_at DATETIME2(0),
    has_content BIT
);

