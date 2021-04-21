CREATE TEMPORARY TABLE step_one
SELECT 
	website_sessions.website_session_id,
    MIN(website_pageview_id) AS firstview
FROM website_sessions
INNER JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE 
	website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_pageviews.pageview_url IN ('/home', '/lander-1')
GROUP BY website_sessions.website_session_id;

-- session with landing page
CREATE TEMPORARY TABLE step_two
SELECT
	step_one.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM step_one
LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = step_one.firstview;

CREATE TEMPORARY TABLE step_three
SELECT
	step_two.website_session_id,
    step_two.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages
FROM step_two
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = step_two.website_session_id
GROUP BY
	step_two.website_session_id,
    step_two.landing_page
HAVING count_of_pages = 1;
    

SELECT
	step_two.landing_page,
	COUNT(DISTINCT step_two.website_session_id) AS total_sessions,
    COUNT(DISTINCT step_three.website_session_id) AS bounce_sessions
FROM step_two
LEFT JOIN step_three
	ON step_three.website_session_id = step_two.website_session_id
GROUP BY step_two.landing_page;   


SELECT
	MIN(DATE(website_pageviews.created_at)) AS week_start_date,
    COUNT(DISTINCT step_three.website_session_id) / COUNT(DISTINCT step_two.website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url = '/home' THEN step_two.website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN step_two.website_session_id ELSE NULL END) AS lander_sessions
    -- COUNT(DISTINCT step_two.website_session_id) AS total_sessions,
    -- COUNT(DISTINCT step_three.website_session_id) AS bounce_sessions
FROM step_two
LEFT JOIN step_three
	ON step_three.website_session_id = step_two.website_session_id
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = step_two.website_session_id
GROUP BY WEEK(website_pageviews.created_at);
    
/* Time calculation brainstorming   
SELECT
	created_at,
    WEEK(created_at),
    MIN(DATE(created_at))
FROM website_pageviews
WHERE website_session_id < 100
GROUP BY 1;
*/