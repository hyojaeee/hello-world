/*
Product Sales Analysis:
Analyzing product sales helps you understand how each product contributes to
your business, and how product launches impact the overall portfolio
*/

SELECT
	COUNT(order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin,
    AVG(price_usd) AS average_order_value
FROM orders
WHERE order_id BETWEEN 100 AND 200;


/*
Product Level Website Analysis:
learning how customers interact with each of your products, and how well each product converts customers
*/

SELECT
	website_pageviews.pageview_url,
    COUNT(DISTINCT website_pageviews.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_pageviews.website_session_id) AS viewed_product_to_order_rate
FROM website_pageviews
LEFT JOIN orders
	ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at BETWEEN '2013-02-01' AND '2013-03-01'
	AND website_pageviews.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
GROUP BY 1;


