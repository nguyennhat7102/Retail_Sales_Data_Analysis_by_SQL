# Retail Sales Data Analysis SQL Project

Dự án này tập trung vào việc làm sạch dữ liệu, khám phá dữ liệu (EDA) và giải quyết các bài toán kinh doanh thực tế trong lĩnh vực bán lẻ bằng cách sử dụng **PostgreSQL / SQL**.

## 📌 Tổng quan dự án

Dự án phân tích một tập dữ liệu bán lẻ chứa thông tin về các giao dịch, bao gồm ngày giờ bán hàng, thông tin khách hàng (ID, giới tính, độ tuổi), danh mục sản phẩm, số lượng, đơn giá, giá vốn hàng bán (COGS) và tổng doanh thu. Mục tiêu của dự án là xây dựng cơ sở dữ liệu, xử lý dữ liệu bị khuyết thiếu, và thực hiện các câu lệnh truy vấn phân tích (SQL queries) để trả lời các câu hỏi kinh doanh quan trọng.

---

## 🗂️ Cấu trúc cơ sở dữ liệu (Database Schema)

Dữ liệu được lưu trữ trong bảng `retail_sales` với cấu trúc như sau:

| Tên cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `transactions_id` | `INT` (Primary Key) | Mã định danh duy nhất cho mỗi giao dịch |
| `sale_date` | `DATE` | Ngày thực hiện giao dịch |
| `sale_time` | `TIME` | Giờ thực hiện giao dịch |
| `customer_id` | `INT` | Mã định danh khách hàng |
| `gender` | `VARCHAR(15)` | Giới tính khách hàng |
| `age` | `INT` | Tuổi của khách hàng |
| `category` | `VARCHAR(15)` | Danh mục sản phẩm |
| `quantity` | `INT` | Số lượng sản phẩm mua |
| `price_per_unit` | `FLOAT` | Đơn giá sản phẩm |
| `cogs` | `FLOAT` | Giá vốn hàng bán (Cost of Goods Sold) |
| `total_sale` | `FLOAT` | Tổng doanh thu của giao dịch |

---

## 🛠️ Các bước thực hiện dự án

### 1. Tạo bảng và Chuẩn hóa dữ liệu
*   **Tạo bảng**: Định nghĩa cấu trúc bảng `retail_sales`.
*   **Sửa tên cột**: Đổi tên cột bị gõ sai từ `quantiy` thành `quantity`.

```sql
DROP TABLE IF EXISTS RETAIL_SALES;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantiy INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

ALTER TABLE retail_sales RENAME COLUMN quantiy TO quantity;
```

### 2. Khám phá & Làm sạch dữ liệu (EDA)
*   **Kiểm tra số lượng bản ghi**: Xác định quy mô tập dữ liệu.
*   **Xử lý dữ liệu khuyết thiếu (Null Values)**: Xác định các dòng có giá trị `NULL` ở các trường thông tin quan trọng và tiến hành loại bỏ để đảm bảo tính chính xác cho phân tích.

```sql
-- Kiểm tra các giá trị NULL
SELECT * FROM retail_sales 
WHERE category IS NULL OR customer_id IS NULL OR cogs IS NULL 
   OR gender IS NULL OR sale_time IS NULL OR sale_date IS NULL 
   OR price_per_unit IS NULL OR total_sale IS NULL;

-- Xóa các bản ghi chứa giá trị NULL
DELETE FROM retail_sales 
WHERE category IS NULL OR customer_id IS NULL OR cogs IS NULL 
   OR gender IS NULL OR sale_time IS NULL OR sale_date IS NULL 
   OR price_per_unit IS NULL OR total_sale IS NULL;
```

**Thống kê mô tả tổng quan (Descriptive Statistics) cho các biến số**:
  
| Metric | Value |
|---|---:|
|Min Age | 18 |
| Max Age | 64 |
| Avg Age | 41.35 |
| Min Quantity | 1 |
| Max Quantity | 4 |
| Avg Quantity | 2.51 |
| Min Sale | 25 |
| Max Sale | 2,000 |
| Avg Sale | 456.54 |

**Xác định biên thời gian của dữ liệu (Data Timeline)**

| start_date |	end_date |	total_days_of_data|
|---|---|---:|
|2022-01-01	|2023-12-31|	729|

**Thống kê số lượng và tỷ lệ % giao dịch theo giới tính**
| Gender | Transaction Count | Percentage |
|---|---:|---:|
| Female | 1,017 | 50.93% |
| Male | 980 | 49.07% |

**Thống kê hiệu quả tài chính sơ bộ (Initial Profitability)**

| Metric | Value |
|---|---:|
| Total Sales | 911,720.00 |
| Total Cost | 189,762.70 |
| Profit | 721,957.30 |
| Profit Margin | 79.19% |

**Kiểm tra tính toàn vẹn logic của dữ liệu (Data Integrity Check) - True**

