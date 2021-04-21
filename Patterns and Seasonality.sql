/*
Analyzing business patterns is about generating insights to help you maximize efficiency
and anticipate future trends

day of week: 0 = Mon, 1 = Tues,...
*/

SELECT
	website_session_id,
    created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS wkday,
    CASE
		WHEN WEEKDAY(created_at) = 0 THEN 'Monday'
        ELSE 'other_day'
	END AS clean_weekday,
    QUARTER(created_at) AS qtr

FROM website_sessions
WHERE website_session_id BETWEEN 150000 AND 155000;
    
    
    
    
    
    
    
    
    
    
    
    
    
    