-- Superstore_Sales_Analysis
-- Skills used: Joins, CTE's, Aggregate Functions, Converting Data Types

-- Select data to have a clear view of the total order, sales, and profit per year 

SELECT sub_category, 
COUNT (quantity) AS total_orders, 
SUM(sales) AS total_sales, 
SUM(profit) AS total_profit,
DATE_PART ('Year', order_date) AS order_year
FROM products
JOIN orders USING (product_id)
GROUP BY 1,5
ORDER BY 5 ASC;

-- The data output showed that the sub_category Table is unprofitable -with a negative value- 
-- Ran the query below to see which products are unprofitable within the sub_category Table

SELECT sub_category, product_name, 
COUNT(quantity) AS total_orders, 
SUM(sales) AS total_sales, 
SUM(profit) AS total_profit,
CASE 
		WHEN SUM(profit) <= 0 THEN 'negative'
		ELSE 'positive'
	  	END AS profit_category
FROM products
JOIN orders USING (product_id)
WHERE sub_category = 'Tables'
GROUP BY 1,2 
ORDER BY 2 ASC;

-- The data output showed that at least 70% of the product in this sub_category have negative profit
-- Even though the sub_category Tables is the only one having a total negative profit, some other sub_categories have meager profit 
-- To have a clear view of those low-profit sub_categories, I ran the query below

SELECT sub_category, SUM(profit) AS total_profit,
CASE 
		WHEN SUM(profit) < 0 THEN 'loss'
		WHEN SUM(profit) <= 50000 THEN 'low_profit'
		WHEN SUM(profit) > 50001 THEN 'high_profit'
	  	END AS profit_category
FROM orders
JOIN products USING (product_id)
GROUP BY sub_category	
ORDER BY SUM(profit), profit_category ASC;

-- The data output showed that in addition to the sub_category Tables, some other sub_categories have low profits, such as the fasteners, labels, supplies, and envelopes: they generated less than $50,000 total profit since 2015  
-- After analyzing the orders table,  I needed to see how is the relation between the customer segments and the sub_category Tables 

SELECT segment AS customer_segment, COUNT(order_id) AS total_order, SUM(profit) AS total_profit,
		CAST(100.0 * SUM(profit) / SUM(SUM(profit)) over () AS INT ) AS profit_percentage
FROM orders 
JOIN customers 
USING (customer_id)
JOIN products USING (product_id)
WHERE sub_category IN ('Tables','Fasteners','Labels', 'Supplies', 'Envelopes')
GROUP BY 1
ORDER BY 1 ASC;

-- After running the above query, I found that the corporate segment is the most unprofitable, with only a 13% profit return 
-- At this stage, I wanted to see which sub_categories are less profitable in the corporate segment 

SELECT sub_category, segment AS customer_segment, SUM(profit) AS total_profit,
COUNT (quantity) AS total_order, ROUND(SUM(profit)/COUNT(quantity),2) AS unit_profit
FROM orders o
JOIN customers c
USING (customer_id)
JOIN products p
USING (product_id)
WHERE sub_category IN ('Tables','Fasteners','Labels', 'Supplies', 'Envelopes') 
				   AND segment = 'Corporate'
GROUP BY 1,2
ORDER BY 2 ASC ;

-- The data output showed that the sub_category Tables, among all other sub_categories, is the most unprofitable by far, with a substantial negative value 
-- Realizing this, I wanted to see the relation between the sub_category 'Tables' and the regions and returns tables

SELECT 
	reason_returned, 
	COUNT(reason_returned) AS total_reason_returned, 
	ROUND(100.0 * COUNT(reason_returned) / SUM(COUNT(reason_returned)) over (),2 ) AS percentage_reason_returned
FROM orders o
JOIN products p USING (product_id)
JOIN returns r USING (order_id)
JOIN customers c USING (customer_id)
WHERE sub_category = 'Tables' AND segment = 'Corporate'
GROUP BY 1
ORDER BY 1 DESC;

-- Analyzing the returned_reason for the sub_category Tables in the corporate segment gave me this result: 60% of the customers mentioned 'Wrong Item' as their returned_reason, and  23% 'Not Given. 
-- Below, I wrote the same query and slightly changed it by inserting a sub_query in the WHERE clause to select the two main reason_returned that occurred most  - Wrong Item and Not Given -

SELECT 
	reason_returned, 
	product_name,
	COUNT(return_quantity) AS total_return
FROM orders o
JOIN products p USING (product_id)
JOIN returns r USING (order_id)
JOIN customers c USING (customer_id)
WHERE sub_category = 'Tables' 
	AND segment = 'Corporate'
	AND reason_returned IN (SELECT reason_returned FROM returns
							WHERE reason_returned = 'Wrong Item'
						   OR reason_returned = 'Not Given')
GROUP BY 1,2
ORDER BY 1,3 DESC;
 
 -- After running this query, I knew which customer segment, product sub_category, and product name were causing the loss of profit, so I needed to know in which regions those customers live
 -- Localize the customers, causing the loss 
 WITH order_cte AS (
				SELECT region_id, order_id, product_id, customer_id, profit
			 	FROM orders),

region_cte AS (
				SELECT region_id, sub_region 
 				FROM regions),
			
return_cte AS (
				SELECT order_id, reason_returned
				FROM returns
				WHERE reason_returned = 'Not Given' OR reason_returned = 'Wrong Item'),
				
product_cte AS (
				SELECT product_id, sub_category
				FROM products
				WHERE sub_category = 'Tables'),
				
customer_cte AS (
				SELECT customer_id, segment
				FROM customers
				WHERE segment = 'Corporate')

SELECT
region_cte.sub_region,
SUM(order_cte.profit) AS total_profit
FROM order_cte 
JOIN region_cte USING (region_id)
JOIN return_cte USING (order_id)
JOIN product_cte USING (product_id)
JOIN customer_cte USING (customer_id)
GROUP BY region_cte.sub_region
ORDER BY SUM(order_cte.profit)
LIMIT 50;




