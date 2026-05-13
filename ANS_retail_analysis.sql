SELECT COUNT(*) FROM project.transactions;
SELECT COUNT(*) FROM project.prod_cat_info;
SELECT COUNT(*) FROM project.customer;


--  1. What is the total number of rows in each of the 3 tables in the database?
SELECT * FROM project.transactions LIMIT 20;
SELECT * FROM project.customer LIMIT 20;
SELECT * FROM project.prod_cat_info;


-- 2. As you would have noticed, the dates provided across the datasets are not in a
-- correct format. As first steps, pls convert the date variables into valid date formats
-- before proceeding ahead 

SELECT *,  
    COALESCE(STR_TO_DATE(tran_date, "%d-%m-%Y"), (STR_TO_DATE(tran_date, "%d/%m/%Y"))) AS correct_date
 FROM project.transactions; 
 
SELECT DOB, STR_TO_DATE(DOB, "%d-%m-%Y") AS correct_date FROM project.customer;

-- 3. What is the time range of the transaction data available for analysis? Show the
-- output in number of days, months and years simultaneously in different columns

SELECT 
	MIN(STR_TO_DATE(tran_date, "%d-%m-%Y")) AS Begin_transactions,
    MAX(STR_TO_DATE(tran_date, "%d-%m-%Y"))  AS End_transactions,
    DATEDIFF(MAX(STR_TO_DATE(tran_date, "%d-%m-%Y")), MIN(STR_TO_DATE(tran_date, "%d-%m-%Y"))) AS number_of_days,
    FLOOR(DATEDIFF(MAX(STR_TO_DATE(tran_date, "%d-%m-%Y")), MIN(STR_TO_DATE(tran_date, "%d-%m-%Y"))) /12 ) AS number_of_months,
    FLOOR(DATEDIFF(MAX(STR_TO_DATE(tran_date, "%d-%m-%Y")), MIN(STR_TO_DATE(tran_date, "%d-%m-%Y"))) /365) AS number_of_year
FROM project.transactions;


-- 4. Which product category does the sub-category “DIY” belong to? 
SELECT prod_cat
FROM project.prod_cat_info
WHERE prod_subcat = 'DIY';


-- DATA ANALYSIS
-- 1. Which channel is most frequently used for transactions? 
SELECT Store_type AS channel,COUNT(Store_type) AS number_of_transactions
FROM project.transactions
GROUP BY Store_type
ORDER BY COUNT(Store_type) DESC;


-- 2. What is the count of Male and Female customers in the database? 
SELECT Gender, COUNT(Gender) AS Number_of_Gender
FROM project.customer
GROUP BY Gender; 

SELECT * FROM project.customer
WHERE Gender != 'M' AND Gender != 'F';

-- 3. From which city do we have the maximum number of customers and how many? 
SELECT city_code, COUNT(city_code) AS city_count
FROM project.customer
GROUP BY city_code
ORDER BY COUNT(city_code) DESC;




 -- 4. How many sub-categories are there under the Books category?
SELECT prod_cat, COUNT(prod_subcat) AS book_subcat_count FROM project.prod_cat_info;
-- WHERE prod_cat = 'Books';

SELECT prod_cat, prod_subcat FROM project.prod_cat_info;


 -- 5. What is the maximum quantity of products ever ordered?  
SELECT  project.transactions.prod_cat_code, project.transactions.prod_subcat_code, COUNT(Qty) AS Max_quantity
FROM project.transactions
INNER JOIN project.prod_cat_info 
ON project.transactions.prod_cat_code = project.prod_cat_info.prod_cat_code
	AND project.transactions.prod_subcat_code = project.prod_cat_info.prod_sub_cat_code
GROUP BY project.transactions.prod_cat_code, project.transactions.prod_subcat_code
ORDER BY Max_quantity DESC;

-- 6. What is the net total revenue generated in categories Electronics and Books?
SELECT project.prod_cat_info.prod_cat, COUNT(total_amt) AS total_revenue
FROM project.transactions
INNER JOIN project.prod_cat_info
	ON project.transactions.prod_cat_code = project.prod_cat_info.prod_cat_code
