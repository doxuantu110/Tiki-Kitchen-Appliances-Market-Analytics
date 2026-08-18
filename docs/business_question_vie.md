# Business Questions — Tiki Kitchen Appliances Market Analytics

## 1. Business Problem

Ngành hàng Đồ gia dụng nhà bếp trên Tiki có hàng nghìn SKU đến từ nhiều
thương hiệu, mức giá và mức giảm giá rất phân tán. Category Manager
(Quản lý ngành hàng) cần hiểu:

- Phân khúc giá nào đang bán chạy?
- Thương hiệu/seller nào đang chiếm ưu thế?
- Mức độ khuyến mãi có thực sự tương quan với doanh số và đánh giá hay
  không?
- Loại sản phẩm nào đang thiếu hàng ở mức giá phổ thông?
- Sản phẩm hay thương hiệu nào phù hợp cho chiến dịch Marketing sắp tới?
- Khách hàng đang thực sự phàn nàn điều gì đằng sau những rating thấp?

**→ Mục tiêu:** tối ưu chiến lược định giá, đàm phán với nhà cung cấp và
phân bổ ngân sách marketing phù hợp cho quý tới.

---

## 2. Business Questions

Mỗi câu hỏi được gán mã (BQ) để tham chiếu xuyên suốt các bước EDA, KPI
và Dashboard.

### Nhóm 1 — Pricing & Discount
*Nguồn dữ liệu chính: `products_cleaned.csv`*

| Mã | Câu hỏi |
|---|---|
| BQ1.1 | Phân khúc giá nào có mật độ sản phẩm (SKU count) và số lượng bán cao nhất? |
| BQ1.2 | Mức giảm giá có tương quan với số lượng sản phẩm bán ra hay không? Tới ngưỡng nào thì hết hiệu lực? |

### Nhóm 2 — Brand/Seller
*Nguồn dữ liệu chính: `products_cleaned.csv`*

| Mã | Câu hỏi |
|---|---|
| BQ2.1 | Top thương hiệu/seller nào chiếm thị phần lớn nhất (theo số lượng bán) trong dataset? |
| BQ2.2 | Seller nào có rating cao nhưng volume thấp — tiềm năng chưa được khai thác? |

### Nhóm 3 — Customer Perception
*Nguồn dữ liệu chính: `products_cleaned.csv`*

| Mã | Câu hỏi |
|---|---|
| BQ3.1 | Rating trung bình theo phân khúc giá có sự khác biệt không? |
| BQ3.2 | Sản phẩm nào có review count cao nhưng rating thấp — rủi ro chất lượng cần cảnh báo? |

### Nhóm 4 — Assortment/Merchandising
*Nguồn dữ liệu chính: `products_cleaned.csv` (trường `subcategory_proxy`)*

| Mã | Câu hỏi |
|---|---|
| BQ4.1 | Danh mục con nào đang thiếu hàng ở phân khúc giá phổ thông (gap in assortment)? |

> **Lưu ý:** `subcategory_proxy` là phân loại dựa trên từ khóa trong tên
> sản phẩm (heuristic), không phải taxonomy chính thức từ Tiki. Kết quả
> ở nhóm này mang tính ước lượng, cần ghi rõ giới hạn này khi trình bày.

### Nhóm 5 — Marketing Assortment
*Nguồn dữ liệu chính: `products_cleaned.csv`*

| Mã | Câu hỏi |
|---|---|
| BQ5.1 | Sản phẩm hay thương hiệu/seller nào có sự kết hợp mạnh nhất giữa số lượng bán, đánh giá khách hàng và mức độ hấp dẫn của khuyến mãi - phù hợp ưu tiên cho chiến dịch marketing sắp tới? |

### Nhóm 6 — Customer Voice
*Nguồn dữ liệu chính: `reviews_cleaned.csv` (trường `content`, lọc `has_content = True`)*

| Mã | Câu hỏi |
|---|---|
| BQ6.1 | Những từ khóa/chủ đề nào xuất hiện nhiều nhất trong các đánh giá tiêu cực (rating ≤ 2)? |
| BQ6.2 | Trong nhóm sản phẩm thuộc "watchlist rủi ro chất lượng" (BQ3.2), nội dung comment thực sự phàn nàn về điều gì? |

---

## 3. Ghi chú liên kết

- Yêu cầu nghiệp vụ chi tiết (scope, ràng buộc, tiêu chí hoàn thành): xem
  `business_requirements.md`.
