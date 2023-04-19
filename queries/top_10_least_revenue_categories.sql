-- TODO: This query will return a table with the top 10 least revenue categories 
-- in English, the number of orders and their total revenue. The first column 
-- will be Category, that will contain the top 10 least revenue categories; the 
-- second one will be Num_order, with the total amount of orders of each 
-- category; and the last one will be Revenue, with the total revenue of each 
-- catgory.
-- HINT: All orders should have a delivered status and the Category and actual 
-- delivery date should be not null.

select D.product_category_name_english as Category
, COUNT(DISTINCT A.order_id) as Num_order
, SUM(E.payment_value) as Revenue
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
GROUP by C.product_category_name --A.order_id 
ORDER BY revenue
limit(10)
