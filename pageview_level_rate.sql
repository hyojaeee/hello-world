SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_sessions.created_at,
    (CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END) AS products_page,
	(CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_page,
    (CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page,
    (CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_page,
    (CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_page,
    (CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05';

CREATE TEMPORARY TABLE clicked
SELECT
	website_session_id,
    MAX(products_page) AS products_clicked,
    MAX(mrfuzzy_page) AS mrfuzzy_clicked,
    MAX(cart_page) AS cart_clicked,
    MAX(shipping_page) AS shipping_clicked,
    MAX(billing_page) AS billing_clicked,
    MAX(thankyou_page) AS thankyou_clicked
FROM(
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_sessions.created_at,
    (CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END) AS products_page,
	(CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_page,
    (CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page,
    (CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_page,
    (CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_page,
    (CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
) AS pageview_level
GROUP BY website_session_id;

SELECT * FROM clicked;

SELECT 
	COUNT(DISTINCT website_session_id),
    COUNT(DISTINCT CASE WHEN products_clicked = 1 THEN website_session_id ELSE NULL END) AS products,
	COUNT(DISTINCT CASE WHEN mrfuzzy_clicked = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy,
	COUNT(DISTINCT CASE WHEN cart_clicked = 1 THEN website_session_id ELSE NULL END) AS cart,
	COUNT(DISTINCT CASE WHEN shipping_clicked = 1 THEN website_session_id ELSE NULL END) AS shipping,
	COUNT(DISTINCT CASE WHEN billing_clicked = 1 THEN website_session_id ELSE NULL END) AS billing,
	COUNT(DISTINCT CASE WHEN thankyou_clicked = 1 THEN website_session_id ELSE NULL END) AS thankyou
FROM clicked;

-- pageview level rate
SELECT 
	-- COUNT(DISTINCT website_session_id),
    COUNT(DISTINCT CASE WHEN products_clicked = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT website_session_id) AS lander_click_rate,
	COUNT(DISTINCT CASE WHEN mrfuzzy_clicked = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN products_clicked = 1 THEN website_session_id ELSE NULL END) AS product_click_rate,
	COUNT(DISTINCT CASE WHEN cart_clicked = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN mrfuzzy_clicked = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rate,
	COUNT(DISTINCT CASE WHEN shipping_clicked = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN cart_clicked = 1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
	COUNT(DISTINCT CASE WHEN billing_clicked = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN shipping_clicked = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
	COUNT(DISTINCT CASE WHEN thankyou_clicked = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN billing_clicked = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate
FROM clicked