WHERE project.prod_cat_info.prod_cat = 'Books' OR project.prod_cat_info.prod_cat = 'Electronics'
GROUP BY project.prod_cat_info.prod_cat;


-- 7. How many customers have >10 transactions with us, excluding returns? 
SELECT cust_id, COUNT(cust_id) AS num_transactions
FROM project.transactions
WHERE QTY>0
GROUP BY cust_id
HAVING COUNT(cust_id) > 10
ORDER BY COUNT(cust_id) DESC;

-- solution 2
SELECT cust_id AS customer_id, COUNT(total_amt) AS num_transactions
FROM
project.transactions
WHERE QTY>0  -- remove returns
GROUP BY CUST_ID
HAVING COUNT(total_amt)>10;

-- 8. What is the combined revenue earned from the “Electronics” & “Clothing”
-- categories, from “Flagship stores”?

SELECT  project.transactions.prod_cat_code, ROUND(SUM(total_amt),2) AS revenue, store_type
FROM project.transactions
INNER JOIN project.prod_cat_info
	ON project.transactions.prod_cat_code = project.prod_cat_info.prod_cat_code
WHERE project.transactions.store_type = 'Flagship store'
AND project.prod_cat_info.prod_cat IN ('Electronics' , 'Clothing')
GROUP BY project.transactions.prod_cat_code; 

WITH total_revenue AS (
SELECT  project.transactions.prod_cat_code, ROUND(SUM(total_amt),2) AS revenue, store_type
FROM project.transactions
INNER JOIN project.prod_cat_info
	ON project.transactions.prod_cat_code = project.prod_cat_info.prod_cat_code
WHERE project.transactions.store_type = 'Flagship store'
AND project.prod_cat_info.prod_cat IN ('Electronics' , 'Clothing')
GROUP BY project.transactions.prod_cat_code)

SELECT ROUND(SUM(revenue),2) AS total_revenue FROM total_revenue;


-- 9. What is the total revenue generated from “Male” customers in “Electronics”
-- category? Output should display total revenue by prod sub-cat.

SELECT gender, project.prod_cat_info.prod_cat, project.prod_cat_info.prod_subcat, ROUND(SUM(total_amt),2) AS total_revenue
FROM project.customer
LEFT JOIN project.transactions
	-- ON project.transactions.cust_id = project.customer.customer_id
	ON project.customer.customer_id = project.transactions.cust_id
INNER JOIN project.prod_cat_info 
	ON project.transactions.prod_cat_code = project.prod_cat_info.prod_cat_code 
		AND project.transactions.prod_subcat_code = project.prod_cat_info.prod_sub_cat_code   -- key difference total and separate SUM
WHERE project.customer.Gender = 'M'
AND project.prod_cat_info.prod_cat ='Electronics'
GROUP BY gender, project.prod_cat_info.prod_cat, project.prod_cat_info.prod_subcat;


-- SELECT gender, PROD_CAT, PROD_SUBCAT,ROUND(SUM(CAST(TOTAL_AMT AS FLOAT)),2)
-- AS TOTAL_REVENUE FROM project.Customer AS C
-- LEFT JOIN project.Transactions AS TR
-- ON C.customer_Id=TR.cust_id 
-- INNER JOIN project.prod_cat_info AS PCI 
-- ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
-- WHERE GENDER = 'M' AND PROD_CAT='ELECTRONICS' 
-- GROUP BY GENDER, PROD_CAT, PROD_SUBCAT;




-- 10.  For all customers aged between 25 to 35 years find what is the net total revenue
-- generated by these consumers in last 30 days of transactions from max transaction
-- date available in the data?

-- WITH corrected_trans_date AS( 
-- SELECT   
--     COALESCE(STR_TO_DATE(tran_date, "%d-%m-%Y"), (STR_TO_DATE(tran_date, "%d/%m/%Y"))) AS correct_date
--  FROM project.transactions) 

