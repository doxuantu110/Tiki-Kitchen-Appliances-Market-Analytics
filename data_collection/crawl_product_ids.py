import os
import time
import random
import pandas as pd
import requests
from dotenv import load_dotenv


load_dotenv()


BASE_URL = "https://tiki.vn/api/personalish/v1/blocks/listings"
CATEGORY_ID = 1884
CATEGORY_URL_KEY = "do-dung-nha-bep"
LIMIT = 40

headers = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/151.0.0.0 Safari/537.36"
    ),
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "en-GB,en-US;q=0.9,en;q=0.8,vi;q=0.7",
    "Referer": f"https://tiki.vn/{CATEGORY_URL_KEY}/c{CATEGORY_ID}",
}

access_token = os.getenv("TIKI_ACCESS_TOKEN")
trackity_id = os.getenv("TIKI_TRACKITY_ID")
if not access_token:
    raise ValueError("TIKI_ACCESS_TOKEN is missing")

if not trackity_id:
    raise ValueError("TIKI_TRACKITY_ID is missing")

if access_token:
    headers["x-access-token"] = access_token


params = {
    "limit": LIMIT,
    "include": "advertisement",
    "aggregations": 2,
    "version": "home-persionalized",
    "trackity_id": trackity_id,
    "category": CATEGORY_ID,
    "page": 1,
    "urlKey": CATEGORY_URL_KEY,
}


product_ids = set()


with requests.Session() as session:
    page = 1

    while True:
        params["page"] = page
        print(f"Requesting page {page}...")
        try:
            response = session.get(
                BASE_URL,
                headers=headers,
                params=params,
                timeout=30,
            )
            response.raise_for_status()
        except requests.RequestException as e:
            print(f"Request failed on page {page}: {e}")
            break

        try:
            response_data = response.json()
        except ValueError:
            print(f"Invalid JSON response on page {page}")
            break
        data = response_data.get("data", [])
        
        if not data:
            print(f"No products found on page {page}. Stopping.")
            break

        previous_count = len(product_ids)
        for record in data:
            product_id = record.get("id")
            if product_id is not None:
                product_ids.add(product_id)
                
        new_count = len(product_ids) - previous_count
        print(
            f"Page {page}: "
            f"{len(data)} records, "
            f"{new_count} new product IDs, "
            f"{len(product_ids)} total unique IDs"
        )

        # Nếu page không tạo ra product ID mới, pagination đã kết thúc.
        if new_count == 0:
            print("No new product IDs. Stopping.")
            break

        page += 1

        # Random delay giữa các requests
        delay = random.uniform(3, 7)
        time.sleep(delay)

# Save result

df = pd.DataFrame(
    {
        "product_id": sorted(product_ids)
    }
)

output_file = "product_ids.csv"

df.to_csv(
    output_file,
    index=False,
    encoding="utf-8-sig",
)

print()
print(f"Crawling completed.")
print(f"Total unique products: {len(df)}")
print(f"Saved to: {output_file}")
print(response.status_code)
print(response_data.get("paging"))
print(response_data)