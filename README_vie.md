# Tiki Kitchen Appliances Market Analytics

End-to-end data analytics project: từ web crawling dữ liệu Tiki, làm
sạch, dựng data warehouse SQL Server, đến dashboard Power BI và báo cáo
insight — phục vụ bài toán ra quyết định của Category Manager ngành
hàng Đồ gia dụng nhà bếp.

> **Vai trò giả định:** Data Analyst hỗ trợ Category Manager tối ưu
> chiến lược định giá, đàm phán nhà cung cấp và phân bổ ngân sách
> marketing.

---

## Business Problem

Ngành hàng Đồ gia dụng nhà bếp trên Tiki có hàng nghìn SKU từ nhiều
thương hiệu, mức giá và mức giảm giá rất phân tán. Category Manager cần
trả lời: phân khúc giá nào bán chạy, thương hiệu/seller nào dẫn đầu,
khuyến mãi có thực sự hiệu quả, danh mục nào đang thiếu hàng, sản phẩm
nào nên ưu tiên marketing, và khách hàng đang phàn nàn gì đằng sau
những rating thấp.

Chi tiết đầy đủ: [`docs/business_requirements_eng.md`](docs/business_requirements_eng.md)
[`docs/business_question_eng.md`](docs/business_question_eng.md)

## Business Questions

| Nhóm | Câu hỏi chính |
|---|---|
| BQ1 - Pricing & Discount | Phân khúc giá/discount nào bán chạy nhất? Ngưỡng nào discount hết hiệu lực? |
| BQ2 - Brand & Seller | Brand/seller nào chiếm thị phần? Seller nào tiềm năng chưa khai thác? |
| BQ3 - Customer Perception | Rating khác biệt theo phân khúc giá? Sản phẩm nào rủi ro chất lượng? |
| BQ4 - Assortment | Danh mục con nào thiếu hàng ở phân khúc phổ thông? |
| BQ5 - Marketing Priority | Sản phẩm/brand nào phù hợp ưu tiên marketing? |
| BQ6 - Customer Voice | Khách hàng thực sự phàn nàn điều gì trong review tiêu cực? |

---

## Data Pipeline
![Data Pipeline](/docs/images/tiki_data_pipeline.png)


**Star schema:** `dim_product`, `dim_brand`, `dim_subcategory`,
`dim_seller`, `dim_date` (role-playing) — `fact_product_metrics`,
`fact_reviews`.

![Data Pipeline](/docs/images/tiki_kitchen_appliances_dw.png)
---

## Project Structure

```
├── docs/                     # Business problem, requirements, dashboard design
├── data_collection/          # Crawler (product IDs, product detail, reviews)
├── data/
│   ├── raw/                     # Dữ liệu thô từ crawler
│   └── processed/                # products_cleaned.csv, reviews_cleaned.csv
├── data_cleaning/             # cleaning.ipynb + audit report
├── eda/                      # Exploratory analysis
├── analysis/                 # SQL trả lời từng Business Question + BQ6 notebook
├── data_warehouse/            # SQL Server: staging → dimension → fact → view
├── dashboard/                 # File Power BI + screenshots
└── insights/                  # Báo cáo insight & recommendation cuối cùng
```

---

## Tech Stack

- **Data Collection:** Python (`requests`, `pandas`), Tiki internal API
- **Cleaning & EDA:** Python (`pandas`, `numpy`, `matplotlib`), Jupyter
- **Text Analysis:** `underthesea` (tokenize tiếng Việt), n-gram frequency + distinctiveness scoring
- **Data Warehouse:** SQL Server (star schema, T-SQL)
- **Visualization:** Power BI Desktop, DAX

---

## Key Insights

Chi tiết đầy đủ theo từng Business Question:
[`insights/Insights_Recommendations_v1.pdf`](insights/Insights_Recommendations_v1.pdf)

Một vài phát hiện nổi bật:

- **Vấn đề hậu mãi > lỗi sản phẩm:** phân tích n-gram trên review tiêu
  cực cho thấy các từ khóa đặc trưng nhất (`trả`, `giải quyết`, `trả
  lại`, `thu hồi`) đều xoay quanh quy trình đổi trả/khiếu nại, không
  phải lỗi kỹ thuật - khó thấy nếu chỉ nhìn rating trung bình.
