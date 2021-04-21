USE mavenfuzzyfactory;

SELECT * FROM
	(SELECT *
    FROM website_sessions
    WHERE website_session_id <= 100) AS first_hundred;