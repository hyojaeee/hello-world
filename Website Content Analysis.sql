USE mavenfuzzyfactory;

SELECT * FROM website_pageviews WHERE website_pageview_id < 100;

SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY pvs DESC;

CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;

SELECT * FROM first_pageview;

SELECT 
	-- first_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page, -- AKA entry page
    COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
	ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY landing_page;
    

SELECT * FROM first_pageview LEFT JOIN website_pageviews ON
first_pageview.min_pv_id = website_pageviews.website_pageview_id;

-- BUSINESS CONTEXT: we want to see landing page performance for a certain time period
-- STEP1: find the first website_pageview_id for relevant sessions
-- STEP2: identify the landing page of each session
-- STEP3: counting pageviews for each session, to identify "bounces"
-- STEP4: summarizing total sessions and bounced sessions, by LP (Landing Page)

-- finding the minimum website pageview id associated with each session we care about
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
	website_pageviews.website_session_id;

-- same query as above, but this time we are storing the dataset as a temporary table
CREATE TEMPORARY TABLE first_pageviews_demo
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
	website_pageviews.website_session_id;

-- next, we'll bring in the landing page to each session
CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT
	first_pageviews_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pageview_id;  -- website pageview is the landing page

SELECT * FROM sessions_w_landing_page_demo;  -- QA only

-- next, we make a table to include a count of pageviews per session

-- first, show all the sessions. Then we will limit to bounced sessions and create a temp table

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page_demo
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_w_landing_page_demo.website_session_id
GROUP BY
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;

SELECT
	sessions_w_landing_page_demo.landing_page,
    sessions_w_landing_page_demo.website_session_id,
    bounced_sessions_only.website_session_id AS bounced_website_session_id
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
ORDER BY
	sessions_w_landing_page_demo.website_session_id;

-- final output
-- we will use the same query we previously ran, and run a count of records
-- we will group by landing page, and then we'll add a bounce rate column

SELECT
	sessions_w_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id)/COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS bounce_rate
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
GROUP BY sessions_w_landing_page_demo.landing_page;