-- monthly trends to date (sales, revenue, margin) til 01/04/13

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 1,2;


-- 04/01/12 to 04/05/13 
-- monthly order volume, conv rate, rev per session, sales by product

SELECT
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT orders.order_id) AS number_of_orders,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_sessions,
    COUNT(CASE WHEN orders.primary_product_id = 1 THEN orders.price_usd ELSE NULL END) AS product_one_sales,
    COUNT(CASE WHEN orders.primary_product_id = 2 THEN orders.price_usd ELSE NULL END) AS product_two_sales
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1,2;


-- time period (pre/post 1/6/13), sessions, clickthrough rates from /products, to mrfuzzy and to lovebear
SELECT DISTINCT 
	pageview_url
FROM website_pageviews
WHERE created_at < '2013-04-06';

-- /the-original-mr-fuzzy
-- /the-forever-love-bear

-- 1. find the relevant /products pageviews with website_session_id
-- 2. find the next pageview id that occurs After the product pageview
-- 3. find the pageview url associated with any applicable next pageview id
-- 4. summarize the data and analyze pre vs. post periods

CREATE TEMPORARY TABLE session_with_time_period
SELECT
	website_session_id,
    website_pageview_id,
	CASE
		WHEN created_at < '2013-01-06' THEN 'Pre Product 2'
        WHEN created_at >= '2013-01-06' THEN 'Post Product 2'
		ELSE 'error'
	END AS time_period
FROM website_pageviews
WHERE created_at > '2012-10-06' 
	AND created_at < '2013-04-06'
    AND pageview_url = '/products';

CREATE TEMPORARY TABLE session_with_next_pageview_id
SELECT
	session_with_time_period.time_period,
    session_with_time_period.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM session_with_time_period
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = session_with_time_period.website_session_id
    AND website_pageviews.website_pageview_id > session_with_time_period.website_pageview_id
GROUP BY 1,2;

CREATE TEMPORARY TABLE session_with_next_pageview_url
SELECT
	session_with_next_pageview_id.time_period,
    session_with_next_pageview_id.website_session_id,
	website_pageviews.pageview_url AS next_pageview_url
FROM session_with_next_pageview_id
LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = session_with_next_pageview_id.min_next_pageview_id;

SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NULL THEN website_session_id ELSE NULL END) AS with_next_page,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT website_session_id) AS clickthrough_rate_mrfuzzy,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT website_session_id) AS clickthrough_rate_lovebear
FROM session_with_next_pageview_url
GROUP BY 1;


    
    










