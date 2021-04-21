-- finding billing-2 first usage
SELECT
    MIN(website_sessions.created_at),
    website_pageviews.pageview_url,
    website_pageviews.website_pageview_id
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE pageview_url = '/billing-2'
GROUP BY website_pageview_id;

SELECT
	website_session_id,
    (CASE WHEN pageview_url = '/billing' OR pageview_url = '/billing-2' THEN 1 ELSE 0 END) AS billing,
    -- (CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END) AS billing_one,
    (CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS order_completed
FROM website_pageviews
WHERE created_at BETWEEN '2012-09-10' AND '2012-11-10';
-- Use Orders tables for order_id

CREATE TEMPORARY TABLE billing_page
SELECT
	website_session_id,
    MAX(billing) AS billing,
    -- MAX(billing_one) AS billing_one,
    MAX(order_completed) AS thankyou_page
FROM (
SELECT
	website_session_id,
    (CASE WHEN pageview_url = '/billing' OR pageview_url = '/billing-2' THEN 1 ELSE 0 END) AS billing,
    -- (CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END) AS billing_one,
    (CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS order_completed
FROM website_pageviews
WHERE created_at BETWEEN '2012-09-10' AND '2012-11-10'
) AS pageview_level
GROUP BY website_session_id;

-- SELECT * FROM billing_page;

SELECT
	pageview_url,
    COUNT(DISTINCT CASE WHEN billing = 1 THEN billing_page.website_session_id ELSE NULL END) AS sessions,
    COUNT(DISTINCT CASE WHEN thankyou_page = 1 THEN billing_page.website_session_id ELSE NULL END) AS orders,
    COUNT(DISTINCT CASE WHEN thankyou_page = 1 THEN billing_page.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN billing = 1 THEN billing_page.website_session_id ELSE NULL END) AS rate
FROM billing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = billing_page.website_session_id
WHERE pageview_url IN ('/billing', '/billing-2')
GROUP BY pageview_url;





