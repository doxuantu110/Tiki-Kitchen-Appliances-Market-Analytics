# Business Requirements - Tiki Kitchen Appliances Market Analytics

## 1. Project Overview

Phân tích ngành hàng Đồ gia dụng nhà bếp trên Tiki nhằm cung cấp góc nhìn dữ liệu cho việc ra quyết định về định giá, khuyến mãi, hợp tác thương hiệu/seller và ưu tiên marketing. Chi tiết vấn đề nghiệp vụ và
danh sách câu hỏi: xem `business_question.md`.

## 2. Stakeholder (giả định)

**Category Manager** — Đồ gia dụng nhà bếp, Tiki. Người ra quyết định
về: chiến lược định giá theo phân khúc, đàm phán điều khoản với nhà
cung cấp/seller, và phân bổ ngân sách marketing theo quý.

## 3. Business Objectives

- Xác định phân khúc giá và mức khuyến mãi tối ưu cho doanh số.
- Xác định thương hiệu/seller đang dẫn đầu và các seller còn tiềm năng
  chưa khai thác.
- Phát hiện sản phẩm/thương hiệu có rủi ro chất lượng cần cảnh báo sớm.
- Phát hiện khoảng trống trong danh mục sản phẩm (assortment gap).
- Đề xuất danh sách sản phẩm/thương hiệu ưu tiên cho chiến dịch
  marketing kế tiếp.
- Hiểu nội dung phản hồi thực tế của khách hàng đằng sau các rating thấp.

## 4. Scope

- Dữ liệu sản phẩm và review công khai trên Tiki, ngành hàng Đồ gia
  dụng nhà bếp (category id 1884).
- Phân tích mô tả (descriptive): phân phối, tương quan, KPI theo nhóm.
- Phân tích văn bản cơ bản (keyword/tần suất từ) trên nội dung review.
- Dashboard trực quan hóa KPI phục vụ Category Manager.

## 5. Data Requirements

| Dataset | Nguồn | Mục đích chính |
|---|---|---|
| `products_cleaned.csv` | Crawl từ Tiki API (`v2/products/{id}`) | Pricing, Discount, Brand/Seller, Rating, Assortment |
| `reviews_cleaned.csv` | Crawl từ Tiki API (`v2/reviews`) | Customer Voice, đối chiếu review count |

Chi tiết thu thập và làm sạch dữ liệu: xem `data_collection/` và
`data_cleaning/`.

## 6. Deliverables

1. Dataset đã làm sạch (`data/processed/`).
2. Notebook EDA và tính KPI (`eda/`, `analysis/`).
3. Dashboard Power BI theo các nhóm câu hỏi trong `business_question.md`.
4. Báo cáo Insights & Recommendations (`insights/`).

## 7. Success Criteria

- Mỗi nhóm Business Question (BQ1–BQ6) có ít nhất 1 KPI và 1 biểu đồ
  tương ứng trên dashboard.
- Mỗi insight trình bày đều có số liệu hỗ trợ và đề xuất hành động cụ
  thể (không dừng ở mô tả số liệu).

## 8. Assumptions & Limitations

- **Sub-category (`subcategory_proxy`)** được suy ra từ từ khóa trong
  tên sản phẩm, không phải danh mục chính thức từ Tiki — kết quả liên
  quan đến BQ4 mang tính ước lượng, không phải số liệu tuyệt đối chính
  xác.
- **`review_count`** trên trang sản phẩm có thể lệch so với số review
  thực tế thu thập được (`crawled_review_count`); phân tích ưu tiên dùng số liệu crawl thực tế.
- Review chỉ được thu thập cho sản phẩm có `review_count > 0` tại thời
  điểm crawl; sản phẩm mới phát sinh review sau đó sẽ không được cập nhật (dữ liệu là snapshot tại 1 thời điểm, không real-time).
- Tên khách hàng trong review đã được ẩn danh hóa trước khi xử lý/công bố, phục vụ mục đích bảo vệ dữ liệu cá nhân.
