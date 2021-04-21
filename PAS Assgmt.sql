-- 2012's trends session and orders

-- by month
SELECT
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 1,2;

-- by week
SELECT
	MIN(DATE(website_sessions.created_at)) AS week_start_date,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 
	WEEK(website_sessions.created_at);


-- by hour and by day of week avg range 09/15 to 11/15
SELECT
	website_session_id,
    created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS day_of_week,
	CASE
		WHEN WEEKDAY(created_at) = 0 THEN 'Mon'
        WHEN WEEKDAY(created_at) = 1 THEN 'Tue'
        WHEN WEEKDAY(created_at) = 2 THEN 'Wed'
        WHEN WEEKDAY(created_at) = 3 THEN 'Thu'
        WHEN WEEKDAY(created_at) = 4 THEN 'Fri'
        WHEN WEEKDAY(created_at) = 5 THEN 'Sat'
        WHEN WEEKDAY(created_at) = 6 THEN 'Sun'
		ELSE 'Error'
	END AS clean_day
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15';


SELECT
	HOUR(created_at) AS hr,
    COUNT(DISTINCT CASE WHEN clean_day = 'Mon' THEN website_session_id ELSE NULL END) AS mon,
    COUNT(DISTINCT CASE WHEN clean_day = 'Tue' THEN website_session_id ELSE NULL END) AS tue,
    COUNT(DISTINCT CASE WHEN clean_day = 'Wed' THEN website_session_id ELSE NULL END) AS wed,
    COUNT(DISTINCT CASE WHEN clean_day = 'Thu' THEN website_session_id ELSE NULL END) AS thu,
    COUNT(DISTINCT CASE WHEN clean_day = 'Fri' THEN website_session_id ELSE NULL END) AS fri,
    COUNT(DISTINCT CASE WHEN clean_day = 'Sat' THEN website_session_id ELSE NULL END) AS sat,
    COUNT(DISTINCT CASE WHEN clean_day = 'Sun' THEN website_session_id ELSE NULL END) AS sun
FROM 
(
SELECT
	website_session_id,
    created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS day_of_week,
	CASE
		WHEN WEEKDAY(created_at) = 0 THEN 'Mon'
        WHEN WEEKDAY(created_at) = 1 THEN 'Tue'
        WHEN WEEKDAY(created_at) = 2 THEN 'Wed'
        WHEN WEEKDAY(created_at) = 3 THEN 'Thu'
        WHEN WEEKDAY(created_at) = 4 THEN 'Fri'
        WHEN WEEKDAY(created_at) = 5 THEN 'Sat'
        WHEN WEEKDAY(created_at) = 6 THEN 'Sun'
		ELSE 'Error'
	END AS clean_day
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'

) AS seee
GROUP BY HOUR(created_at);

SELECT
	hr,
    ROUND(AVG(website_sessions),1) AS avg_sessions,
    ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END),1) AS mon,
    ROUND(AVG(CASE WHEN wkday = 1 THEN website_sessions ELSE NULL END),1) AS tue,
    ROUND(AVG(CASE WHEN wkday = 2 THEN website_sessions ELSE NULL END),1) AS wed,
    ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END),1) AS thu,
    ROUND(AVG(CASE WHEN wkday = 4 THEN website_sessions ELSE NULL END),1) AS fri,
    ROUND(AVG(CASE WHEN wkday = 5 THEN website_sessions ELSE NULL END),1) AS sat,
    ROUND(AVG(CASE WHEN wkday = 6 THEN website_sessions ELSE NULL END),1) AS sun
FROM(
SELECT
	DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3
) AS weekly_avg_sessions
GROUP BY 1;








