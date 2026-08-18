import os
import time
import random

import pandas as pd
import requests
from tqdm import tqdm
from dotenv import load_dotenv

load_dotenv()

# Configuration

INPUT_FILE = "product_ids.csv"
OUTPUT_FILE = "crawled_product_data.csv"
BASE_URL = "https://tiki.vn/api/v2/products"
TIKI_ACCESS_TOKEN = os.getenv("TIKI_ACCESS_TOKEN")
TIKI_TRACKITY_ID = os.getenv("TIKI_TRACKITY_ID")

headers = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/151.0.0.0 Safari/537.36"
    ),
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7",
    "Referer": "https://tiki.vn/",
}

if TIKI_ACCESS_TOKEN:
    headers["x-access-token"] = TIKI_ACCESS_TOKEN

# Parser
def parser_product(product):
    brand = product.get("brand") or {}
    current_seller = product.get("current_seller") or {}
    categories = product.get("categories") or {}
    quantity_sold = product.get("quantity_sold") or {}
    stock_item = product.get("stock_item") or {}
    return {
        "id": product.get("id"),
        "sku": product.get("sku"),
        "product_name": product.get("name"),
        "meta_title": product.get("meta_title"),
        "short_description": product.get("short_description"),

        # ---- Pricing ----
        "price": product.get("price"),
        "list_price": product.get("list_price"),
        "original_price": product.get("original_price"),  # fallback đáng tin hơn list_price
        "discount": product.get("discount"),
        "discount_rate": product.get("discount_rate"),

        # ---- Rating & Sales ----
        "rating_average": product.get("rating_average"),
        "review_count": product.get("review_count"),
        "quantity_sold_text": quantity_sold.get("text"),
        "quantity_sold_value": quantity_sold.get("value"),
        "all_time_quantity_sold": product.get("all_time_quantity_sold"),

        # ---- Inventory ----
        "inventory_status": product.get("inventory_status"),
        "inventory_type": product.get("inventory_type"),
        "stock_item_qty": stock_item.get("qty"),
        "stock_item_min_sale_qty": stock_item.get("min_sale_qty"),
        "stock_item_max_sale_qty": stock_item.get("max_sale_qty"),

        # ---- Brand ----
        "brand_id": brand.get("id"),
        "brand_name": brand.get("name"),
        "brand_slug": brand.get("slug"),

        # ---- Seller ----
        "seller_id": current_seller.get("id"),
        "seller_name": current_seller.get("name"),
        "seller_store_id": current_seller.get("store_id"),
        "seller_price": current_seller.get("price"),  # giá cụ thể của seller này (có thể khác price gốc nếu nhiều seller)
        "seller_is_best_store": current_seller.get("is_best_store"),

        # ---- Category ----
        "category_id": categories.get("id"),
        "category_name": categories.get("name"),
    }

# Load Product IDs
df_id = pd.read_csv(INPUT_FILE)
p_ids = (
    df_id["product_id"]
    .dropna()
    .astype(int)
    .drop_duplicates()
    .tolist()
)
print(f"Total product IDs: {len(p_ids)}")

# Crawl
result = []
failed_ids = []

with requests.Session() as session:
    session.headers.update(headers)
    for pid in tqdm(p_ids):
        url = f"{BASE_URL}/{pid}"
        success = False
        for attempt in range(3):
            try:
                response = session.get(url,
                    params={
                        "platform": "web"
                    },
                    timeout=30,
                )

                if response.status_code == 200:
                    product = response.json()
                    result.append(parser_product(product))
                    success = True
                    break
                elif response.status_code in {429,500,502,503,504,}:
                    time.sleep(
                        5 * (attempt + 1)
                    )
                else:
                    print(
                        f"Failed {pid}: "
                        f"{response.status_code}"
                    )
                    break

            except requests.RequestException as e:
                if attempt == 2:
                    print(
                        f"Request failed {pid}: {e}"
                    )
                time.sleep(5 * (attempt + 1))

        if not success:
            failed_ids.append(pid)

        # Random delay
        time.sleep(random.uniform(2, 4))

# Save
df_product = pd.DataFrame(result)
df_product.to_csv(
    OUTPUT_FILE,
    index=False,
    encoding="utf-8-sig",
)
print()
print("Crawling completed.")
print(f"Success: {len(result)}")
print(f"Failed: {len(failed_ids)}")
print(f"Saved to: {OUTPUT_FILE}")