USE mavenfuzzyfactory;
/*
1.	Gsearch seems to be the biggest driver of our business. Could you pull monthly 
trends for gsearch sessions and orders so that we can showcase the growth there? 
*/ 

SELECT
	MONTH(website_sessions.created_at) AS month_2012,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders_counted
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY 1;

/*
2.	Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand 
and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell. 
*/ 

SELECT 
	MONTH(website_sessions.created_at) AS month_2012,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY 1;

/*
3.	While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 
I want to flex our analytical muscles a little and show the board we really know our traffic sources. 
*/ 

SELECT
	MONTH(website_sessions.created_at) AS month_2012,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1;

/*
4.	I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/ 

SELECT * FROM orders WHERE order_id < 100;
SELECT * FROM website_pageviews WHERE website_session_id < 300;

SELECT 
	website_pageviews.website_session_id,
	(CASE WHEN pageview_url = '/home' OR pageview_url = '/lander-1' THEN 1 ELSE 0 END) AS home_page,
    (CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS product_page,
	(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_page,
	(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page,
	(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_page,
	(CASE WHEN pageview_url = '/billing' OR pageview_url = '/billing-2'THEN 1 ELSE 0 END) AS billing_page,
	(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_page
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch';

CREATE TEMPORARY TABLE pageviews_gsearch
SELECT
	website_session_id,
    MAX(home_page) AS home,
    MAX(product_page) AS product,
    MAX(mrfuzzy_page) AS mrfuzzy,
    MAX(cart_page) AS cart,
    MAX(shipping_page) AS shipping, 
    MAX(billing_page) AS billing,
    MAX(thankyou_page) AS thankyou
FROM(
SELECT 
	website_pageviews.website_session_id,
	(CASE WHEN pageview_url = '/home' OR pageview_url = '/lander-1' THEN 1 ELSE 0 END) AS home_page,
    (CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS product_page,
	(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_page,
	(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page,
	(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_page,
	(CASE WHEN pageview_url = '/billing' OR pageview_url = '/billing-2'THEN 1 ELSE 0 END) AS billing_page,
	(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_page
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
) AS pageview_level
GROUP BY website_session_id;

SELECT * FROM pageviews_gsearch WHERE website_session_id < 100;

SELECT
	MONTH(website_pageviews.created_at),
	COUNT(DISTINCT CASE WHEN home = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END),
	COUNT(DISTINCT CASE WHEN product = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END),   
	COUNT(DISTINCT CASE WHEN mrfuzzy = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END),
	COUNT(DISTINCT CASE WHEN cart = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END),
	COUNT(DISTINCT CASE WHEN shipping = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END),
	COUNT(DISTINCT CASE WHEN billing = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END),
	COUNT(DISTINCT CASE WHEN thankyou = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END)
FROM pageviews_gsearch
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = pageviews_gsearch.website_session_id
GROUP BY MONTH(website_pageviews.created_at);


SELECT
	MONTH(website_pageviews.created_at),
	COUNT(DISTINCT CASE WHEN product = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN home = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END) AS to_product_rate,   
	COUNT(DISTINCT CASE WHEN mrfuzzy = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN product = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END) AS to_mrfuzz_rate,
	COUNT(DISTINCT CASE WHEN cart = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN mrfuzzy = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END) AS to_cart_rate,
	COUNT(DISTINCT CASE WHEN shipping = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN cart = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END) AS to_shipping_rate,
	COUNT(DISTINCT CASE WHEN billing = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN shipping = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END) AS to_billing_rate,
	COUNT(DISTINCT CASE WHEN thankyou = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN billing = 1 THEN pageviews_gsearch.website_session_id ELSE NULL END) AS to_thankyou_rate
FROM pageviews_gsearch
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = pageviews_gsearch.website_session_id
GROUP BY MONTH(website_pageviews.created_at);

SELECT
	MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY MONTH(website_sessions.created_at);
/*
5.	I’d like to tell the story of our website performance improvements over the course of the first 8 months. 
Could you pull session to order conversion rates, by month? 
*/ 

