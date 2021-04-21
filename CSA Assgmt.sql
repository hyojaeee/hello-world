/*
Step 1. set up time period (pre cross sell and post cross sell) which is +- 1 month 09/25/13
Step 2. cart_session 
Step 3. clickthrough rates from the /cart page
Step 4. average products per order
Step 5. AOV
Step 6. overall revenue per /cart page view
*/

-- SELECT DISTINCT pageview_url FROM session_w_url_w_time_period; -- pageview_url names
-- order_items.is_primary_item = 0 --> cross selling 

CREATE TEMPORARY TABLE time_periods_for_all
SELECT
	-- order_id,
    website_session_id,
    created_at,
    CASE
		WHEN created_at >= '2013-08-25' AND created_at < '2013-09-25' THEN 'Pre-cross sell'  
        WHEN created_at >= '2013-09-25' AND created_at <= '2013-10-25' THEN 'Post-cross sell' 
		ELSE 'Error'
	END AS time_period
FROM website_sessions
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25';

CREATE TEMPORARY TABLE session_w_url_w_time_periods
SELECT
	website_pageviews.website_session_id,
    website_pageviews.created_at,
	website_pageviews.pageview_url,
    time_periods_for_all.time_period
FROM website_pageviews
LEFT JOIN time_periods_for_all
	ON time_periods_for_all.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at BETWEEN '2013-08-25' AND '2013-10-25';


SELECT
	website_pageviews.website_session_id,
	CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping,
    CASE WHEN website_pageviews.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou
FROM website_pageviews
LEFT JOIN session_w_url_w_time_periods
	ON session_w_url_w_time_periods.website_session_id = website_pageviews.website_session_id;

CREATE TEMPORARY TABLE session_with_reach_page
SELECT
	website_session_id,
    MAX(cart) AS cart,
    MAX(shipping) AS shipping,
    MAX(billing) AS billing,
    MAX(thankyou) AS thankyou
FROM (
SELECT
	website_pageviews.website_session_id,
	CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping,
    CASE WHEN website_pageviews.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou
FROM website_pageviews
LEFT JOIN session_w_url_w_time_periods
	ON session_w_url_w_time_periods.website_session_id = website_pageviews.website_session_id
) AS reached_url
GROUP BY 1;


SELECT
	time_periods_for_all.time_period,
    COUNT(DISTINCT CASE WHEN cart = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS cart_sessions,
	COUNT(DISTINCT CASE WHEN shipping = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS clickthroughs,
	COUNT(DISTINCT CASE WHEN shipping = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN cart = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS cart_ctr,
	SUM(items_purchased)/COUNT(DISTINCT orders.website_session_id) AS avg_product_per_order,
    SUM(price_usd)/COUNT(DISTINCT order_id) AS AOV,
    SUM(price_usd)/COUNT(DISTINCT CASE WHEN cart = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS revenue_per_cart_session
FROM time_periods_for_all
LEFT JOIN session_with_reach_page
	ON time_periods_for_all.website_session_id = session_with_reach_page.website_session_id
LEFT JOIN orders
	ON time_periods_for_all.website_session_id = orders.website_session_id
GROUP BY 1;

-- average product per order/ AOV (avg order value = revenue/# orders)/ Revenue per cart session = revenue/cart
SELECT 
	SUM(items_purchased) / COUNT(DISTINCT website_session_id) AS avg_product_per_order,
	SUM(price_usd) / COUNT(DISTINCT order_id) AS AOV
FROM orders WHERE order_id < 20;

SELECT * FROM orders WHERE order_id < 20;











