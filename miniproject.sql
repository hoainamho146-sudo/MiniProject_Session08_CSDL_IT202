CREATE DATABASE salesManagement;

USE salesManagement;

CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    gender TINYINT NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    product_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE orderTable (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE orderDetail (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    order_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orderTable(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

INSERT INTO customer(full_name, dob, gender, email, phone_number)
VALUES
('Nguyen Van An', '2002-05-12', 1, 'an@gmail.com', '0901111111'),
('Tran Thi Bich', '1999-09-21', 0, 'bich@gmail.com', '0902222222'),
('Le Minh Quan', '2001-11-10', 1, 'quan@gmail.com', '0903333333'),
('Pham Thu Ha', '1998-03-15', 0, 'ha@gmail.com', '0904444444'),
('Hoang Gia Bao', '2003-07-08', 1, 'bao@gmail.com', '0905555555');

INSERT INTO category(category_name)
VALUES
('Dien tu'),
('Thoi trang'),
('Gia dung'),
('Sach'),
('The thao');

INSERT INTO product(category_id, product_name, product_price)
VALUES
(1, 'Laptop Dell', 22000000),
(1, 'iPhone 15', 28000000),
(2, 'Ao Hoodie', 450000),
(3, 'Noi chien khong dau', 1800000),
(4, 'Sach SQL Co Ban', 120000),
(5, 'Giay Adidas', 2500000);

INSERT INTO orderTable(customer_id, order_date)
VALUES
(1, '2025-05-01'),
(2, '2025-05-02'),
(3, '2025-05-03'),
(1, '2025-05-04'),
(4, '2025-05-05');

INSERT INTO orderDetail(order_id, product_id, quantity, order_price)
VALUES
(1, 1, 1, 22000000),
(1, 5, 2, 5000000),
(2, 2, 1, 28000000),
(3, 3, 3, 1350000),
(4, 4, 2, 240000),
(5, 6, 1, 2500000);

set sql_safe_updates = 0;

update Product
set product_price = 10000000000
where product_id = 1;

update customer
set email = 'ngvantruon@gmail.com'
where customer_id = 1;

delete from orderDetail
where Order_id = 1;

-- 1
SELECT full_name, email,
CASE 
WHEN gender = 1 THEN 'Nam'
WHEN gender = 0 THEN 'Nữ'
ELSE 'Khác'
END AS Sex
FROM customer;


-- 2
SELECT * FROM customer
ORDER BY (YEAR(NOW()) - YEAR(dob)) ASC LIMIT 3;

-- 3
SELECT o.order_id, o.order_date, c.full_name
FROM orderTable o
INNER JOIN customer c
ON o.customer_id = c.customer_id;


-- 4
SELECT c.category_name, COUNT(p.product_id) AS total_product
FROM category c
INNER JOIN product p
ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) >= 2;

-- 5
select * from product
where product_price > (select avg(product_price) avg_price from product);

-- 6
select * from customer where customer_id not in (select customer_id from orderTable);

-- 7 Quyên 
SELECT 
    c.category_name,
    SUM(o.quantity * o.order_price) AS revenue
FROM category c
JOIN product p 
    ON c.category_id = p.category_id
JOIN orderDetail o 
    ON p.product_id = o.product_id
GROUP BY c.category_name
HAVING SUM(o.quantity * o.order_price) > (
    SELECT AVG(revenue) * 1.2
    FROM (
        SELECT 
            p.category_id,
            SUM(o.quantity * o.order_price) AS revenue
        FROM product p
        JOIN orderDetail o 
            ON p.product_id = o.product_id
        GROUP BY p.category_id
    ) t
);

-- 7 Danh
-- Tính tổng giá trị doanh thu từng danh mục
select sum(quantity * order_price) as sum_revenue_caterogy from orderDetail od 
inner join product p on p.product_id = od.product_id
group by p.category_id;

-- Tính trung bình giá trị doanh thu của tất cả doanh mục
select avg(sum_revenue_caterogy) as avg_revenue
from 
	(select sum(quantity * order_price) as sum_revenue_caterogy from orderDetail od 
	inner join product p on p.product_id = od.product_id
	group by p.category_id) as sum_revenue_caterogy_table;
    
-- Gom code
select c.category_name, sum(od2.quantity * od2.order_price) as sum_revenue from orderDetail od2
inner join product p2 on p2.product_id = od2.product_id
inner join category c on c.category_id = p2.category_id
group by c.category_name
having 
	sum(od2.quantity * od2.order_price) 
    > (select avg(sum_revenue_caterogy) as avg_revenue
		from 
			(select sum(quantity * order_price) as sum_revenue_caterogy from orderDetail od 
			inner join product p on p.product_id = od.product_id
			group by p.category_id) as sum_revenue_caterogy_table) * 1.2;

-- 8
-- Lấy danh sách sản phẩm kèm theo danh mục
select p.product_id, p.product_name, p.product_price, c.category_name from product p
inner join category c on c.category_id = p.category_id;

-- Lấy danh sách các sản phẩm có giá đắt nhất trong từng danh mục
select p.product_id, p.product_name, p.product_price, c.category_name from product p
inner join category c on c.category_id = p.category_id
where p.product_price = (select max(p2.product_price) from product p2
						where p.category_id = p2.category_id);	
                        
-- 9
-- Dùng inner join
select * from customer c 
inner join orderTable ot on ot.customer_id = c.customer_id 
inner join orderDetail od on od.order_id = ot.order_id 
inner join product p on p.product_id = od.product_id 
inner join category ct on ct.category_id = p.category_id
where ct.category_name = 'Dien tu';

-- Dùng lồng nhiều cấp 
-- 1. Lấy id danh mục điện tử
select c.category_id from category c where c.category_name = 'Dien tu';

-- 2. Lấy id thông tin sản phẩm, lồng 1
select p.product_id from product p
where p.category_id in (select c.category_id from category c where c.category_name = 'Dien tu');

-- 3. Lấy id chi tiết đơn hàng, lồng 2
select od.order_id from orderDetail od
where od.product_id in (select p.product_id from product p
					   where p.category_id in (select c.category_id from category c 
											  where c.category_name = 'Dien tu'));

-- 4. Lấy id đơn hàng, lồng 3
select ot.order_id from orderTable ot
where ot.order_id in (select od.order_id from orderDetail od
						where od.product_id in (select p.product_id from product p
												where p.category_id in (select c.category_id from category c 
																		where c.category_name = 'Dien tu')));
                                                                        
-- 5. Lấy thông tin người dùng mua sp trong danh mục Điện tử, lồng 4
select * from customer c
where c.customer_id in (select ot.order_id from orderTable ot
					where ot.order_id in (select od.order_id from orderDetail od
											where od.product_id in (select p.product_id from product p
																	where p.category_id in (select c.category_id from category c 
																							where c.category_name = 'Dien tu'))));