SELECT
	MONTH(orders.created_at) AS month_2012,
    COUNT(DISTINCT CASE WHEN thankyou = 1 THEN orders.order_id ELSE NULL END) AS ordered,
    COUNT(DISTINCT orders.website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN thankyou = 1 THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT orders.website_session_id) AS conversion_rate
FROM orders
	LEFT JOIN pageviews_gsearch
		ON orders.website_session_id = pageviews_gsearch.website_session_id
WHERE orders.created_at < '2012-11-27'
GROUP BY 1;

SELECT
	MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1;


/*
6.	For the gsearch lander test, please estimate the revenue that test earned us 
(Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use 
nonbrand sessions and revenue since then to calculate incremental value)
*/ 
CREATE TEMPORARY TABLE first_pageview
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY 1;

SELECT
	first_pageview.first_pageview_id,
    website_pageviews.pageview_url
FROM first_pageview
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageview.first_pageview_id;


SELECT
	WEEK(website_pageviews.created_at) AS week_2012,
    MIN(DATE(website_pageviews.created_at)) AS first_date_of_week,
	COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url = '/home' THEN first_pageview.first_pageview_id ELSE NULL END) AS home_landed_page,
	COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN first_pageview.first_pageview_id ELSE NULL END) AS lander_landed_page,
    COUNT(orders.order_id) AS total_orders,
    SUM(orders.price_usd) AS total_price
FROM first_pageview
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageview.first_pageview_id
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1;
    


/*
7.	For the landing page test you analyzed previously, it would be great to show a full conversion funnel 
from each of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28).
*/ 
CREATE TEMPORARY TABLE landing_page_test
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-07-19'
	AND website_sessions.created_at < '2012-07-28'
	AND website_sessions.utm_source = 'gsearch'
	AND website_Sessions.utm_campaign = 'nonbrand'
GROUP BY 1;
	
SELECT
	landing_page_test.first_pageview_id,
    website_pageviews.pageview_url
FROM landing_page_test
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = landing_page_test.first_pageview_id;
SELECT * FROM website_pageviews WHERE website_session_id < 100;

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

SELECT * FROM reach_page;

SELECT 
	CASE
		WHEN home = 1 THEN 'homepage'
        WHEN lander1 = 1 THEN 'lander1 page'
		ELSE 'uh oh.. check logic'
	END AS segment,
    COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product = 1 THEN website_session_id ELSE NULL END) AS product,
	COUNT(DISTINCT CASE WHEN mrfuzzy = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy,
	COUNT(DISTINCT CASE WHEN cart = 1 THEN website_session_id ELSE NULL END) AS cart,
	COUNT(DISTINCT CASE WHEN shipping = 1 THEN website_session_id ELSE NULL END) AS shipping,
	COUNT(DISTINCT CASE WHEN billing = 1 THEN website_session_id ELSE NULL END) AS billing,
	COUNT(DISTINCT CASE WHEN thankyou = 1 THEN website_session_id ELSE NULL END) AS thankyou
FROM reach_page
GROUP BY 1;

/*
8.	I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated 
from the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number 
of billing page sessions for the past month to understand monthly impact.
*/ 


SELECT
	WEEK(website_pageviews.created_at) AS week_2012,
    MIN(DATE(website_pageviews.created_at)) AS first_date_of_week,
	COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url = '/billing' THEN orders.order_id ELSE NULL END) AS first_billing_page,
	COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url = '/billing-2' THEN orders.order_id ELSE NULL END) AS second_billing_page,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(orders.price_usd) AS total_price
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at > '2012-09-10'
    AND website_sessions.created_at < '2012-11-10'
GROUP BY 1;



SELECT 
	MONTH(website_pageviews.created_at) AS month_2012,
    COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url = '/billing' THEN website_pageviews.website_session_id ELSE NULL END) AS billing_1,
	COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url = '/billing-2' THEN website_pageviews.website_session_id ELSE NULL END) AS billing_2
FROM website_pageviews 
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_pageviews.created_at < '2012-11-27'
GROUP BY 1;





