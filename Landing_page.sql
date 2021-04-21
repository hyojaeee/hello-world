CREATE TEMPORARY TABLE base
SELECT 
	website_sessions.website_session_id,
    website_pageviews.website_pageview_id,
    website_pageviews.pageview_url
FROM website_sessions
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';

-- To find when /lander-1 was getting traffic
SELECT
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL;


CREATE TEMPORARY TABLE first_landing_page
SELECT
	base.website_session_id,
    MIN(base.website_pageview_id) AS min_pgv_id
FROM base
GROUP BY base.website_session_id;

CREATE TEMPORARY TABLE session_with_landing_page2
SELECT
	first_landing_page.website_session_id,
    website_pageviews.pageview_url
FROM first_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_landing_page.min_pgv_id;
-- WHERE website_pageviews.pageview_url IN ('/home', '/lander-1') 
-- this is not a must, but recommended for future analysis to make sure we're focusing on specific pages

-- SELECT * FROM session_with_landing_page2;

CREATE TEMPORARY TABLE bounced
SELECT
	session_with_landing_page2.website_session_id,
    session_with_landing_page2.pageview_url,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages
FROM session_with_landing_page2
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = session_with_landing_page2.website_session_id
GROUP BY
	session_with_landing_page2.website_session_id,
    session_with_landing_page2.pageview_url
HAVING count_of_pages = 1;

-- SELECT * FROM bounced;

SELECT
	session_with_landing_page2.pageview_url,
    session_with_landing_page2.website_session_id AS sessions,
    bounced.website_session_id AS bounced_sessions
FROM session_with_landing_page2
	LEFT JOIN bounced
		ON bounced.website_session_id = session_with_landing_page2.website_session_id
ORDER BY session_with_landing_page2.website_session_id;



SELECT
	session_with_landing_page2.pageview_url,
    COUNT(DISTINCT session_with_landing_page2.website_session_id) AS total_sessions,
    COUNT(DISTINCT bounced.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced.website_session_id) / COUNT(DISTINCT session_with_landing_page2.website_session_id) AS bounce_rate
FROM session_with_landing_page2
	LEFT JOIN bounced
		ON bounced.website_session_id = session_with_landing_page2.website_session_id
GROUP BY
	session_with_landing_page2.pageview_url;








