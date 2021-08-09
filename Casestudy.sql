CREATE DATABASE casestudy;
USE casestudy;

SELECT * FROM ap
WHERE consumer_id < 10010000050;

SELECT * FROM dca
WHERE customer_reference_ID < 10010000050;

UPDATE dca
SET debt_current_balance = REPLACE(debt_current_balance, '$', '');

UPDATE dca
SET debt_initial_balance = REPLACE(debt_initial_balance, '$', '');

UPDATE dca
SET initial_principal = REPLACE(initial_principal, '$', '');

UPDATE dca
SET initial_fees = REPLACE(initial_fees, '$', '');

SELECT DISTINCT current_status FROM dca;

SELECT
	current_status,
	COUNT(customer_reference_ID) AS count_of_customerid
FROM dca
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM dca 
WHERE current_status = 'Fraud';

SELECT * FROM ap
WHERE consumer_id = '10014408508';

SELECT * FROM dca
WHERE customer_reference_ID = '10014408508';

SELECT * FROM ap
WHERE consumer_id = '10014408508';

SELECT
	YEAR(debt_created_date) AS yr,
    MONTH(debt_created_date) AS mo,
    COUNT(customer_reference_ID) AS count_of_customerid
FROM dca
GROUP BY 1, 2
ORDER BY 3 DESC;

SELECT
	MIN(debt_created_date) AS first_day,
	MAX(debt_created_date) AS most_recent_day
FROM dca;

SELECT
	MIN(referral_date) AS first_day,
	MAX(referral_date) AS most_recent_day
FROM ap;

SELECT
	MIN(debt_created_date) AS first_day
FROM dca;

SELECT *
FROM dca
INNER JOIN ap
ON ap.consumer_id = dca.customer_reference_ID
WHERE current_status IN ('Settled', 'Fraud')
LIMIT 1000;

SELECT
	*
FROM ap
LEFT JOIN dca
ON dca.customer_reference_ID = ap.consumer_id
WHERE referral_balance < current_balance AND referral_latefee = current_latefee;

SELECT * FROM ap
WHERE consumer_id = '10010085262';

SELECT * FROM dca
WHERE customer_reference_ID = '10010085262';

SELECT
	customer_reference_ID,
    MAX(debt_created_date) AS 'recent_date'
FROM dca
GROUP BY customer_reference_ID;

SELECT
	customer_reference_ID,
    MIN(debt_created_date) AS 'first_date'
FROM dca
GROUP BY customer_reference_ID;

SELECT
	*
FROM ap
WHERE referral_date = '6/9/20'
AND referral_balance = '207.97';

WITH top_initial_balance AS (
	SELECT
		*,
        DENSE_RANK() OVER (PARTITION BY MONTH(debt_created_date) ORDER BY 
							SUM(debt_initial_balance) DESC) AS customer_rank
	FROM dca
)
SELECT 
	top_initial_balance.MONTH(debt_created_date),
    top_initial_balance.customer_reference_ID,
    top_initial_balance.customer_rank
FROM top_initial_balance
JOIN dca
ON dca.customer_reference_ID = top_initial_balance.customer_reference_ID
WHERE customer_rank <= 5
GROUP BY 1;

SELECT
	YEAR(debt_created_date) AS yr,
    MONTH(debt_created_date) AS mo,
    ROUND(SUM(debt_initial_balance),2) AS sum_of_initial_balance,
    ROUND(SUM(debt_current_balance),2) AS sum_of_current_balance,
    ROUND(ROUND(SUM(debt_initial_balance),2) - ROUND(SUM(debt_current_balance),2),2) AS resolved_amount,
    ROUND((SUM(debt_initial_balance) - SUM(debt_current_balance))/SUM(debt_initial_balance),2) AS resolved_percentage
FROM dca
GROUP BY 1,2
ORDER BY 1,2;


SELECT
	YEAR(debt_created_date),
    MONTH(debt_created_date)
FROM dca
GROUP BY 1,2,3
ORDER BY 1,2;


SELECT * FROM dca WHERE debt_current_balance < 0;
SELECT DISTINCT current_status FROM dca WHERE debt_current_balance < 0;
 
SELECT * FROM ap WHERE current_balance < 0;

SELECT * FROM ap WHERE consumer_id IN 
('10010921128','10012058634','10014599857','10015754543','10016307369','10016342491');

SELECT * FROM dca WHERE customer_reference_ID IN
('10010921128','10012058634','10014599857','10015754543','10016307369','10016342491');

SELECT * 
FROM ap 
LEFT JOIN dca 
ON ap.consumer_id = dca.customer_reference_ID 
WHERE ap.consumer_id IN 
('10010921128','10012058634','10014599857','10015754543','10016307369','10016342491');

SELECT
*
FROM ap
WHERE referral_date = '4/4/21';

SELECT
* 
FROM dca
LEFT JOIN ap
ON ap.consumer_id = dca.customer_reference_ID
WHERE dca.current_status = 'New' AND ap.consumer_id IS NULL;

SELECT * FROM ap WHERE consumer_ID = '10010001780';
SELECT * FROM dca WHERE customer_reference_ID = '10010001780';