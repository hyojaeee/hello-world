-- Look into the data quick view
SELECT * FROM cleveland_booking_logs
ORDER BY `Created At`
LIMIT 20;

SELECT DISTINCT `Action` FROM cleveland_booking_logs;

SELECT COUNT(DISTINCT `Facility ID`) FROM cleveland_booking_logs;

SELECT 
	COUNT(ID) AS `Unique shifts`
FROM cleveland_booking_logs;

SELECT * FROM cleveland_cancel_logs
LIMIT 20;

SELECT DISTINCT `Action` FROM cleveland_cancel_logs; 

SELECT `Worker ID`, COUNT(*), `Action`
FROM cleveland_cancel_logs
GROUP BY `Worker ID`, `Action`
ORDER BY COUNT(*) DESC;

SELECT * FROM cleveland_cancel_logs
WHERE `Worker ID` = '60d5f8cfdcb29f016634d66f'
ORDER BY `Lead Time`;



SELECT DISTINCT `Agent Req` FROM cleveland_shifts;
SELECT `Agent Req`, COUNT(`Agent Req`) FROM cleveland_shifts
GROUP BY `Agent Req`;

-- Facility where deleted the most counted 
SELECT 
	COUNT(*) AS `Number of counts`, 
    `Facility ID`
FROM cleveland_shifts
WHERE `Deleted` = 'TRUE'
GROUP BY `Facility ID`
ORDER BY 1 DESC;

SELECT *
FROM cleveland_shifts
WHERE `Deleted` = 'TRUE';

SELECT 
	COUNT(DISTINCT ID) AS `Unique HCF Delete Counts`,
	MIN(`Created At`) AS `Date From`,
    MAX(`Created At`) AS `Date To`
FROM cleveland_shifts
WHERE `Deleted` = 'TRUE';

SELECT 
	COUNT(DISTINCT CASE WHEN `Deleted` = 'TRUE' THEN ID ELSE NULL END) AS 'Deleted Counts',
    COUNT(DISTINCT ID) AS 'Total Counts',
	COUNT(DISTINCT CASE WHEN `Deleted` = 'TRUE' THEN ID ELSE NULL END)/COUNT(DISTINCT ID) * 100 AS 'Deleted Rate'
FROM cleveland_shifts;

SELECT 
	`Agent Req`,
	COUNT(*) AS `Number of Counts`
FROM cleveland_shifts
WHERE `Deleted` = 'TRUE'
GROUP BY `Agent Req`
ORDER BY 2 DESC;

SELECT 
	`Created At`,
    `Shift Start Logs`,
	TIMEDIFF(`Shift Start Logs`, `Created At`) AS time_difference
FROM cleveland_cancel_logs;

SELECT *
FROM cleveland_cancel_logs;

SELECT
	COUNT(DISTINCT ID) AS `Unique HCP Cancellation Counts`,
	MIN(`Created At`) AS `Date From`,
    MAX(`Created At`) AS `Date To`
FROM cleveland_cancel_logs;

SELECT 
	MIN(`Shift Start Logs`),
    MAX(`Shift Start Logs`)
FROM cleveland_cancel_logs;

-- how significant is lead time affect action of NCNS or WC?
SELECT 
	COUNT(DISTINCT CASE WHEN `Lead Time` < 0 THEN ID ELSE NULL END) AS `Negative Value`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 0 AND `Lead Time` <= 24 THEN ID ELSE NULL END) AS `1 Day`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 24 AND `Lead Time` <= 48 THEN ID ELSE NULL END) AS `2 Day`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 48 AND `Lead Time` <= 72 THEN ID ELSE NULL END) AS `3 Day`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 72 AND `Lead Time` <= 168 THEN ID ELSE NULL END) AS `1 Week`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 168 THEN ID ELSE NULL END) AS `Over a week`
FROM cleveland_cancel_logs;

SELECT 
	COUNT(DISTINCT CASE WHEN `Lead Time` < 0 THEN ID ELSE NULL END) AS `Negative Value`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 0 AND `Lead Time` <= 24 THEN ID ELSE NULL END) AS `1 Day`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 24 AND `Lead Time` <= 48 THEN ID ELSE NULL END) AS `2 Day`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 48 AND `Lead Time` <= 72 THEN ID ELSE NULL END) AS `3 Day`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 72 AND `Lead Time` <= 168 THEN ID ELSE NULL END) AS `1 Week`,
    COUNT(DISTINCT CASE WHEN `Lead Time` > 168 THEN ID ELSE NULL END) AS `Over a week`
FROM cleveland_booking_logs;

SELECT *
FROM cleveland_booking_logs
ORDER BY `Created At` DESC;

-- JOIN cancel logs and shifts
SELECT 
	COUNT(DISTINCT cleveland_shifts.ID) AS Unique_shifts,
	COUNT(cleveland_cancel_logs.ID) AS Cancelled_case
FROM cleveland_shifts
LEFT JOIN cleveland_cancel_logs
ON cleveland_shifts.ID = cleveland_cancel_logs.ID;

-- LC and NCNS rates
SELECT
	COUNT(DISTINCT CASE WHEN `Action` = 'WORKER_CANCEL' THEN ID ELSE NULL END) AS 'Late Cancellations',
    COUNT(DISTINCT CASE WHEN `Action` = 'NO_CALL_NO_SHOW' THEN ID ELSE NULL END) AS 'NCNS',
    COUNT(DISTINCT CASE WHEN `Action` = 'WORKER_CANCEL' THEN ID ELSE NULL END)/COUNT(ID) * 100 AS 'LC Rate',
    COUNT(DISTINCT CASE WHEN `Action` = 'NO_CALL_NO_SHOW' THEN ID ELSE NULL END)/COUNT(ID) * 100 AS 'NCNS Rate'
FROM cleveland_cancel_logs;