- **Thị trường seller bị chi phối gần tuyệt đối bởi kênh first-party**
  (Seller CR5 = 96.42%) - mọi phân tích cạnh tranh seller thứ 3 được
  tách riêng để không bị con số này che khuất.
- **Discount có ngưỡng bão hòa rõ ràng ở mức 30-50%** - đẩy discount
  cao hơn không mang lại tăng trưởng doanh số tương xứng.
- **41 SKU nằm trong watchlist rủi ro chất lượng** (review nhiều,
  rating thấp) - ưu tiên xử lý trước vì ảnh hưởng lượng khách hàng lớn
  nhất.

## Dashboard Preview

7 trang: Overview · Pricing & Discount · Brand & Seller · Customer
Perception · Assortment/Merchandising · Marketing Priority · Customer
Voice. Screenshot: [`dashboard/screenshots/`](dashboard/screenshots/).

---

## Notable Challenges (đáng chú ý khi đọc code)

- **API giới hạn cứng 2,000 sản phẩm/query** — xử lý bằng đệ quy chia
  nhỏ theo khoảng giá (`crawl_product_ids.py`) đến khi mỗi khoảng dưới
  ngưỡng an toàn.
- **Phát hiện Tiki hiển thị sai `discount_rate`** cho 2 sản phẩm thật
  (`id 234`, `479`) — trang sản phẩm báo giảm giá `0%` dù thực tế lệch
  tới 15.29 điểm %; phát hiện được nhờ bước validate lại bằng
  `discount_rate_calc` trong `cleaning.ipynb`.
- **Fact-to-fact join trong Power BI:** `Dim_Seller` không nối trực
  tiếp với `Fact_Reviews` — xử lý bằng `TREATAS` trong DAX, đồng thời
  thiết kế lại để `brand`/`subcategory` nằm ở `Dim_Product` (dùng chung
  được cho cả 2 Fact table) thay vì lặp lại ở từng Fact riêng.
- **Ngưỡng cảnh báo sai đơn vị:** bug ban đầu trong quy tắc phát hiện
  lệch giá (`> 5` điểm %) lỏng hơn 10 lần so với sai số làm tròn thực tế
  của nguồn dữ liệu — sửa còn `1.0` điểm % mới bắt được lỗi thật.

## Data Limitations & Assumptions

- Dữ liệu là **snapshot 1 thời điểm**, không phải time-series.
- `subcategory_name` là phân loại heuristic theo từ khóa tên sản phẩm
  (15.44% chưa phân loại được), không phải taxonomy chính thức Tiki.
- Tên khách hàng trong review đã được ẩn danh hóa (hash) trước khi xử
  lý/công bố.

Chi tiết đầy đủ: [`docs/business_requirements.md`](00_docs/business_requirements.md#assumptions--limitations)

---

##  How to Reproduce

```bash
git clone <repo-url>
cd tiki-kitchen-appliances-market-analytics
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env   # điền TIKI_ACCESS_TOKEN, TIKI_GUEST_TOKEN, TIKI_TRACKITY_ID
```

1. **Crawl dữ liệu:** chạy lần lượt `data_collection/crawler/crawl_product_ids.py`
   → `crawl_product_data.py` → `crawl_comments.py`
2. **Làm sạch:** chạy `data_cleaning/cleaning.ipynb`
3. **Dựng warehouse:** chạy `data_warehouse/load_csv_to_staging.py`,
   rồi lần lượt 3 file `.sql` trong SQL Server Management Studio
4. **Mở dashboard:** `dashboard/*.pbix`, trỏ Data source settings về
   SQL Server instance của bạn, Refresh

---

##  Documentation

| File | Nội dung |
|---|---|
| [`docs/business_requirements.md`](docs/business_requirements_eng.md) | Scope, stakeholder, success criteria |
| [`docs/business_question.md`](docs/business_question_eng.md) | Business problem + 6 nhóm câu hỏi |
| [`docs/pdf/data_cleaning`](docs/pdf/data_cleaning.pdf) | Quy trình làm sạch dữ liệu chi tiết |
| [`dashboard/dashboard_design.md`](dashboard/dashboard_design.md) | Thiết kế từng trang dashboard |
| [`insights/Insights_Recommendations_v1.pdf`](insights/Insights_Recommendations_v1.pdf) | Insight & khuyến nghị cuối cùng |