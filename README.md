# TASK -1-2

**Task 1** -  PERFORM INNER, LEFT, RIGHT, ANDFULL JOINS ON TABLES TO COMBINE DATA MEANINGFULLY.
 
 **Task 2** -  USE WINDOW FUNCTIONS,SUBQUERIES, AND CTES (COMMONTABLE EXPRESSIONS) FOR ADVANCED DATA ANALYSIS.

**Total Revenue from Coffee Sales**

-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?


SELECT 

	SUM(total) as total_revenue
 
FROM sales


WHERE 

	EXTRACT(YEAR FROM sale_date)  = 2023
 
	AND
 
	EXTRACT(quarter FROM sale_date) = 4



SELECT 

	ci.city_name,
 
	SUM(s.total) as total_revenue
 
FROM sales as s

JOIN customers as c

ON s.customer_id = c.customer_id


JOIN city as ci


ON ci.city_id = c.city_id

WHERE 

	EXTRACT(YEAR FROM s.sale_date)  = 2023
 
	AND
 
	EXTRACT(quarter FROM s.sale_date) = 4
 
GROUP BY 1

ORDER BY 2 DESC






Sales Count for Each Product

-- How many units of each coffee product have been sold?


SELECT 

	p.product_name,
 
	COUNT(s.sale_id) as total_orders
 
FROM products as p

LEFT JOIN

sales as s

ON s.product_id = p.product_id

GROUP BY 1

ORDER BY 2 DESC




-- **Average Sales Amount per City**

-- What is the average sales amount per customer in each city?

-- city abd total sale

-- no cx in each these city



SELECT 

	ci.city_name,
 
	SUM(s.total) as total_revenue,
 
	COUNT(DISTINCT s.customer_id) as total_cx,
 
	ROUND(
 
			SUM(s.total)::numeric/
   
				COUNT(DISTINCT s.customer_id)::numeric
    
			,2) as avg_sale_pr_cx
	
FROM sales as s

JOIN customers as c

ON s.customer_id = c.customer_id

JOIN city as ci

ON ci.city_id = c.city_id

GROUP BY 1

ORDER BY 2 DESC

