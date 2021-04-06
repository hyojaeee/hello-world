SELECT
	is_repeat_session,
    COUNT(DISTINCT user_id)
FROM website_sessions
WHERE created_at >= '2014-01-01' 
	AND created_at < '2014-11-01'
GROUP BY 1;

SELECT
	website_session_id,
	user_id,
	CASE 
		WHEN COUNT(DISTINCT user_id) = 0 THEN '0' 
		WHEN COUNT(DISTINCT user_id) = 1 THEN '1' 
		WHEN COUNT(DISTINCT user_id) = 2 THEN '2' 
		WHEN COUNT(DISTINCT user_id) = 3 THEN '3'
        ELSE 'error'
	END AS repeated
FROM website_sessions
WHERE created_at >= '2014-01-01' 
	AND created_at < '2014-11-01'
GROUP BY 1;

CREATE TEMPORARY TABLE count_repeat_sessions
SELECT
	user_id,
    COUNT(DISTINCT website_session_id) AS session_count
FROM website_sessions
WHERE created_at >= '2014-01-01' 
	AND created_at < '2014-11-01'
GROUP BY 1;

SELECT
	session_count,
	COUNT(DISTINCT CASE WHEN session_count = 1 THEN user_id ELSE NULL END) AS '0',
    COUNT(DISTINCT CASE WHEN session_count = 2 THEN user_id ELSE NULL END) AS '1',
    COUNT(DISTINCT CASE WHEN session_count = 3 THEN user_id ELSE NULL END) AS '2',
    COUNT(DISTINCT CASE WHEN session_count = 4 THEN user_id ELSE NULL END) AS '3'
FROM count_repeat_sessions
GROUP BY 1;
    
SELECT
	session_count,
	CASE
		WHEN session_count = 1 THEN COUNT(DISTINCT user_id)
        WHEN session_count = 2 THEN COUNT(DISTINCT user_id)
        WHEN session_count = 3 THEN COUNT(DISTINCT user_id)
        WHEN session_count = 4 THEN COUNT(DISTINCT user_id)
        ELSE 'error'
	END AS users
FROM count_repeat_sessions
GROUP BY 1;


-- repeated user_id created_at
CREATE TEMPORARY TABLE user_id_with_time
SELECT
	user_id,
    website_session_id,
    created_at
FROM website_sessions
WHERE created_at >= '2014-01-01' 
	AND created_at < '2014-11-01'
    AND is_repeat_session = 1
ORDER BY user_id;


SELECT
	user_id,
	DATEDIFF(MAX(user_id_with_time.created_at),MIN(user_id_with_time.created_at)) AS date_diff
FROM user_id_with_time
GROUP BY user_id;
    
    
SELECT
	MIN(date_diff) AS min_days_diff,
    AVG(date_diff) AS avg_days_diff,
    MAX(date_diff) AS max_days_diff
FROM(
	SELECT
		user_id,
		DATEDIFF(MAX(user_id_with_time.created_at),MIN(user_id_with_time.created_at)) AS date_diff
	FROM user_id_with_time
	GROUP BY user_id
)AS time_difference;
    
    
-- Correct Way to solve time difference
/*
Step 1. Identify the relevant new sessions
Step 2. User the user_id values from Step 1 to find any repeat sessions those users had
Step 3. Find the created_at times for first and second sessions
Step 4. Find the differences between first and second sessions at a user level
Step 5. Aggregate the user level data to find the average, min, max
*/

CREATE TEMPORARY TABLE sessions_w_repeats_for_time_diff
SELECT
	new_sessions.user_id,
	new_sessions.website_session_id AS new_session_id,
	new_sessions.created_at AS new_session_created_at,
	website_sessions.website_session_id AS repeat_session_id,
	website_sessions.created_at AS repeat_session_created_at
FROM(
SELECT
	user_id,
    website_session_id,
    created_at
FROM website_sessions
WHERE created_at < '2014-11-03'
	AND created_at> '2014-01-01'
    AND is_repeat_session = 0
) AS new_sessions
LEFT JOIN website_sessions
	ON website_sessions.user_id = new_sessions.user_id
		AND website_sessions.is_repeat_session = 1
        AND website_sessions.website_session_id > new_sessions.website_session_id
		AND website_sessions.created_at < '2014-11-03'
		AND website_sessions.created_at> '2014-01-01';
        
CREATE TEMPORARY TABLE users_first_to_second
SELECT
	user_id,
    DATEDIFF(second_session_created_at, new_session_created_at) AS days_first_to_second_session
FROM(
SELECT
	user_id,
    new_session_id,
    new_session_created_at,
    MIN(repeat_session_id) AS second_session_id,
    MIN(repeat_session_created_at) AS second_session_created_at
FROM sessions_w_repeats_for_time_diff
WHERE repeat_session_id IS NOT NULL
GROUP BY 1,2,3
) AS first_second;


SELECT
	AVG(days_first_to_second_session) AS avg_days_first_to_second,
    MIN(days_first_to_second_session) AS min_days_first_to_second,
    MAX(days_first_to_second_session) AS max_days_first_to_second
FROM users_first_to_second;



-- Step 1. Repeat vs new
-- Step 2. utm_source CASE WHEN phrase

CREATE TEMPORARY TABLE new_with_repeat_session
SELECT
	new_sessions.user_id,
	new_sessions.website_session_id AS new_session_id,
	website_sessions.website_session_id AS repeat_session_id
FROM(
SELECT
	user_id,
    website_session_id,
    created_at
FROM website_sessions
WHERE created_at < '2014-11-05'
	AND created_at> '2014-01-01'
    AND is_repeat_session = 0
) AS new_sessions
LEFT JOIN website_sessions
	ON website_sessions.user_id = new_sessions.user_id
		AND website_sessions.is_repeat_session = 1
        AND website_sessions.website_session_id > new_sessions.website_session_id
		AND website_sessions.created_at < '2014-11-05'
		AND website_sessions.created_at> '2014-01-01';

SELECT
	CASE 
		WHEN utm_source IN ('gsearch','bsearch') AND utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IN ('gsearch','bsearch') AND utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
		WHEN utm_source = 'socialbook' THEN 'paid_social'
        WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
		WHEN http_referer IS NULL THEN 'direct_type_in'
		ELSE 'error'
	END AS channl_group,
    COUNT(DISTINCT new_with_repeat_session.new_session_id) AS new_session,
    COUNT(DISTINCT new_with_repeat_session.repeat_session_id) AS repeat_session
FROM website_sessions
LEFT JOIN new_with_repeat_session
	ON new_with_repeat_session.user_id = website_sessions.user_id
GROUP BY 1;
    

-- shorter version
SELECT
	CASE
        WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
		WHEN utm_campaign = 'brand' THEN 'paid_brand'
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
		WHEN utm_source = 'socialbook' THEN 'paid_social'
	END AS channel_group,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at < '2014-11-05'
	AND created_at >= '2014-01-01'
GROUP BY 1;

-- conversion rate, revenue per session, repeat vs new
SELECT
	website_sessions.is_repeat_session,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(price_usd) AS revenue,
    SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at >= '2014-01-01'
	AND website_sessions.created_at < '2014-11-08'
GROUP BY 1;






    
-- SELECT DISTINCT utm_source, utm_campaign, http_referer FROM website_sessions
-- utm_source IN ('gsearch','bsearch') AND utm_campaign = 'brand' THEN 'paid_brand'
-- utm_source IN ('gsearch','bsearch') AND utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
-- utm_source = 'socialbook' THEN 'paid_social'
-- http_referer IS NULL THEN 'direct_type_in'
-- utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
