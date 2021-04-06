USE mavenfuzzyfactory;

/*
MidProject #6
*/

SELECT
    MIN(website_pageview_id)
FROM website_pageviews
WHERE website_pageviews.pageview_url = '/lander-1';

CREATE TEMPORARY TABLE first_test_pageview 
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_view
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_pageview_id >= 23504
    AND website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28'
GROUP BY 1;

CREATE TEMPORARY TABLE landing_page_for_each_session
SELECT
	first_test_pageview.first_view,
    website_pageviews.pageview_url
FROM first_test_pageview
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageview.first_view
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

CREATE TEMPORARY TABLE order_for_landing_page
SELECT
	landing_page_for_each_session.first_view,
    landing_page_for_each_session.pageview_url,
    orders.order_id,
    orders.price_usd
FROM landing_page_for_each_session
	LEFT JOIN orders
		ON orders.website_session_id = landing_page_for_each_session.first_view;

SELECT
	pageview_url,
	COUNT(DISTINCT order_for_landing_page.first_view) AS sessions,
    COUNT(DISTINCT order_for_landing_page.order_id) AS orders,
    COUNT(DISTINCT order_for_landing_page.order_id) / COUNT(DISTINCT order_for_landing_page.first_view) AS cvs_rate
FROM order_for_landing_page
GROUP BY pageview_url;

SELECT 
	MAX(website_sessions.website_session_id) AS most_recent_home_pageview
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_pageviews.pageview_url = '/home'
	AND website_sessions.created_at < '2012-11-27';


SELECT
	COUNT(website_session_id)
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';

    
/*
MidProject #7
*/

CREATE TEMPORARY TABLE reach_page
SELECT
	website_session_id,
	MAX(home) AS home,
    MAX(lander1) AS lander1,
    MAX(product) AS product,
    MAX(mrfuzzy) AS mrfuzzy,
    MAX(cart) AS cart,
    MAX(shipping) AS shipping,
    MAX(billing) AS billing,
    MAX(thankyou) AS thankyou
FROM(
SELECT
	website_sessions.website_session_id,
	(CASE WHEN website_pageviews.pageview_url = '/home' THEN 1 ELSE 0 END) AS home,
	(CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END) AS lander1,
	(CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END) AS product,
	(CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy,
	(CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart,
	(CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping,
	(CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing,
	(CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-07-19'
	AND website_sessions.created_at < '2012-07-28'
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
) AS pageview_level
GROUP BY 1;

SELECT
	CASE
		WHEN home = 1 THEN 'home_reached'
        WHEN lander1 = 1 THEN 'lander_reached'
        ELSE 'Something wrong, Check logic'
        END AS landed,
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product = 1 THEN website_session_id ELSE NULL END) AS to_product,
    COUNT(DISTINCT CASE WHEN mrfuzzy = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN cart = 1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM reach_page
GROUP BY 1;
	
SELECT
	CASE
		WHEN home = 1 THEN 'home_reached'
        WHEN lander1 = 1 THEN 'lander_reached'
        ELSE 'Something wrong, Check logic'
        END AS landed,
	COUNT(DISTINCT CASE WHEN product = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS to_product_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy_rt,
    COUNT(DISTINCT CASE WHEN cart = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy = 1 THEN website_session_id ELSE NULL END) AS to_cart_rt,
    COUNT(DISTINCT CASE WHEN shipping = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart = 1 THEN website_session_id ELSE NULL END) AS to_shipping_rt,
	COUNT(DISTINCT CASE WHEN billing = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping = 1 THEN website_session_id ELSE NULL END) AS to_billing_rt,
	COUNT(DISTINCT CASE WHEN thankyou = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing = 1 THEN website_session_id ELSE NULL END) AS to_thankyou_rt
FROM reach_page
GROUP BY 1;
    
    
/*
MidProject #8
*/    

SELECT
	page_seen,
    SUM(price_usd),
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page
FROM(
SELECT
	website_pageviews.website_session_id,
	website_pageviews.pageview_url AS page_seen,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
	AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
) AS billing_page_seen
GROUP BY 1;


SELECT
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE website_pageviews.pageview_url IN ('/billing', 'billing-2')
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27';    
    