SELECT customer_id, SUM(project.transactions.total_amt) AS Total_sales, project.transactions.tran_date
-- STR_TO_DATE(DOB, "%d-%m-%Y") AS correct_DOB  
	 -- COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y"))) AS correct_tran_date
    -- (MAX(YEAR(COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y")))))- YEAR(STR_TO_DATE(DOB, "%d-%m-%Y"))) AS year_diff
FROM project.customer
INNER JOIN project.transactions
	ON project.customer.customer_id = project.transactions.cust_id
 WHERE YEAR(COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y")))) - YEAR(STR_TO_DATE(DOB, "%d-%m-%Y")) BETWEEN 25 AND 35 
 AND COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y"))) <= '2014-02-28' 
 AND COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y"))) >= '2014-01-28'
 GROUP BY customer_id, project.transactions.tran_date;


WITH sum_total_sales AS(
SELECT customer_id, SUM(project.transactions.total_amt) AS Total_sales, project.transactions.tran_date
-- STR_TO_DATE(DOB, "%d-%m-%Y") AS correct_DOB  
	 -- COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y"))) AS correct_tran_date
    -- (MAX(YEAR(COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y")))))- YEAR(STR_TO_DATE(DOB, "%d-%m-%Y"))) AS year_diff
FROM project.customer
INNER JOIN project.transactions
	ON project.customer.customer_id = project.transactions.cust_id
 WHERE YEAR(COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y")))) - YEAR(STR_TO_DATE(DOB, "%d-%m-%Y")) BETWEEN 25 AND 35 
 AND COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y"))) <= '2014-02-28' 
 AND COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y"))) >= '2014-01-28'
 GROUP BY customer_id, project.transactions.tran_date )
 
 SELECT ROUND(SUM(Total_sales),2) AS sum_total_sales FROM sum_total_sales;

-- 11. Which product category has seen the max value of returns in the last 3 months of transactions?
SELECT project.transactions.prod_cat_code,   project.prod_cat_info.prod_cat, ROUND(SUM(total_amt),2) AS total_sales
FROM project.transactions
INNER JOIN project.prod_cat_info
	ON project.prod_cat_info.prod_cat_code = project.transactions.prod_cat_code
WHERE COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y"))) <= '2014-02-28' 
 AND COALESCE(STR_TO_DATE(project.transactions.tran_date, "%d-%m-%Y"), (STR_TO_DATE(project.transactions.tran_date, "%d/%m/%Y"))) >= '2013-12-28'
GROUP BY project.transactions.prod_cat_code, project.prod_cat_info.prod_cat
ORDER BY ROUND(SUM(total_amt),2) DESC;

-- 12. Which store-type sells the maximum products; by value of sales amount and by quantity sold?
SELECT Store_type, SUM(Qty) AS quantity_sold , ROUND(SUM(total_amt),2) AS sales_amount
FROM  project.transactions
GROUP BY Store_type
ORDER BY SUM(Qty) , SUM(total_amt) DESC;
 
-- 13. What are the categories for which average revenue is above the overall average
SELECT  project.prod_cat_info.prod_cat AS categoory,  ROUND(AVG(total_amt),2) AS sales_more_than_avg
FROM project.transactions
INNER JOIN project.prod_cat_info
	ON project.prod_cat_info.prod_cat_code = project.transactions.prod_cat_code 
		AND project.prod_cat_info.prod_sub_cat_code = project.transactions.prod_subcat_code 
GROUP BY project.prod_cat_info.prod_cat
HAVING AVG(total_amt) > (SELECT AVG(total_amt) FROM project.transactions);



-- 14. Find the average and total revenue by each subcategory for the categories which
-- are among top 5 categories in terms of quantity sold.

SELECT project.prod_cat_info.prod_cat AS category, project.prod_cat_info.prod_subcat AS subcategory, 
ROUND(AVG(total_amt),2) AS average_revenue, 
ROUND(SUM(total_amt),2) AS total_revenue , 
SUM(Qty) AS quantity_sold
FROM project.transactions
INNER JOIN project.prod_cat_info
	ON project.prod_cat_info.prod_cat_code = project.transactions.prod_cat_code 
		AND project.prod_cat_info.prod_sub_cat_code = project.transactions.prod_subcat_code 
GROUP BY project.prod_cat_info.prod_cat, project.prod_cat_info.prod_subcat
ORDER BY SUM(Qty) DESC LIMIT 5;
