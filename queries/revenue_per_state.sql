-- TODO: This query will return a table with two columns; customer_state, and 
-- Revenue. The first one will have the letters that identify the top 10 states 
-- with most revenue and the second one the total revenue of each.
-- HINT: All orders should have a delivered status and the actual delivery date 
-- should be not null. 

select B.customer_state as customer_state
, round(SUM(C.payment_value),2) as Revenue 
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