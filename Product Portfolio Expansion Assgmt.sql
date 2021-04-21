/*
12/12/13 new product (birthday bear) launch +- 1 month pre-post analysis comparing
session to order conversion rate
AOV
products per order
revenue per session
*/

SELECT
	CASE 
		WHEN website_sessions.created_at < '2013-12-12' THEN 'A. Pre_Birthday_panda'
		WHEN website_sessions.created_at >= '2013-12-12' THEN 'B. Post_Birthday_panda'
    ELSE 'Error'
    END AS time_period,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd) AS total_revenue,
    SUM(orders.items_purchased) AS total_products_sold,
    SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS average_order_value,
    SUM(orders.items_purchased)/COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1;
    
    
    
    
    
    
    
    
    
    
    
    
    