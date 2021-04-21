SET GLOBAL max_allowed_packet = 1073741824;

USE mavenfuzzyfactory;

SELECT *
FROM website_sessions
WHERE website_session_id = 1059;

SELECT *
FROM website_pageviews
WHERE website_session_id = 1059;

SELECT *
FROM orders
WHERE website_session_id = 1059;

SELECT
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt  -- conversion rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY utm_content  -- 1 (column name)
ORDER BY COUNT(DISTINCT website_sessions.website_session_id) DESC;    -- 2

SELECT
	website_session_id,
    created_at,
    MONTH(created_at)
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000;

SELECT
	YEAR(created_at),
    WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
GROUP BY 1, 2;

SELECT 
	primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS single_item_orders,
	COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS two_items_orders,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;


