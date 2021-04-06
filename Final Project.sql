/* First, I’d like to show our volume growth. 
Can you pull overall session and order volume, trended by quarter for the life of the business? 
Since the most recent quarter is incomplete, you can decide how to handle it. 
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qt,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2;


/* Next, let’s showcase all of our efficiency improvements. 
I would love to show quarterly figures since we launched, for session-to-order conversion rate, 
revenue per order, and revenue per session.
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qt,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt,
    SUM(price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2;


 /* I’d like to show how we’ve grown specific channels. 
 Could you pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, 
 brand search overall, organic search, and direct type-in?
 */

 CREATE TEMPORARY TABLE session_with_channel
 SELECT
	website_session_id,
    CASE
		WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN 'gsearch_nonbrand'
        WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN 'bsearch_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'brand_search_overall'
        WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        ELSE 'check logic'
	END AS channels
FROM website_sessions;


SELECT
	YEAR(orders.created_at) AS yr,
    QUARTER(orders.created_at) AS qt,
    COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'gsearch_nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'bsearch_nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand,
	COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'brand_search_overall' THEN orders.order_id ELSE NULL END) AS brand_search_overall,
	COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'organic_search' THEN orders.order_id ELSE NULL END) AS organic_search,
	COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'direct_type_in' THEN orders.order_id ELSE NULL END) AS direct_type_in
FROM orders
LEFT JOIN session_with_channel
	ON session_with_channel.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;



 /*
 Next, let’s show the overall session-to-order conversion rate trends for those same channels, 
 by quarter. Please also make a note of any periods where we made major improvements or optimizations.
 */
 
 SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qt,
    COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'gsearch_nonbrand' THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'gsearch_nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_cv_rt,
    COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'bsearch_nonbrand' THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'bsearch_nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_cv_rt,
	COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'brand_search_overall' THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'brand_search_overall' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_overall_cv_rt,
	COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'organic_search' THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'organic_search' THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_cv_rt,
	COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'direct_type_in' THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN session_with_channel.channels = 'direct_type_in' THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_cv_rt
FROM website_sessions
LEFT JOIN session_with_channel
	ON session_with_channel.website_session_id = website_sessions.website_session_id
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2;

 
 
  /* We’ve come a long way since the days of selling a single product. 
  Let’s pull monthly trending for revenue and margin by product, along with total sales and revenue. 
  Note anything you notice about seasonality. 
  */
  
  SELECT DISTINCT product_id FROM order_items;
  
  SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
	SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
	SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS bdaypanda_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS bdaypanda_marg,
	SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
  FROM order_items
  GROUP BY 1,2
  ORDER BY 1,2;

  -- Seasonality: 11/12 sells high general
  -- febraury lovebear valentine's day
  
  
  
  
  /*
  Let’s dive deeper into the impact of introducing new products. 
  Please pull monthly sessions to the /products page, and show how the % of those sessions 
  clicking through another page has changed over time, along with a view of how conversion from 
  /products to placing an order has improved.
  
  1. what comes next after /products page
  2. clickthrough rates for another pages
  3. conversion from /products to order
  */

CREATE TEMPORARY TABLE session_with_pageview
SELECT
	website_session_id,
    website_pageview_id,
    pageview_url
FROM website_pageviews
WHERE pageview_url >= '/products';

CREATE TEMPORARY TABLE session_with_next_page
SELECT
	session_with_pageview.website_session_id,
    MAX(session_with_pageview.pageview_url) AS next_page
FROM session_with_pageview
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = session_with_pageview.website_session_id
    AND website_pageviews.website_pageview_id > session_with_pageview.website_pageview_id
WHERE session_with_pageview.pageview_url > '/products'
GROUP BY 1;
  
