import os
import time
import random
import hashlib
import pandas as pd
import requests
from tqdm import tqdm
from dotenv import load_dotenv

# LOAD ENV
load_dotenv()

TIKI_GUEST_TOKEN = os.getenv("TIKI_ACCESS_TOKEN")
if not TIKI_GUEST_TOKEN:
    raise ValueError(
        "TIKI_GUEST_TOKEN is missing. "
        "Please add it to your .env file."
    )

# CONFIG
REVIEW_URL = "https://tiki.vn/api/v2/reviews"
PRODUCT_INPUT_FILE = "crawled_product_data.csv" 
OUTPUT_FILE = "comments_data.csv"
FAILED_IDS_FILE = "failed_comment_product_ids.csv"
COMMENTS_PER_PAGE = 5
MAX_RETRIES = 3
DELAY_MIN = 2
DELAY_MAX = 5
SAVE_EVERY_N_PRODUCTS = 20

# Safety limit: không dùng review_count/5 làm điều kiện dừng CHÍNH,
# chỉ để chặn trường hợp bất thường (API không trả last_page, loop
# không tự dừng đúng lúc, tránh crawl vô hạn cho 1 sản phẩm).
SAFETY_BUFFER_PAGES = 5

# SESSION
session = requests.Session()
headers = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/151.0.0.0 Safari/537.36"
    ),
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7",
    "Referer": "https://tiki.vn/",
    "x-guest-token": TIKI_GUEST_TOKEN,
}
session.headers.update(headers)

# PARSER
def anonymize_name(name):
    """Ẩn danh tên khách hàng bằng hash ngắn, thay vì lưu tên thật."""
    if not name:
        return None
    return "cust_" + hashlib.sha256(name.encode("utf-8")).hexdigest()[:10]

def comment_parser(comment):
    """Parse one review/comment returned by Tiki."""
    created_by = comment.get("created_by") or {}
    return {
        "comment_id": comment.get("id"),
        "product_id": comment.get("product_id"),
        "title": comment.get("title"),
        "content": comment.get("content"),
        "rating": comment.get("rating"),
        "thank_count": comment.get("thank_count"),
        "customer_id": comment.get("customer_id"),
        "customer_name_hash": anonymize_name(created_by.get("name")),
        "purchased_at": created_by.get("purchased_at"),
        "created_at": comment.get("created_at"),
    }

# FETCH ONE PAGE (WITH RETRY)
def fetch_review_page(product_id, page):
    """Gọi 1 trang review, retry cho lỗi tạm thời. Trả None nếu thất bại hẳn."""
    params = {
        "product_id": product_id,
        "sort": "score|desc,id|desc,stars|all",
        "page": page,
        "limit": COMMENTS_PER_PAGE,
        "include": "comments",
    }
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = session.get(REVIEW_URL, params=params, timeout=30)
            if response.status_code == 429:
                wait = 10 * attempt
                print(f"    Rate-limited (429). Chờ {wait}s rồi thử lại...")
                time.sleep(wait)
                continue
            
            if response.status_code in {500, 502, 503, 504}:
                wait = 5 * attempt
                print(
                    f"    Server error {response.status_code} "
                    f"(lần {attempt}/{MAX_RETRIES}). Chờ {wait}s..."
                )
                time.sleep(wait)
                continue
            response.raise_for_status()
            
            try:
                return response.json()
            except ValueError:
                print(
                    f"    Invalid JSON cho product {product_id}, "
                    f"page {page} (lần {attempt}/{MAX_RETRIES})"
                )
                time.sleep(5 * attempt)
                continue

        except requests.RequestException as e:
            print(
                f"    Request failed cho product {product_id}, "
                f"page {page} (lần {attempt}/{MAX_RETRIES}): {e}"
            )
            time.sleep(5 * attempt)
    return None  # hết retry mà vẫn thất bại

