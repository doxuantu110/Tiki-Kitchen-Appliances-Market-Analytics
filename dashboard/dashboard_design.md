# Dashboard Design — Tiki Kitchen Appliances Market Analytics

Tổng cộng 7 trang: 1 Overview + 6 trang theo nhóm BQ. Nguồn dữ liệu: import trực tiếp các bảng star schema từ `tiki_dw` (không dùng view phẳng — xem lý do ở phần "Nguyên tắc chung").

---

## Nguyên tắc chung (áp dụng mọi trang)

- **Nguồn dữ liệu**: import `dim_product`, `dim_brand`, `dim_subcategory`,
  `dim_seller`, `dim_date` (2 bản — 1 cho `created_date_key`, 1 cho
  `purchased_date_key`), `fact_product_metrics`, `fact_reviews`. Không
  import `vw_product_full`/`vw_review_full` làm nguồn chính — 2 view này
  chỉ dùng để kiểm tra nhanh trong SQL, import thẳng sẽ làm mất khả năng
  1 dimension lọc nhiều fact table cùng lúc.
- **Slicer cố định** (đặt cùng vị trí mọi trang): `brand_name`,
  `price_bucket`, `subcategory_name`.
- **Mỗi trang tối đa 4-5 visual** — ưu tiên KPI card ở hàng trên, biểu đồ
  chi tiết bên dưới.
- **Màu nhất quán xuyên suốt**: đỏ/cam = rủi ro/cảnh báo, xanh lá =
  tích cực, xanh dương = trung tính/mặc định. Không đổi bảng màu tùy
  tiện giữa các trang.
- **Ẩn cột khóa** (`product_key`, `brand_id`, `date_key`...) khỏi Report
  view, chỉ hiện field nghiệp vụ.

---

## Trang 0 — Overview

**Mục đích:** bức tranh tổng quan trước khi đi sâu từng nhóm câu hỏi.

| Loại | Nội dung |
|---|---|
| KPI Card | Total SKU, Total Units Sold, Avg Price, Avg Rating |
| KPI Card | % SKU on Discount, CR5 (top 5 seller market share) |
| Donut chart | SKU count theo `price_bucket` |
| Bar chart | Top 5 brand theo `Total Units Sold` |
| Line chart | Số review theo tháng (`dim_date.month`, `fact_reviews`) |

---

## Trang 1 — Pricing & Discount (BQ1)

**Câu hỏi:** Phân khúc giá nào bán chạy nhất? Discount tương quan với
doanh số tới ngưỡng nào?

| Loại | Nội dung | Field |
|---|---|---|
| KPI Card | Avg Sold per SKU (toàn ngành) | `[Avg Sold per SKU]` |
| Clustered bar | SKU count + Total Sold theo `price_bucket` | `dim_product` → `fact_product_metrics` |
| Scatter plot | `discount_rate` (X) vs `quantity_sold_value` (Y), mỗi điểm 1 SKU | `fact_product_metrics` |
| Bar chart | Avg Units Sold theo `discount_bucket` — tìm điểm bão hòa | `fact_product_metrics.discount_bucket` |

**Ghi chú thiết kế:** scatter plot nên thêm trục màu theo `price_bucket`
để thấy discount có hiệu quả khác nhau ở từng phân khúc giá không.

---

## Trang 2 — Brand & Seller (BQ2)

**Câu hỏi:** Brand/seller nào dẫn đầu? Seller nào tiềm năng chưa khai
thác?

| Loại | Nội dung | Field |
|---|---|---|
| KPI Card | CR5, Số lượng brand active | `dim_brand`, `fact_product_metrics` |
| Treemap | Market share (%) theo `brand_name` | `[Market Share %]` |
| Bubble chart | Trục X = Market Share, Trục Y = Avg Rating, size = review_count, theo `seller_name` | `dim_seller` |
| Table | Top 10 seller: sold, rating, market share (sort theo rating giảm dần) | — |

**Ghi chú thiết kế:** Bubble chart chia 4 góc phần tư bằng đường tham
chiếu (median rating, median market share) — góc "rating cao, share
thấp" chính là nhóm "tiềm năng chưa khai thác" trong BQ2.2.

---

## Trang 3 — Customer Perception (BQ3)

**Câu hỏi:** Rating khác biệt theo phân khúc giá? Sản phẩm nào rủi ro
chất lượng?

| Loại | Nội dung | Field |
|---|---|---|
| KPI Card | Avg Rating toàn ngành, Negative Review Rate | `[Negative Review Rate]` |
| Column chart | Avg Rating theo `price_bucket` | `fact_product_metrics` |
| Table (watchlist) | product_name, brand_name, rating_average, review_count — điều kiện review_count ≥ P75 và rating < 3.5 | dùng lại `vw_quality_risk_products` làm nguồn riêng cho bảng này (ngoại lệ so với nguyên tắc chung) |
| Conditional formatting | Tô đỏ dòng có rating < 3.0 trong bảng watchlist | — |

