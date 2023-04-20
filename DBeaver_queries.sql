
---------- QUERY #1 ------------------
-- 		delivery_date_difference
--------------------------------------
-- Two columns: State & Delivery_difference

select A.customer_state
,CAST(
		AVG(
			julianday(STRFTIME("%Y-%m-%d",B.order_estimated_delivery_date)) - julianday(STRFTIME("%Y-%m-%d",B.order_delivered_customer_date))
			)
	AS INT
	) as delivery_difference
from olist_customers A 
inner join olist_orders B
on A.customer_id=B.customer_id 
WHERE 
B.order_status='delivered'
AND B.order_delivered_customer_date IS NOT NULL 
GROUP by A.customer_state 
order by delivery_difference

SELECT customer_state AS State,
CAST(AVG(julianday(STRFTIME("%Y-%m-%d",order_estimated_delivery_date))-julianday(STRFTIME("%Y-%m-%d",order_delivered_customer_date))) AS INTEGER) AS Delivery_Difference
FROM olist_customers cust
INNER JOIN olist_orders  ord ON ord.customer_id = cust.customer_id 
WHERE ord.order_status ='delivered' AND order_delivered_customer_date IS NOT NULL
GROUP BY customer_state
ORDER BY Delivery_Difference; 


/*
State|Delivery_Difference|
-----+-------------------+
AL   |                  8|
MA   |                  9|
BA   |                 10|
CE   |                 10|
ES   |                 10|
SE   |                 10|
MS   |                 11|
PI   |                 11|
RJ   |                 11|
SC   |                 11|
SP   |                 11|
DF   |                 12|
GO   |                 12|
TO   |                 12|
MG   |                 13|
PB   |                 13|
PE   |                 13|
PR   |                 13|
RN   |                 13|
RS   |                 13|
MT   |                 14|
PA   |                 14|
RR   |                 17|
AM   |                 19|
AP   |                 19|
AC   |                 20|
RO   |                 20|
 */




---------- QUERY #2 ------------------
--  	global_ammount_order_status
--------------------------------------

-- order_satus & ammount.

select * from olist_orders_dataset ood 
/*
order_id                        |customer_id                     |order_status|order_purchase_timestamp|order_approved_at  |order_delivered_carrier_date|order_delivered_customer_date|order_estimated_delivery_date|
--------------------------------+--------------------------------+------------+------------------------+-------------------+----------------------------+-----------------------------+-----------------------------+
e481f51cbdc54678b7cc49136f2d6af7|9ef432eb6251297304e76186b10a928d|delivered   |2017-10-02 10:56:33     |2017-10-02 11:07:15|2017-10-04 19:55:00         |2017-10-10 21:25:13          |2017-10-18 00:00:00          |
53cdb2fc8bc7dce0b6741e2150273451|b0830fb4747a6c6d20dea0b8c802d7ef|delivered   |2018-07-24 20:41:37     |2018-07-26 03:24:27|2018-07-26 14:31:00         |2018-08-07 15:27:45          |2018-08-13 00:00:00          |
47770eb9100c2d0c44946d9cf07ec65d|41ce2a54c0b03bf3443c3d931a367089|delivered   |2018-08-08 08:38:49     |2018-08-08 08:55:23|2018-08-08 13:50:00         |2018-08-17 18:06:29          |2018-09-04 00:00:00          |
 */
select * from olist_order_payments_dataset oopd 
/*
order_id                        |payment_sequential|payment_type|payment_installments|payment_value|
--------------------------------+------------------+------------+--------------------+-------------+
b81ef226f3fe1789b1e8b2acac839d17|                 1|credit_card |                   8|        99.33|
a9810da82917af2d9aefd1278f1dcfa0|                 1|credit_card |                   1|        24.39|

*/

select A.order_status
, count(A.order_status)
from olist_orders AS A
GROUP by order_status 

---------- QUERY #3 ------------------
--  real_vs_estimated_delivered_time
--------------------------------------


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



---------- QUERY #4 ------------------
--  revenue_by_month_year
--------------------------------------

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




---------- QUERY #5 ------------------
--  revenue_per_state
--------------------------------------

select B.customer_state 
, round(SUM(C.payment_value),2) as revenue 
from olist_orders A
join olist_customers B
    on A.customer_id = B.customer_id 
join olist_order_payments C 
    on C.order_id = A.order_id 
where 1=1
and A.order_status = 'delivered'
and A.order_delivered_customer_date is not null
GROUP by B.customer_state 
Order By 2 DESC
limit(10)

---------- QUERY #6 ------------------
--  top_10_least_revenue_categories
--------------------------------------

select D.product_category_name_english 
, COUNT(DISTINCT A.order_id) as num_order
, SUM(E.payment_value) as revenue
from olist_orders A
join olist_order_items B on A.order_id = B.order_id 
join olist_products C  on B.product_id = C.product_id 
join product_category_name_translation D on C.product_category_name  = D.product_category_name 
join olist_order_payments E on E.order_id = A.order_id 
where 1=1 
and A.order_status='delivered'
and A.order_delivered_customer_date is not null
GROUP by C.product_category_name --A.order_id 
ORDER BY revenue
limit(10)


---------- QUERY #7 ------------------
--  top_10_revenue_categories
--------------------------------------

select D.product_category_name_english as category
, COUNT(DISTINCT A.order_id) as num_order
, SUM(E.payment_value) as revenue 
from olist_orders A
join olist_order_items B
	on A.order_id = B.order_id 
join olist_products C 
	on B.product_id = C.product_id 
join product_category_name_translation D
	on C.product_category_name  = D.product_category_name 
join olist_order_payments E 
	on E.order_id = A.order_id 
where 1=1 
and A.order_status='delivered'
and A.order_delivered_customer_date is not null
and C.product_category_name is not null
GROUP by C.product_category_name 
ORDER BY revenue DESC 
limit(10)






 
 
 
 