--find the avg cpc each month separated in queries to find trend for this year so far
SELECT month(click_time) date, avg(price)/100 
FROM clicks2 
WHERE click_time>='2017-05-01' 
GROUP BY date;


SELECT month(click_time) date, avg(price)/100 
FROM clicks2 
WHERE click_time>='2017-03-01' AND click_time < '2017-05-01'
GROUP BY date;

SELECT month(click_time) date, avg(price)/100 
FROM clicks2 
WHERE click_time>='2017-01-01' AND click_time < '2017-03-01'
GROUP BY date;

-- how many clicks we are getting by segment for 
--which segmement is getting the most clicks spend and conversions
SELECT count(id) num_of_clicks_rover, segment_id, sum(price/100), sum(if(conversion2_time IS null, 0, 1)) conversion
FROM clicks2
WHERE campaign_id = 3218 AND click_time>='2017-06-01'
GROUP BY segment_id
ORDER BY num_of_clicks_rover desc
;

-- how many 