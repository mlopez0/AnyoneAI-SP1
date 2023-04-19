-- TODO: This query will return a table with the differences between the real 
-- and estimated delivery times by month and year. It will have different 
-- columns: month_no, with the month numbers going from 01 to 12; month, with 
-- the 3 first letters of each month (e.g. Jan, Feb); Year2016_real_time, with 
-- the average delivery time per month of 2016 (NaN if it doesn't exist); 
-- Year2017_real_time, with the average delivery time per month of 2017 (NaN if 
-- it doesn't exist); Year2018_real_time, with the average delivery time per 
-- month of 2018 (NaN if it doesn't exist); Year2016_estimated_time, with the 
-- average estimated delivery time per month of 2016 (NaN if it doesn't exist); 
-- Year2017_estimated_time, with the average estimated delivery time per month 
-- of 2017 (NaN if it doesn't exist) and Year2018_estimated_time, with the 
-- average estimated delivery time per month of 2018 (NaN if it doesn't exist).
-- HINTS
-- 1. You can use the julianday function to convert a date to a number.
-- 2. order_status == 'delivered' AND order_delivered_customer_date IS NOT NULL
-- 3. Take distinct order_id.

WITH filtered_time AS
(SELECT
    strftime('%m', order_purchase_timestamp) AS month_no
	, strftime('%Y', order_purchase_timestamp) AS year
    , (JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp)) AS real_time
    , (JULIANDAY(order_estimated_delivery_date) - JULIANDAY(order_purchase_timestamp)) AS estimated_time
FROM olist_orders
WHERE 1=1
and order_status = 'delivered' 
and order_delivered_customer_date IS NOT NULL
)
SELECT month_no
, substr ("JanFebMarAprMayJunJulAugSepOctNovDec", month_no * 3 -2, 3) AS month
, AVG(CASE WHEN year = '2016' THEN real_time ELSE Null END) AS Year2016_real_time
, AVG(CASE WHEN year = '2017' THEN real_time ELSE Null END) AS Year2017_real_time
, AVG(CASE WHEN year = '2018' THEN real_time ELSE Null END) AS Year2018_real_time
, AVG(CASE WHEN year = '2016' THEN estimated_time ELSE Null END) AS Year2016_estimated_time
, AVG(CASE WHEN year = '2017' THEN estimated_time ELSE Null END) AS Year2017_estimated_time
, AVG(CASE WHEN year = '2018' THEN estimated_time ELSE Null END) AS Year2018_estimated_time 
FROM filtered_time
GROUP BY month_no;