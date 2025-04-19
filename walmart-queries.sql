SELECT * FROM walmart;
-- drop table walmart;


select count(*)from walmart;

select
distinct payment_method,
count(*)
from walmart
group by payment_method;


SELECT DISTINCT payment_method, COUNT(*) 
FROM walmart 
GROUP BY payment_method;

SELECT COUNT(DISTINCT branch) AS distinct_branch_count 
FROM walmart;
select min(quantity) from walmart;

-- #1bussiness problem 
-- find the different payment method and number of trancation,number of qty sold

select
payment_method,
count(*) as no_payments,
sum(quantity) as no_qty_sold
from walmart group by payment_method;


-- --2# identify the higest ratwed catogery in  each branch ,
-- displying the branch ,catogery and avg rating

-- Query 1: Payment method summary
SELECT
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Query 2: Highest rated category per branch
WITH ranked_categories AS (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM walmart
    GROUP BY branch, category
)
SELECT
    branch,
    category,
    avg_rating
FROM ranked_categories
WHERE rnk = 1;

-- #3identify the busiest day for each branch based on the numer of transaction 


WITH branch_day_counts AS (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transaction,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, day_name
)
SELECT 
    branch, 
    day_name AS busiest_day, 
    no_transaction
FROM branch_day_counts
WHERE rnk = 1;

-- #4calculate the total quantity of item sold per payment method .list payment method and total quantity
SELECT
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM WALMART
GROUP BY payment_method;


-- #5 determine the average ,minimum andmaximumrating of  catogery for each city
-- list the city ,average, min_rating,and max_rating


SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;



-- #6 calculate  the total profit of each catogery  by concendring  total_profit as 
-- unit price ,quantity profit margin liastyt category and total profit orderd from higest to lowest 


select 
category,
sum(total) as total_revenew,
sum(total * profit_margin) as profit 
from walmart
group by 1;

-- #7 determine the most commann payment method for each branch .
-- display branch and the preffred_payment_medhod

select
branch,
payment_method,
count(*) as total_trans,
rank() over(partition by branch order by count(*) desc) as 'rank'
from walmart
group by 1,2;



-- #8catogeries sale into 3 group morning after noon evening 
-- find out which of the shift and number of invocies


SELECT 
  Branch,  -- this is column 1
  CASE
    WHEN HOUR(time) < 12 THEN 'morning'
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'afternoon'
    ELSE 'evening'
  END AS day_time,  -- this is column 2
  COUNT(*) AS total_records
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 2;


--  #9 identify 5 branch with higest decrese ratio in
-- reveneue compare to last year (current year 2023 and last yeear 2022)

-- Extract year from string date
SELECT *,
  EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) AS formatted_year
FROM walmart;

-- CTE for 2022 revenue
WITH revenue_2022 AS (
  SELECT
    branch,
    SUM(total) AS revenue
  FROM walmart
  WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2022
  GROUP BY branch
),

-- CTE for 2023 revenue
revenue_2023 AS (
  SELECT
    branch,
    SUM(total) AS revenue
  FROM walmart
  WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2023
  GROUP BY branch
)

-- Final query to compare both
SELECT
  ls.branch,
  ls.revenue AS last_year_revenue,
  cs.revenue AS cr_year_revenue,
  ROUND((ls.revenue - cs.revenue) / ls.revenue * 100, 2) AS decrease_percent
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs ON ls.branch = cs.branch
ORDER BY decrease_percent DESC
LIMIT 5;