```sql
SELECT COUNT(*) AS anomalous_rows
FROM retail_sales
WHERE ABS(total_sale - (quantity * price_per_unit)) > 0.01;
```

---    

## 📊 Giải quyết các bài toán kinh doanh bằng SQL

Dưới đây là danh sách 10 câu hỏi kinh doanh cốt lõi đã được giải quyết bằng các truy vấn SQL tối ưu trong dự án:

### Q1: Truy xuất tất cả các giao dịch được thực hiện vào ngày '2022-11-05'
```sql
SELECT * FROM retail_sales 
WHERE sale_date = '2022-11-05';
```

### Q2: Truy xuất tất cả các giao dịch thuộc danh mục 'Clothing' có số lượng bán lớn hơn 3 trong tháng 11/2022
```sql
SELECT * FROM retail_sales 
WHERE category = 'Clothing' 
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11' 
  AND quantity > 3;
```

### Q3: Tính tổng doanh thu (total_sale) cho từng danh mục sản phẩm
```sql
SELECT category, SUM(total_sale) AS total_sale_each 
FROM retail_sales 
GROUP BY category 
ORDER BY total_sale_each DESC;
```

### Q4: Tính giá trị đơn hàng trung bình của từng khách hàng mua sắm trong danh mục 'Beauty'
```sql
SELECT customer_id, AVG(total_sale) AS avg_price 
FROM retail_sales 
WHERE category = 'Beauty' 
GROUP BY customer_id 
ORDER BY avg_price DESC;
```

### Q5: Tìm tất cả các giao dịch có tổng doanh thu lớn hơn 1000
```sql
SELECT * FROM retail_sales 
WHERE total_sale > 1000;
```

### Q6: Tìm tổng số giao dịch được thực hiện bởi từng giới tính trong mỗi danh mục sản phẩm
```sql
SELECT gender, category, COUNT(*) AS total_transactions
FROM retail_sales 
GROUP BY gender, category
ORDER BY category;
```

### Q7: Tính doanh thu trung bình hàng tháng và tìm ra tháng có doanh thu cao nhất (Best Selling Month) của mỗi năm
```sql
SELECT year, month, avg_sale FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year, 
        EXTRACT(MONTH FROM sale_date) AS month, 
        AVG(total_sale) AS avg_sale,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank 
    FROM retail_sales 
    GROUP BY 1, 2
) AS t1 
WHERE rank = 1;
```

### Q8: Tìm top 5 khách hàng có tổng doanh số mua hàng cao nhất
```sql
SELECT customer_id, SUM(total_sale) AS total_sale_each_cus 
FROM retail_sales 
GROUP BY customer_id 
ORDER BY total_sale_each_cus DESC 
LIMIT 5;
```

### Q9: Tìm số lượng khách hàng duy nhất đã mua sắm trong từng danh mục sản phẩm
```sql
SELECT category, COUNT(DISTINCT customer_id) AS unique_customers 
FROM retail_sales 
GROUP BY category;
```

### Q10: Phân nhóm các đơn hàng theo ca làm việc (Sáng: <=11h, Chiều: 12h-17h, Tối: >17h) và thống kê tổng số đơn hàng của từng ca
```sql
WITH hourly_sale AS (
    SELECT *, 
        CASE 
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning' 
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon' 
            ELSE 'Evening' 
        END AS shift 
    FROM retail_sales 
) 
SELECT shift, COUNT(*) AS total_orders 
FROM hourly_sale 
GROUP BY shift;
```

---

## 🚀 Hướng dẫn chạy dự án

1.  **Cài đặt Cơ sở dữ liệu**: Đảm bảo máy tính của bạn đã cài đặt PostgreSQL (hoặc bất kỳ hệ quản trị CSDL SQL tương thích nào như MySQL, SQL Server).
2.  **Tạo bảng**: Chạy các câu lệnh trong phần "Tạo bảng" để xây dựng cấu trúc lưu trữ.
3.  **Import dữ liệu**: Nhập tệp dữ liệu bán lẻ của bạn vào bảng `retail_sales` vừa tạo.
4.  **Làm sạch dữ liệu**: Chạy truy vấn làm sạch để xóa các dòng dữ liệu bị khuyết (`NULL`).
5.  **Phân tích**: Chạy 10 câu lệnh phân tích nghiệp vụ bên trên để nhận kết quả phân tích.

---

## 📈 Kết quả và Bài học rút ra
*   Hiểu rõ hơn về hành vi mua sắm của khách hàng dựa trên giới tính, độ tuổi và thời gian (ca làm việc).
*   Xác định được danh mục sản phẩm mang lại doanh thu cao nhất để tối ưu chiến lược kho bãi và tiếp thị.
*   Thực hành chuyên sâu các kỹ thuật SQL như: **Window Functions (RANK)**, **Common Table Expressions (CTE)**, các hàm xử lý ngày tháng (`EXTRACT`, `TO_CHAR`), gom nhóm (`GROUP BY`), lọc dữ liệu và làm sạch dữ liệu.
