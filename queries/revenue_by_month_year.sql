-- TODO: This query will return a table with the revenue by month and year. It
-- will have different columns: month_no, with the month numbers going from 01
-- to 12; month, with the 3 first letters of each month (e.g. Jan, Feb);
-- Year2016, with the revenue per month of 2016 (0.00 if it doesn't exist);
-- Year2017, with the revenue per month of 2017 (0.00 if it doesn't exist) and
-- Year2018, with the revenue per month of 2018 (0.00 if it doesn't exist).

WITH rev_month_tmp AS
(SELECT
    strftime('%m', A.order_delivered_customer_date) AS month_no
    ,B.payment_value as month_amount
	,strftime('%Y', A.order_delivered_customer_date) AS year_n
FROM olist_orders A
join olist_order_payments B
	on A.order_id = B.order_id 
WHERE 1=1
and A.order_status = 'delivered' 
AND A.order_delivered_customer_date IS NOT NULL
and A.order_purchase_timestamp is NOT NULL 
GROUP By A.order_id 
)
SELECT month_no
, substr ("JanFebMarAprMayJunJulAugSepOctNovDec", month_no * 3 -2, 3) AS month
, SUM(CASE WHEN year_n = '2016' THEN month_amount ELSE 0.00 END) AS Year2016
, SUM(CASE WHEN year_n = '2017' THEN month_amount ELSE 0.00 END) AS Year2017
, SUM(CASE WHEN year_n = '2018' THEN month_amount ELSE 0.00 END) AS Year2018
FROM rev_month_tmp
GROUP BY month_no;

