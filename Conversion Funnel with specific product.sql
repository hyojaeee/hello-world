-- 1. find website sessions with each products
-- 2. pageview url with each product
-- 3. 1 or 0
-- 4. max
-- 5. Summarize Data

CREATE TEMPORARY TABLE session_with_pageview_products
SELECT
	website_session_id,
    website_pageview_id
FROM website_pageviews
WHERE created_at > '2013-01-06'
	AND created_at < '2014-04-10'
	AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear');

CREATE TEMPORARY TABLE pageview_url_with_id
SELECT
	session_with_pageview_products.website_pageview_id,
	website_pageviews.pageview_url
FROM session_with_pageview_products
LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = session_with_pageview_products.website_pageview_id;
    

-- SELECT DISTINCT pageview_url FROM website_pageviews;

SELECT
	website_session_id,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping,
    CASE WHEN pageview_url = '/billing' OR pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou
FROM website_pageviews
WHERE created_at > '2013-01-06'
	AND created_at < '2014-04-10';

CREATE TEMPORARY TABLE session_with_reach_page
SELECT
	website_session_id,
    MAX(cart) AS cart,
    MAX(shipping) AS shipping,
    MAX(billing) AS billing,
    MAX(thankyou) AS thankyou
FROM(
SELECT
	website_session_id,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping,
    CASE WHEN pageview_url = '/billing' OR pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou
FROM website_pageviews
WHERE created_at > '2013-01-06'
	AND created_at < '2014-04-10'
) AS reach_page
GROUP BY 1;


SELECT
	website_pageviews.pageview_url,
    COUNT(DISTINCT session_with_reach_page.website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN cart = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS to_thankyou
FROM session_with_reach_page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = session_with_reach_page.website_session_id
WHERE website_pageviews.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
	AND created_at > '2013-01-06'
	AND created_at < '2013-04-10'
GROUP BY 1;


SELECT
	website_pageviews.pageview_url,
    COUNT(DISTINCT CASE WHEN cart = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) 
		/COUNT(DISTINCT session_with_reach_page.website_session_id) AS clicked_to_cart_rt,
	COUNT(DISTINCT CASE WHEN shipping = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN cart = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS clicked_to_shipping_rt,
	COUNT(DISTINCT CASE WHEN billing = 1 THEN session_with_reach_page.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN shipping = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS clicked_to_billing_rt,
    COUNT(DISTINCT CASE WHEN thankyou = 1 THEN session_with_reach_page.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN billing = 1 THEN session_with_reach_page.website_session_id ELSE NULL END) AS clicked_to_thankyou_rt
FROM session_with_reach_page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = session_with_reach_page.website_session_id
WHERE website_pageviews.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
	AND created_at > '2013-01-06'
	AND created_at < '2013-04-10'
GROUP BY 1;
        
        
        