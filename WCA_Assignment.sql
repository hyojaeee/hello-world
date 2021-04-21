SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY pvs DESC;

SELECT * FROM website_pageviews WHERE website_session_id < 100;

CREATE TEMPORARY TABLE first_landing
SELECT 
	MIN(website_pageview_id) AS session_hitting_this_landing_page,
    website_session_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY 2;

SELECT * FROM first_landing;

SELECT
	pageview_url AS landing_page_url,
    COUNT(DISTINCT first_landing_0614.website_session_id) AS count_of_sessions
FROM first_landing_0614
LEFT JOIN website_pageviews
	ON first_landing_0614.session_hitting_this_landing_page = website_pageviews.website_pageview_id
GROUP BY pageview_url;

-- session/bounce session/bounce rate


-- landing page
CREATE TEMPORARY TABLE first_pageviews
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-06-14'
GROUP BY website_pageviews.website_session_id;

SELECT * FROM first_pageviews;

-- session with url
CREATE TEMPORARY TABLE session_with_landing_page
SELECT
	first_pageviews.website_session_id,
	website_pageviews.pageview_url AS landing_page
FROM first_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id;
        
SELECT * FROM session_with_landing_page;

-- bounce session
CREATE TEMPORARY TABLE bounced_sessions
SELECT
	session_with_landing_page.website_session_id,
	session_with_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM session_with_landing_page
	LEFT JOIN website_pageviews
		ON session_with_landing_page.website_session_id = website_pageviews.website_session_id
GROUP BY 
	session_with_landing_page.website_session_id,
	session_with_landing_page.landing_page
HAVING COUNT(website_pageviews.website_pageview_id) = 1;


SELECT
	session_with_landing_page.landing_page,
	session_with_landing_page.website_session_id,
    bounced_sessions.website_session_id
FROM session_with_landing_page
	LEFT JOIN bounced_sessions
		ON bounced_sessions.website_session_id = session_with_landing_page.website_session_id
ORDER BY session_with_landing_page.website_session_id;


SELECT
	session_with_landing_page.landing_page,
	COUNT(DISTINCT session_with_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT session_with_landing_page.website_session_id) AS bounce_rate
FROM session_with_landing_page
	LEFT JOIN bounced_sessions
		ON bounced_sessions.website_session_id = session_with_landing_page.website_session_id
GROUP BY session_with_landing_page.landing_page; 