# CRAWL COMMENTS FOR ONE PRODUCT
def crawl_product_comments(product_id, review_count):
    """
    Crawl toàn bộ reviews của một product.

    Stop conditions:
    1. API trả data rỗng
    2. API báo current_page >= last_page
    3. Page trả ít hơn COMMENTS_PER_PAGE
    4. Vượt safety_max_pages
    """
    all_comments = []
    page = 1
    safety_max_pages = (
        -(-review_count // COMMENTS_PER_PAGE)
        + SAFETY_BUFFER_PAGES
    )
    while page <= safety_max_pages:
        print(
            f"    Product {product_id} - "
            f"requesting review page {page}..."
        )
        response_data = fetch_review_page(product_id,page)

        if response_data is None:
            print(
                f"    Failed at product {product_id}, "
                f"page {page}."
            )
            return all_comments, False
        comments = response_data.get("data") or []

        # STOP 1: Không còn review
        if not comments:
            print(
                f"    No reviews on page {page}. "
                f"Stopping."
            )
            break

        # Parse
        for comment in comments:
            parsed = comment_parser(comment)
            if parsed["product_id"] is None:
                parsed["product_id"] = product_id
            all_comments.append(parsed)
        print(
            f"    Page {page}: "
            f"{len(comments)} reviews"
        )
        
        # Paging metadata
        paging = response_data.get("paging") or {}
        current_page = paging.get("current_page")
        last_page = paging.get("last_page")

        # STOP 2: API báo page cuối
        if (
            current_page is not None
            and last_page is not None
            and current_page >= last_page
        ):
            print(
                f"    Reached last page "
                f"({current_page}/{last_page})."
            )
            break

        # STOP 3: Page không đầy đủ
        if len(comments) < COMMENTS_PER_PAGE:
            print(
                f"    Page {page} has only "
                f"{len(comments)} reviews. "
                f"Stopping."
            )
            break

        # Next page
        page += 1
        time.sleep(random.uniform(DELAY_MIN,DELAY_MAX)  )

    # STOP 4: Safety limit
    if page > safety_max_pages:
        print(
            f"    WARNING: Safety limit reached "
            f"({safety_max_pages} pages)."
        )
    return all_comments, True

# MAIN
def main():
    print("Loading product data...")
    df_products = pd.read_csv(PRODUCT_INPUT_FILE)
    # Chuẩn hóa tên cột id/product_id
    id_col = "id" if "id" in df_products.columns else "product_id"
    
    if id_col not in df_products.columns or "review_count" not in df_products.columns:
        raise ValueError(
            f"{PRODUCT_INPUT_FILE} phải có cột '{id_col}' và 'review_count'."
        )

    df_products = df_products.dropna(subset=[id_col])
    df_products[id_col] = df_products[id_col].astype(int)
    df_products["review_count"] = df_products["review_count"].fillna(0).astype(int)
    total_products = len(df_products)

    # Chỉ giữ sản phẩm có review_count > 0 — bỏ qua hoàn toàn phần còn lại,
    # không gọi Review API cho chúng.
    df_to_crawl = df_products[df_products["review_count"] > 0].drop_duplicates(
        subset=[id_col]
    )

    skipped = total_products - len(df_to_crawl)

    print(f"Tổng sản phẩm: {total_products}")
    print(f"Bỏ qua (review_count == 0): {skipped}")
    print(f"Cần crawl (review_count > 0): {len(df_to_crawl)}")

    all_comments = []
    failed_ids = []

    for i, row in enumerate(
        tqdm(df_to_crawl.itertuples(index=False), total=len(df_to_crawl), desc="Products")
    ):
        product_id = getattr(row, id_col)
        review_count = getattr(row, "review_count")

        comments, ok = crawl_product_comments(product_id, review_count)
        all_comments.extend(comments)

        if not ok:
            failed_ids.append(product_id)

        print(
            f"    Product {product_id}: "
            f"{len(comments)} comments collected "
            f"(review_count khai báo: {review_count})"
        )

        # Checkpoint: lưu định kỳ để không mất data nếu gián đoạn
        if (i + 1) % SAVE_EVERY_N_PRODUCTS == 0:
            df_checkpoint = pd.DataFrame(all_comments)
            if "comment_id" in df_checkpoint.columns:
                df_checkpoint = df_checkpoint.drop_duplicates(subset=["comment_id"])
            df_checkpoint.to_csv(OUTPUT_FILE, index=False, encoding="utf-8-sig")

            if failed_ids:
                pd.DataFrame({"product_id": failed_ids}).to_csv(
                    FAILED_IDS_FILE, index=False, encoding="utf-8-sig"
                )
        time.sleep(random.uniform(DELAY_MIN, DELAY_MAX))

    # FINAL SAVE
    df_comment = pd.DataFrame(all_comments)

    if not df_comment.empty:
        if "comment_id" in df_comment.columns:
            df_comment = df_comment.drop_duplicates(subset=["comment_id"])
        df_comment.to_csv(OUTPUT_FILE, index=False, encoding="utf-8-sig")
    else:
        columns = [
            "comment_id",
            "product_id",
            "title",
            "content",
            "rating",
            "thank_count",
            "customer_id",
            "customer_name_hash",
            "purchased_at",
            "created_at",
        ]
        pd.DataFrame(columns=columns).to_csv(
            OUTPUT_FILE, index=False, encoding="utf-8-sig"
        )

    if failed_ids:
        pd.DataFrame({"product_id": failed_ids}).to_csv(
            FAILED_IDS_FILE, index=False, encoding="utf-8-sig"
        )

    print()
    print("=" * 60)
    print("COMMENT CRAWLING COMPLETED")
    print("=" * 60)
    print(f"Products đủ điều kiện crawl: {len(df_to_crawl)}")
    print(f"Products bỏ qua (review_count == 0): {skipped}")
    print(f"Products thất bại (cần retry riêng): {len(failed_ids)}")
    print(f"Comments thu được: {len(df_comment)}")
    print(f"Saved to: {OUTPUT_FILE}")
    if failed_ids:
        print(f"Failed IDs saved to: {FAILED_IDS_FILE}")

if __name__ == "__main__":
    main()