**Ghi chú thiết kế:** bảng watchlist là điểm duy nhất trong toàn bộ
dashboard nên import trực tiếp từ view thay vì bảng gốc, vì logic
percentile (`PERCENTILE_CONT`) khó viết lại gọn bằng DAX — giữ nguyên
trong SQL cho đáng tin cậy.

---

## Trang 4 — Assortment / Merchandising (BQ4)

**Câu hỏi:** Sub-category nào thiếu hàng ở phân khúc giá phổ thông?

| Loại | Nội dung | Field |
|---|---|---|
| KPI Card | Số sub-category hiện có, % SKU thuộc "Khác/Chưa phân loại" | `dim_subcategory` |
| Matrix (heatmap) | Hàng = `subcategory_name`, Cột = `price_bucket`, Giá trị = SKU count, tô nền theo giá trị | `dim_subcategory` × `dim_product` |
| Bar chart | Sub-category có ít SKU nhất ở phân khúc `<100k`/`100-300k` | — |

**Ghi chú quan trọng:** phải chú thích rõ trên trang này (text box cố
định, không phải tooltip) rằng `subcategory_name` là phân loại heuristic
theo từ khóa tên sản phẩm, không phải taxonomy chính thức từ Tiki —
đúng giới hạn đã ghi trong `business_requirements.md`.

---

## Trang 5 — Marketing Priority (BQ5)

**Câu hỏi:** Sản phẩm/brand nào phù hợp ưu tiên cho chiến dịch marketing?

| Loại | Nội dung | Field |
|---|---|---|
| KPI Card | Số sản phẩm đạt `marketing_score` > ngưỡng | measure tự định nghĩa |
| Table | Top 20 sản phẩm theo `marketing_score`, kèm sold/rating/discount | measure kết hợp (xem dưới) |
| Bar chart | Top 10 brand theo `marketing_score` trung bình | — |

**DAX gợi ý** (trọng số cần bạn tự cân nhắc lại theo ưu tiên thật):
```dax
Marketing Score =
0.4 * DIVIDE([Total Units Sold], MAX(fact_product_metrics[quantity_sold_value])) +
0.3 * DIVIDE(AVERAGE(fact_product_metrics[rating_average]), 5) +
0.3 * DIVIDE(AVERAGE(fact_product_metrics[discount_rate]), 100)
```
**Ghi chú thiết kế:** đây là trang duy nhất dùng "composite score" —
nên ghi chú công thức ngay trên trang (text box) để người xem hiểu cách
tính, tránh bị hỏi dồn khi trình bày mà không giải thích được logic.

---

## Trang 6 — Customer Voice (BQ6)

**Câu hỏi:** Khách phàn nàn gì trong review tiêu cực? Watchlist rủi ro
chất lượng thực sự gặp vấn đề gì?

**Nguồn dữ liệu khác biệt so với các trang trên:** phần word-frequency/
keyword tagging không làm được bằng T-SQL hiệu quả — tính bằng Python
(notebook riêng đọc từ `fact_reviews`/`reviews_cleaned.csv`), xuất kết
quả ra 1 bảng nhỏ (`keyword_frequency.csv`: `keyword`, `frequency`,
`is_negative_context`), rồi import bảng CSV này vào Power BI như 1 bảng
độc lập (không cần quan hệ với star schema).

| Loại | Nội dung | Field |
|---|---|---|
| KPI Card | Negative Review Rate, Số review có content | `[Negative Review Rate]` |
| Bar chart | Top 15 từ khóa xuất hiện nhiều nhất trong review tiêu cực | bảng `keyword_frequency.csv` |
| Line chart | Negative Review Rate theo tháng (`created_date_key` → `dim_date`) | `fact_reviews` |
| Table | Nội dung review của các sản phẩm trong watchlist (BQ3.2), lọc `rating <= 2` | `fact_reviews` liên kết `vw_quality_risk_products` |

---

## Trang phụ trợ (tùy chọn) — Data Quality

Không bắt buộc, nhưng nếu muốn thể hiện sự minh bạch về audit đã làm:

| Loại | Nội dung |
|---|---|
| KPI Card | Số sản phẩm `possibly_delisted`, số `discount_rate_mismatch` |
| Table | 2 sản phẩm bất thường (id 234, 479) kèm giải thích phát hiện |

---

## Đối chiếu với Success Criteria

Theo `business_requirements.md`: *"Mỗi nhóm BQ1–BQ6 có ít nhất 1 KPI và 1 biểu đồ tương ứng"* — bảng thiết kế trên đáp ứng đủ điều kiện cho cả 6 nhóm, mỗi nhóm có ít nhất 1 KPI card và 2-3 visual hỗ trợ.
