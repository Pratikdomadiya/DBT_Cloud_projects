/*
File content :

Goal - Shows monthly product sales for each locations
output : The result of this SQL query displayed in the Monthly Product Sales report would look something like this:

product_name | sales_year | sales_month | monthly_sales
Widget_4     | 2022       | 03          | 5,600.00
widget_2     | 2022       | 04          | 10,500.00
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

































