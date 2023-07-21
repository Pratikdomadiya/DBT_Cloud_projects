/*
File contetent :

- Shows monthly product sales for each locations
*/

SELECT 
     p.product_name, 
     YEAR(f.transaction_date) as sales_year, 
     MONTH(f.transaction_date) as sales_month, 
     SUM(f.amount * f.quantity) as monthly_sales
FROM 
     fact_transactions as f
INNER JOIN 
     dim_products as p ON f.product_id = p.product_id
GROUP BY 
     p.product_name, 
     YEAR(f.transaction_date), 
     MONTH(f.transaction_date)
ORDER BY 
     sales_year, 
     sales_month DESC

/*
https://www.datafold.com/blog/7-dbt-testing-best-practices
*/

































