USE mavenfuzzyfactory;

/* Channel Portfolio optimization
Analyzing a portfolio of marketing channels is about bidding efficiently and using
data to maximize the effectiveness of your marketing budget
*/

SELECT DISTINCT utm_source, utm_campaign
FROM website_sessions;

SELECT
	utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conversion_rate -- aka 'conversion rate'

FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 1
ORDER BY sessions DESC;

-- Analyzing direct, brand-driven traffic

SELECT 
    CASE 
		WHEN http_referer IS NULL THEN 'direct_type_in'
        WHEN http_referer = 'https://www.gsearch.com' THEN 'gsearch_organic'
        WHEN http_referer = 'https://www.bsearch.com' THEN 'bsearch_organic'
        ELSE 'Other'
	END AS kind,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
	AND utm_source IS NULL
GROUP BY 1
ORDER BY 2 DESC;









