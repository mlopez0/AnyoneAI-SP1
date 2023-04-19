-- TODO: This query will return a table with two columns; order_status, and
-- Ammount. The first one will have the different order status classes and the
-- second one the total ammount of each.

select A.order_status as order_status
, count(A.order_status) as Ammount
from olist_orders AS A
GROUP by order_status 