SELECT 
	YEAR(website_pageviews.created_at) AS yr,
	MONTH(website_pageviews.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN next_page = '/the-original-mr-fuzzy' THEN session_with_next_page.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN pageview_url = '/products' THEN website_pageviews.website_session_id ELSE NULL END) AS mrfuzzy_ctrt,
	COUNT(DISTINCT CASE WHEN next_page = '/the-original-mr-fuzzy' THEN session_with_next_page.website_session_id ELSE NULL END)
		/COUNT(DISTINCT orders.order_id) AS mrfuzzy_order_rate,
	COUNT(DISTINCT CASE WHEN next_page = '/the-forever-love-bear' THEN session_with_next_page.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN pageview_url = '/products' THEN website_pageviews.website_session_id ELSE NULL END) AS lovebear_ctrt,
	COUNT(DISTINCT CASE WHEN next_page = '/the-forever-love-bear' THEN session_with_next_page.website_session_id ELSE NULL END)   
		/COUNT(DISTINCT orders.order_id) AS lovebear_order_rate,
	COUNT(DISTINCT CASE WHEN next_page = '/the-birthday-sugar-panda' THEN session_with_next_page.website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN pageview_url = '/products' THEN website_pageviews.website_session_id ELSE NULL END) AS bdaypanda_ctrt,
	COUNT(DISTINCT CASE WHEN next_page = '/the-birthday-sugar-panda' THEN session_with_next_page.website_session_id ELSE NULL END)
		/COUNT(DISTINCT orders.order_id) AS bdaypanda_order_rate,
	COUNT(DISTINCT CASE WHEN next_page = '/the-hudson-river-mini-bear' THEN session_with_next_page.website_session_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN pageview_url = '/products' THEN website_pageviews.website_session_id ELSE NULL END) AS minibear_ctrt,
	COUNT(DISTINCT CASE WHEN next_page = '/the-hudson-river-mini-bear' THEN session_with_next_page.website_session_id ELSE NULL END) 
		/COUNT(DISTINCT orders.order_id) AS minibear_order_rate
FROM session_with_next_page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = session_with_next_page.website_session_id
LEFT JOIN orders
	ON orders.website_session_id = session_with_next_page.website_session_id
GROUP BY 1,2;


-- different version
CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at AS saw_product_page_at
FROM website_pageviews
WHERE pageview_url = '/products';


SELECT
	YEAR(saw_product_page_at) AS yr,
	MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM products_pageviews
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = products_pageviews.website_session_id
    AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
LEFT JOIN orders
	ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2;
  /*
  We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). 
  Could you please pull sales data since then, and show how well each product cross-sells from one another?
  */
  
SELECT
	*
FROM order_items
WHERE created_at >= '2014-12-05';

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
	product_id,
    SUM(price_usd)
FROM order_items
WHERE created_at >= '2014-12-05'
GROUP BY 1,2,3;


SELECT
    orders.primary_product_id,
	COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN orders.order_id ELSE NULL END) AS x_sell_prod1,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN orders.order_id ELSE NULL END) AS x_sell_prod2,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN orders.order_id ELSE NULL END) AS x_sell_prod3,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN orders.order_id ELSE NULL END) AS x_sell_prod4,

	COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT orders.order_id) AS x_sell_prod1_rt,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT orders.order_id) AS x_sell_prod2_rt,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT orders.order_id) AS x_sell_prod3_rt,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT orders.order_id) AS x_sell_prod4_rt

FROM orders
LEFT JOIN order_items
	ON order_items.order_id = orders.order_id
    AND order_items.is_primary_item = 0 -- cross sell only
WHERE orders.created_at >= '2014-12-05'
GROUP BY 1;
  

-- Another Version
CREATE TEMPORARY TABLE primary_products
SELECT
	order_id,
    primary_product_id,
    created_at AS ordered_at
FROM orders
WHERE created_at > '2014-12-05'; -- when the 4th product was added


SELECT
    primary_product_id,
	COUNT(DISTINCT order_id) AS total_orders,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS x_sell_prod1,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS x_sell_prod2,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS x_sell_prod3,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS x_sell_prod4,

	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS x_sell_prod1_rt,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS x_sell_prod2_rt,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS x_sell_prod3_rt,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS x_sell_prod4_rt
FROM(
SELECT
	primary_products.*,
    order_items.product_id AS cross_sell_product_id
FROM primary_products
LEFT JOIN order_items
	ON order_items.order_id = primary_products.order_id
    AND order_items.is_primary_item = 0 -- only bringing in cross-sells
) AS primary_w_cross_sell
GROUP BY 1;





  /*
  In addition to telling investors about what we’ve already achieved, 
  let’s show them that we still have plenty of gas in the tank. 
  Based on all the analysis you’ve done, could you share some recommendations and opportunities 
  for us going forward? No right or wrong answer here – I’d just like to hear your perspective!
  */

-- cross selling product 4 is great idea sine it is minibear and have high correlation with other threes
-- add more products like product 4 which has high cross selling rates