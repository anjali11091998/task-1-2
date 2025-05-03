--- Monday Coffee Data Analysis---
select * from city;
select * from products;
select * from customers;
select * from sales;

---Reports And Data Analysis---

---Coffee Consumers Count
--How many people in each city are estimated to consume coffee, given that 25% of the population does?
	select 
	city_name,
	round ((population* 0.25)/1000000, 2 )as coffee_consumers_in_million,
	city_rank
	from city
 	order by 2 desc
    

--Total Revenue from Coffee Sales
--What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
	select 
	ci.city_name,
	sum(s.total) as total_revenue
	from sales as s
	Join customers as c
	on s.customer_id = c.customer_id
	Join city as ci
	on ci.city_id = c.city_id
	where
	extract ( year From s.sale_date) =2023
	And
	extract ( Quarter From s.sale_date) =4
	Group by 1
	Order by 2 desc

--Sales Count for Each Product
--How many units of each coffee product have been sold?
Select 
p.product_name,
Count (s.sale_id) as total_order
from Products as p
 Left Join 
 sales as s
 on p.product_id = s.product_id
 Group by 1
 order by 2 desc

--Average Sales Amount per City
--What is the average sales amount per customer in each city?
-- city and total sale
-- no.customer in each city
		select 
	ci.city_name,
	sum(s.total) as total_revenue,
	count( Distinct s.customer_id) as total_customer,
	Round(
	sum(s.total):: numeric/
	count( Distinct s.customer_id)
	,2)  as avg_sale_per_customer
	from sales as s
	Join customers as c
	on s.customer_id = c.customer_id
	Join city as ci
	on ci.city_id = c.city_id
	Group by 1
	Order by 2 desc


--City Population and Coffee Consumers
--Provide a list of cities along with their populations and estimated coffee consumers.
	with city_table as
	(
	Select 
	city_name,
	Round ((population*0.25)/1000000,2) as coffee_consumer
	From city ),
	
	customer_table
	as
	(
	select
	ci.city_name,
	count (distinct c.customer_id) as unique_cx
	from sales as s
	Join customers as c
	on s.customer_id = c.customer_id
	join city as ci
	on ci.city_id = c.city_id
	Group by 1)

	select 
	customer_table.city_name,
	city_table.coffee_consumer,
	customer_table.unique_cx
	from city_table 
	join 
	customer_table
	on 
	city_table.city_name =customer_table.city_name
	

--Top Selling Products by City
--What are the top 3 selling products in each city based on sales volume?

	Select * 
	from 
	(Select 
	 ci.city_name,
	 p.product_name,
	 count (s.sale_id) as total_order,
	 Dense_rank () over(partition by ci.city_name order by  count (s.sale_id)desc  )as rank
	from sales as s
	Join products as p
	on s.product_id = p.product_id
	join customers as c 
	on c.customer_id = s. customer_id
	join  city as ci
	on ci.city_id = c.city_id
 
	Group by 1,2
	--order by 1,3 desc
	) as t1
	Where rank <=3


--Customer Segmentation by City
--How many unique customers are there in each city who have purchased coffee products?
	select 
	ci.city_name,
	count(distinct c.customer_id) as unique_cx
	from city as ci
	left join
	customers as c
	on c.city_id = ci.city_id
	join sales as s
	on s.customer_id = c.customer_id
	where 
	s.product_id in (1%14)
	group by 1

	 
--Average Sale vs Rent
--Find each city and their average sale per customer and avg rent per customer

with
	city_table
as
(select 
	ci.city_name,
	sum(s.total) as total_revenue,
	count( Distinct s.customer_id) as total_customer,
	Round(
	sum(s.total):: numeric/
	count( Distinct s.customer_id)
	,2)  as avg_sale_per_customer
	from sales as s
	Join customers as c
	on s.customer_id = c.customer_id
	Join city as ci
	on ci.city_id = c.city_id
	Group by 1
	Order by 2 desc
	),
	city_rent
	as
	(
	select city_name,
	estimated_rent
	from city
	)
select 
	cr.city_name,
	cr.estimated_rent,
	ct.total_customer,
	ct.avg_sale_per_customer,
	round
	(cr.estimated_rent::numeric/ct.total_customer ,2)as avg_rent_per_customer
	from city_rent as cr
	join city_table as ct
	on cr.city_name = ct. city_name
	order by 4 desc

--Monthly Sales Growth
--Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

WITH
monthly_sales
AS
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM sale_date) as month,
		EXTRACT(YEAR FROM sale_date) as YEAR,
		SUM(s.total) as total_sale
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3, 2
),
growth_ratio
AS
(
		SELECT
			city_name,
			month,
			year,
			total_sale as cr_month_sale,
			LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
		FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	ROUND(
		(cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric * 100
		, 2
		) as growth_ratio

FROM growth_ratio
where last_month_sale is not null

--Market Potential Analysis
--Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

with
	city_table
as
(select 
	ci.city_name,
	sum(s.total) as total_revenue,
	count( Distinct s.customer_id) as total_customer,
	Round(
	sum(s.total):: numeric/
	count( Distinct s.customer_id)
	,2)  as avg_sale_per_customer
	from sales as s
	Join customers as c
	on s.customer_id = c.customer_id
	Join city as ci
	on ci.city_id = c.city_id
	Group by 1
	Order by 2 desc
	),
	city_rent
	as
	(
	select city_name,
	estimated_rent,
	population
	from city
	)
select 
	cr.city_name,
	cr.estimated_rent,
	ct.total_customer,
	population,
	ct.avg_sale_per_customer,
	round
	(cr.estimated_rent::numeric/ct.total_customer ,2)as avg_rent_per_customer
	from city_rent as cr
	join city_table as ct
	on cr.city_name = ct. city_name
	order by 4 desc







