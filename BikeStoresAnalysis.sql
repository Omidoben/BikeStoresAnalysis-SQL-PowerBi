--Data Transformation and Analysis of Bike Stores Database Using PostgrelSQL


SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;

--What is the total revenue generated from the sale of bikes
SELECT SUM((quantity * list_price) - discount) AS total_revenue
FROM order_items;


--Total units sold
SELECT SUM(quantity) AS units_sold
FROM order_items;


--Total Orders placed over the 3 years period
SELECT COUNT(order_id) AS total_orders
FROM order_items;



--What is the average order processing time?
SELECT ROUND(AVG(shipped_date - order_date), 0) AS average_processing_time
FROM orders;
--The average order processing time is 2 days



--What is the distribution of customers by region?
SELECT state, COUNT(*) AS no_of_customers
FROM customers
GROUP BY state;

--NewYork had the highest number of customers, followed by Texas, then Carlifonia came last



--What are the demographics of our top spending customers?
--Filter only the top 100

WITH t1 AS 
	(SELECT c.first_name, c.last_name, c.city, c.state, 
			SUM((ord.quantity * ord.list_price) - ord.discount) AS total_spending
	FROM customers c
	INNER JOIN orders o ON o.customer_id = c.customer_id
	INNER JOIN order_items ord ON ord.order_id = o.order_id
	GROUP BY c.first_name, c.last_name, c.city, c.state
	ORDER BY total_spending DESC),
t2 AS 
	(SELECT *,
		  DENSE_RANK() OVER (ORDER BY total_spending DESC) AS rnk
	FROM t1)
SELECT *
FROM t2
WHERE rnk <= 100;

--Pamelia Newman was the top spending customer, with a total spending of more than 37,000



--Which products have the highest and lowest sales and profitability?
SELECT p.product_name, p.product_id, SUM(ord.quantity) AS no_of_sales, 
		SUM((ord.quantity * ord.list_price) - ord.discount) AS total_sales
FROM products p
INNER JOIN order_items ord ON ord.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sales DESC;

--Product Trek Slash 8 27.5-2016 generated the most revenue , while Trek Precaliber 16 Boys 
--had the least revenue, it had been sold only once. 
--Notably, 15 products had been sold only once.



--Are there any seasonal trends in product sales?
--Extract year, month, and day from the order date column
--Add the year column
ALTER TABLE orders ADD COLUMN year varchar(4);

UPDATE orders
SET year = DATE_PART('year', order_date);

--Add the month column
ALTER TABLE orders ADD COLUMN month varchar(3);

UPDATE orders
SET month = TO_CHAR(order_date, 'Mon');

--Add the day column
ALTER TABLE orders ADD COLUMN day varchar(3);

UPDATE orders
SET day = TO_CHAR(order_date, 'Dy');

	
--Which year had the highest sales?

SELECT o.year, SUM(ord.quantity) AS total_sales
FROM orders o
JOIN order_items ord ON ord.order_id = o.order_id
GROUP BY o.year;

--2017 had the highest sales (3099), followed by 2016 and then 2015


--Which was the highest selling month?
SELECT o.month, SUM(ord.quantity) AS total_sales
FROM orders o
JOIN order_items ord ON ord.order_id = o.order_id
GROUP BY o.month
ORDER BY total_sales DESC

--Most products were purchased in the months of April and March, while December and November had 
--the least number of purchases


--Which was the highest selling day?
SELECT o.day, SUM(ord.quantity) AS total_sales
FROM orders o
JOIN order_items ord ON ord.order_id = o.order_id
GROUP BY o.day
ORDER BY total_sales;

--Sunday had the most sales over the three years period, while Wednesday had the least.

 

--How does the performance of different brands and categories compare in terms of revenue and units sold?

SELECT b.brand_name, SUM(ord.quantity) AS units_sold, 
		SUM((ord.quantity * ord.list_price) - ord.discount) AS total_revenue
FROM brands b
JOIN products p ON b.brand_id = p.brand_id
JOIN order_items ord ON ord.product_id = p.product_id
GROUP BY b.brand_name
ORDER BY units_sold DESC;

--The brand Trek generated the highest sales of over 5 million, followed by Electra, 
--where as Strider was the lowest


SELECT c.category_name, SUM(ord.quantity) AS units_sold,
		SUM((ord.quantity * ord.list_price) - ord.discount) AS total_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items ord ON ord.product_id = p.product_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

/*For the categories, Mountain Bikes generated the most revenue, Road Bikes was the second 
  best category, while Children Bicycles generated the lowest revenue.
Notably,  Cruisers Bicycles had the most sold out units (2063), Mountain Bikes was second with (1753)
while Children Bicycles was third with 1180 units*/



--What were the best performing categories per region
SELECT category_name, state, units_sold, total_revenue
FROM
	(SELECT *,
		RANK() OVER (PARTITION BY category_name ORDER BY units_sold DESC) AS rnk
	FROM
		(SELECT c.category_name, cust.state, SUM(ord.quantity) AS units_sold,
				SUM((ord.quantity * ord.list_price) - ord.discount) AS total_revenue
		FROM categories c
		JOIN products p ON c.category_id = p.category_id
		JOIN order_items ord ON ord.product_id = p.product_id
		JOIN orders o ON o.order_id = ord.order_id
		JOIN customers cust ON  cust.customer_id = o.customer_id
		GROUP BY c.category_name, cust.state
		ORDER BY units_sold DESC) x) y
WHERE rnk = 1;	

--Among all the categories, Newyork was the best performing region. It has the highest sales and revenue.

--Further inquriy on why newyork was the best performing region


SELECT st.store_name, st.state, SUM(sc.quantity) AS total_stocks
FROM stores st 
JOIN stocks sc ON st.store_id = sc.store_id
GROUP BY st.store_name, st.state
ORDER BY total_stocks DESC;

--Intrestingly, both states have almost the same quantity of stocks	in there stores, 
--		thus Newyork is rightfully the best performing state



--Who are the best performing staffs in each region
SELECT sf.staff_id, sf.first_name, sf.last_name, st.state, SUM(ord.quantity) AS total_sales
FROM staffs sf
JOIN orders o ON sf.staff_id = o.staff_id
JOIN stores st ON o.store_id = st.store_id
JOIN order_items ord ON ord.order_id = o.order_id
GROUP BY sf.staff_id, sf.first_name, sf.last_name, st.state
ORDER BY st.state;

/*Genna Serrano was the best performing staff in Carlifonia, Marcelene Boyer in Newyork while 
Kali Vargas in Texas*/



--What store sold the highest number of units
SELECT st.store_name, st.state, SUM(ord.quantity) AS no_of_units
FROM stores st
JOIN orders o ON st.store_id =o.store_id
JOIN order_items ord ON o.order_id = ord.order_id
GROUP BY st.store_name, st.state;

--Baldwin Bikes of NY had the highest number of units sold, followed by Santa Cruz Bikes of CA, while
--Rowlet Bikes of Texas had the least sales.



























