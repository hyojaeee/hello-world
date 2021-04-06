-- gsearch nonbrand vs. bsearch 2012-08-22 to 2012-11-29 wkly trend session volume

SELECT * 
FROM website_sessions 
WHERE website_session_id < 10;

SELECT 
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE website_sessions.created_at > '2012-08-22' 
	AND website_sessions.created_at <'2012-11-29'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);   


-- 08/22 to 11/30 pct traffic from mobile
SELECT 
	utm_source,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
	-- COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
GROUP BY 1;


-- 08/22 to 09/18 order conv_rate for different device type and different utm_source
SELECT
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-18'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2;


-- 11/4 to 12/22 weekly bsearch of gsearch pct by device
SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_desktop,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_desktop,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS pct_b_of_g_desktop,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_mobile,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_mobile,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS pct_b_of_g_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-11-04' AND '2012-12-22'
	AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);


-- beginning to 12/23, organic search/direct type in/paid traffic by month, pct of paid nonbrand

SELECT 
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) AS brand,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct_type_in,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
    COUNT(DISTINCT CASE WHEN http_referer = 'https://www.gsearch.com' OR 'https://www.bsearch.com' THEN website_session_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN http_referer = 'https://www.gsearch.com' OR 'https://www.bsearch.com' THEN website_session_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand

FROM website_sessions
WHERE created_at < '2012-12-23'
GROUP BY 1,2;

SELECT
	*,
    CASE
		WHEN utm_campaign = 'nonbrand' THEN 'nonbrand'
        WHEN utm_campaign = 'brand' THEN 'brand'
        WHEN http_referer IS NULL THEN 'direct_type_in'
        WHEN http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
        ELSE 'other'
	END AS channel_route
FROM website_sessions;

SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) AS direct_type_in,
    COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS orgnic_pct_nonbrand
FROM (
SELECT
	website_session_id,
    created_at,
    CASE
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
        ELSE 'other'
	END AS channel_group
FROM website_sessions
WHERE created_at < '2012-12-23'
) AS session_w_channel_group
GROUP BY 
	YEAR(created_at),
    MONTH(created_at);





