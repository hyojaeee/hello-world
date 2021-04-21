/*
Analyze Repeat Behavior
Analyzing repeat visitshelps you understand user behavior and identify
some of your most valuable customers

Cookies have unique ID values associated with them, which allows us to recognize
a customer when they come back and track their behavior over time

Comparing Dates and Datetimes with DATEDIFF()
DATEDIFF(secondDate, firstDate)

*/



SELECT
	order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd AS price_paid_usd,
    order_items.created_at,
    order_item_refunds.order_item_refund_id,
    order_item_refunds.refund_amount_usd,
    order_item_refunds.created_at,
    DATEDIFF(order_item_refunds.created_at, order_items.created_at) AS days_order_to_refund
FROM order_items
LEFT JOIN order_item_refunds
	ON order_item_refunds.order_item_id = order_items.order_item_id
WHERE order_items.order_id IN (3489, 32049, 27061);









