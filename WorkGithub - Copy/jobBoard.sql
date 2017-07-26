-- how many clicks we are getting by segment for
--which segmement is getting the most clicks spend and conversions
SELECT count(id) numOfClicks, segment_id, sum(price/100), sum(if(conversion2_time IS null, 0, 1)) conversion
FROM clicks2
WHERE campaign_id = 1394 AND click_time>='2017-06-01'
UNION
SELECT count(id) numOfClicks, segment_id, sum(price/100), sum(if(conversion2_time IS null, 0, 1)) conversion
FROM affiliate_clicks
WHERE campaign_id = 1394 AND click_time>='2017-06-01'
GROUP BY segment_id
ORDER BY numOfClicks desc;


-- SELECT TOP 15 SEARCHES IN A CAMPAIGN FOR A CERTAIN PERIOD OF click_time
select q, count(*) Clicks, sum(if(conversion2_time is null,0,1)) conv2, sum(if(conversion3_time is null, 0,1)) conv3
from clicks2
where campaign_id=2806 and click_time>='2017-6-1' and click_time<'2017-7-1'
group by q
order by conv2 desc
limit 50;


--find spend for a day for a campaign
select campaign_id, sum(Clicks) Clicks, sum(Conversion2) Conversions, round(sum(Conversion2)/sum(Clicks),2) CR, round(sum(Spend),2) Spend, round(sum(Spend)/sum(Clicks),2) eCPC from
(
select campaign_id, count(*) Clicks, sum(if(conversion2_time is null, 0, 1)) Conversion2, sum(price)/100 Spend
from clicks2
where campaign_id = 187
and click_time >= '2017-6-1' and click_time < '2017-6-2'
group by  campaign_id
UNION ALL
select  campaign_id, count(*) Clicks, sum(if(conversion2_time is null, 0, 1)) Conversion2, sum(price)/100 Spend
from affiliate_clicks
where campaign_id = 187
and click_time >= '2017-6-1' and click_time < '2017-6-2'  and is_adv
group by  campaign_id
) A
group by campaign_id;


-- FROM JOSH h
--eventually go to the admin table at jobsdb to get my admin id
--my admin is 168
--Make sure to group by campaign id instead of customer name
--to get spend for that customer
select Customer, Month, sum(Clicks) Clicks, round(sum(Spend), 2) Spend from
(
select e.name Customer, month(a.date) Month, sum(a.clicks) Clicks, sum(a.cost/100) Spend
from clicks2_cache a
join jobdb.job_campaigns b on a.campaign_id = b.id
join jobdb.job_pools c on b.pool_id = c.id
join jobdb.admins d on c.acct_mgr_id = d.id
join jobdb.job_customers e on a.customer_id = e.id
where d.id = 168
and a.date >= '2017-06-28' and a.date < '2017-06-29'
group by e.name, month(a.date)
UNION ALL
select e.name Customer, month(a.date) Month, sum(a.clicks) Clicks, sum(a.cost/100) Spend
from affiliate_clicks_summary a
join jobdb.job_campaigns b on a.campaign_id = b.id
join jobdb.job_pools c on b.pool_id = c.id
join jobdb.admins d on c.acct_mgr_id = d.id
join jobdb.job_customers e on a.ad_customer_id = e.id
where d.id = 168
and a.date >= '2017-06-28' and a.date < '2017-06-29'
group by e.name, month(a.date)
) A
group by Customer, Month;

 --Performance by Company (run query in Sales78 database)
select Company, ID Company_ID, round(sum(Spend),2) Spend, sum(Clicks) Clicks, Sum(Conversion) Conversion,  round(sum(Spend)/Sum(Conversion),2) CPA from
(
select b.name Company,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion,
b.id ID
from clicks2 a join companies b on a.company_id = b.id
where a.campaign_id in (21)
and click_time >='2017-06-01'
group by b.name
UNION ALL
select b.name Company,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion,
b.id ID
from affiliate_clicks  a join companies b on a.company_id = b.id
where a.campaign_id in (21)
and click_time >='2017-06-01'
group by b.name
) A
group by Company
having round(sum(Spend)/Sum(Conversion),2) > 3
order by sum(Spend) desc
limit 50;


-- average daily spend, total spend, by campid for the month
select campID, round(sum(Spend),2) Spend, sum(spend)/26 avg_spend from
(
select a.campaign_id campID, sum(a.price)/100 Spend
from clicks2 a JOIN jobdb.job_campaigns b on a.campaign_id = b.id
where campaign_id in(6504)
and date(a.click_time) >= '2017-6-1'
group by  a.campaign_id
UNION ALL
select a.campaign_id campID, sum(a.price)/100 Spend
from affiliate_clicks a JOIN jobdb.job_campaigns b on a.campaign_id = b.id
where campaign_id in(6504)
and date(a.click_time) >= '2017-6-1' and is_adv
group by  a.campaign_id
) A
group by campID;




-- tells conversions by hour of the day
--good for budget pacing clients to show when things are capping
select hour(click_time) HOUR, sum(CLICKS) CLICKS, round(Sum(Spend),2) SPEND, round((SPEND/CLICKS),2) AVG_CPC, sum(Conv), round(Sum(SPEND)/sum(Conv),2) CPA
from
(
select 1 CLICKS, click_time, if(conversion2_time is null, 0, 1) Conv, (price/100) Spend
from clicks2
where campaign_id in (7343, 4197)
and click_time >='2017-07-25'
UNION ALL
select 1 CLICKS, click_time, if(conversion2_time is null, 0, 1) Conv, (price/100) Spend
from affiliate_clicks
where campaign_id in (7343, 4197)
and click_time >='2017-07-25'
and is_adv
) A
group by hour(click_time);

-- are conversions usually lower or higher on weekends?
select campaign_id, dayname(click_time) dayOfWeek, round(sum(if(conversion_time IS null, 0, 1))/count(*),2) c1, round(sum(if(conversion2_time IS null, 0, 1))/count(*),2) c2, round(sum(if(conversion3_time IS null, 0, 1))/count(*),2) c3
from clicks2
where campaign_id = 1394 and date(click_time) >= '2017-6-1'
group by dayOfWeek
order by c2 desc;
-- find the day of the week that the pixle fires the most
select campaign_id, dayname(click_time), count(*) num_of_clicks, sum(if(conversion_time is null, 0, 1)) con1, sum(if(conversion2_time is null, 0, 1)) con2, sum(if(conversion3_time is null, 0, 1)) con3
from clicks2
where campaign_id = 2806 and date(click_time) >= '2015-1-1'
group by dayname(click_time)
order by con2 desc;


-- find the days that the budget changed for a segment by campid
select last_updated, dayname(last_updated), name segmentName, budget
from jobdb.job_segments
where campaign_id = 2684 and date(last_updated) >= '2017-01-01'
order by last_updated;



-- find the top five publishers for a campaign by the number of clicks they send us
select a.affiliate_id, b.name, count(*) num_of_clicks, sum(if(a.conversion2_time is null, 0, 1)) con2, round(sum(a.price)/100, 2) Spend
from affiliate_clicks a
join jobdb.job_affiliates b on a.affiliate_id = b.id
where date(a.click_time) >= '2017-6-1' and a.campaign_id = 691
group by a.affiliate_id
order by num_of_clicks desc
limit 5;


--get expired jobs JOBSDB DATABASE!
select id, title, created, expired
from expired_jobs
where campaign_id = 4605;


--most common SEARCHES overall (big database)
select q, count(*) as mostCommon
from user_searches3
where last_upd >= '2017-06-26 00:00:00' and last_upd < '2017-06-26 00:30:00'
and q like '%nurse%'
group by q
order by mostCommon desc
limit 1;



-- check deduped and check exlusions to make sure something is in clicks2 and getting jobs2careers tracksion
-- most common searches by camp id
select q, count(*) as mostCommon
from clicks2
where campaign_id = 7516
and date(click_time) >= '2017-07-01'
group by q
order by mostCommon desc
limit 10;
--most common location by camp id
select l, count(*) as mostCommon
from clicks2
where campaign_id = 416
and date(click_time) >= '2017-06-01'
group by l
order by mostCommon desc
limit 10;



--Quarterly Pacing--
select Month, Cust, Pool, sum(Price) from
(
select month(date) Month, d.name Cust, c.name Pool, sum(cost/100) Price
from clicks2_cache a join jobdb.job_campaigns b on a.campaign_id = b.id
join jobdb.job_pools c on b.pool_id = c.id
join jobdb.job_customers d on c.job_customer_id = d.id
where c.acct_mgr_id = 151
and date >= '2017-04-01'
group by Month, d.name, c.name
UNION ALL
select month(date) Month, d.name, c.name, sum(cost/100) Price
from affiliate_clicks_summary a join jobdb.job_campaigns b on a.campaign_id = b.id
join jobdb.job_pools c on b.pool_id = c.id
join jobdb.job_customers d on c.job_customer_id = d.id
where c.acct_mgr_id = 151
and date >= '2017-04-01'
group by Month, d.name, c.name
) A
group by Month, Cust, Pool



--average cpa seen in the clicks tab under a camapign
SELECT
	campaign_id campID,
	clickTime,
	sum(Clicks) clicks,
	round(sum(Spend), 2) Spend,
	sum(C1) C1,
	sum(C2) C2,
	sum(C3) C3,
	round(sum(Spend)/sum(C1),2) avgcpa,
	round(sum(Spend)/sum(C2),2) avgcpa2,
	round(sum(Spend)/sum(C3),2) avgcpa3
FROM
(
SELECT
	campaign_id,
	date(click_time) clickTime,
	count(*) Clicks,
	(sum(price)/100) Spend,
	sum(if(conversion_time is null, 0, 1)) C1,
	sum(if(conversion2_time is null, 0, 1)) C2,
	sum(if(conversion3_time is null, 0, 1)) C3
FROM clicks2
WHERE campaign_id = 1394 and click_time >='2017-6-1'
GROUP BY date(click_time)
UNION ALL
SELECT
	campaign_id,
	date(click_time) clickTime,
	count(*) Clicks,
	(sum(price)/100) Spend,
	sum(if(conversion_time is null, 0, 1)) C1,
	sum(if(conversion2_time is null, 0, 1)) C2,
	sum(if(conversion3_time is null, 0, 1)) C3
FROM affiliate_clicks
WHERE campaign_id = 1394 and click_time >='2017-6-1' and is_adv
GROUP BY date(click_time)
) A
GROUP BY clickTime
;

--average cpa seen in the clicks tab under a camapign over the year
SELECT campaign_id campID, clickTime, sum(Clicks) clicks, round(sum(Spend), 2) Spend, sum(C2) C2,round(sum(Spend)/sum(C2),2) avgcpa2
FROM
(
SELECT campaign_id, month(click_time) clickTime,count(click_time) Clicks,(sum(price)/100) Spend,sum(if(conversion2_time is null, 0, 1)) C2
FROM clicks2
WHERE campaign_id = 1001 and click_time >='2017-1-1'
GROUP BY month(click_time)
UNION ALL
SELECT campaign_id,month(click_time) clickTime,count(click_time) Clicks,(sum(price)/100) Spend,sum(if(conversion2_time is null, 0, 1)) C2
FROM affiliate_clicks
WHERE campaign_id = 1001 and click_time >='2017-1-1'
and is_adv
GROUP BY month(click_time)
) A
GROUP BY clickTime
;
--average cpa seen in the clicks tab under a camapign
SELECT campaign_id campID, sum(Clicks) clicks, round(sum(Spend), 2) Spend, sum(C2) C2,round(sum(Spend)/sum(C2),2) avgcpa2
FROM
(
SELECT campaign_id,count(click_time) Clicks,(sum(price)/100) Spend,sum(if(conversion2_time is null, 0, 1)) C2
FROM clicks2
WHERE campaign_id = 1001 and click_time >='2017-7-1'
UNION ALL
SELECT campaign_id,count(click_time) Clicks,(sum(price)/100) Spend,sum(if(conversion2_time is null, 0, 1)) C2
FROM affiliate_clicks
WHERE campaign_id = 1001 and click_time >='2017-7-1'
and is_adv
) A
;



--company that recieved clicks and how many 2684 for segment 31997
--all clicks from yesterday for that segment broken by comapny id
-- link to companies database in sales 78
-- and spend

select Company, ID Company_ID, round(sum(Spend),2) Spend, sum(Clicks) Clicks, Sum(Conversion) Conversion,  round(sum(Spend)/Sum(Conversion),2) CPA from
(
select b.name Company,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion,
b.id ID
from clicks2 a join companies b on a.company_id = b.id
where a.segment_id in (31997) and a.campaign_id = 2684
and click_time >='2017-07-11' and click_time < '2017-07-12'
group by b.name
UNION ALL
select b.name Company,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion,
b.id ID
from affiliate_clicks  a join companies b on a.company_id = b.id
where a.segment_id in (31997) and a.campaign_id = 2684
and click_time >='2017-07-11' and click_time < '2017-07-12'
group by b.name
) A
group by Company
order by sum(Spend) desc;






select b.name, a.campaign_id, a.segment_id, sum(a.price/100) spend, b.status
from affiliate_clicks a
join jobdb.job_segments b on a.segment_id = b.id
where a.click_time >= '2017-7-1'
and a.campaign_id in (4487, 3673)
group by a.segment_id
order by a.campaign_id, b.status;

select sum(count) Count, job_id from
(
select count(click_time) count, job_id
from clicks2
where campaign_id = 6151
and click_time >= '2017-7-1'
group by job_id
union all
select count(click_time) count, job_id
from affiliate_clicks
where campaign_id = 6151
and click_time >= '2017-7-1'
group by job_id
) A
group by job_id
order by count desc
limit 50;






select name, Segment, sum(clicks) Clicks, sum(Conversion) CONVERSIONS from (
select b.name name, a.segment_id Segment, count(a.click_time) clicks, sum(if(a.conversion2_time is null, 0, 1)) Conversion
from clicks2 a
join jobdb.job_segments b on a.segment_id = b.id
where a.campaign_id = 2806
and a.click_time >= '2017-7-1'
group by Segment
union all
select b.name name, a.segment_id Segment, count(a.click_time) clicks, sum(if(a.conversion2_time is null, 0, 1)) Conversion
from affiliate_clicks a
join jobdb.job_segments b on a.segment_id = b.id
where a.campaign_id = 2806
and a.click_time >= '2017-7-1'
group by Segment
) A
group by Segment
order by CONVERSIONS desc
limit 50;



--- look up by job referance
select job_reference, sum(Clicks) ClickS, sum(Conversion), sum(Conversion2)
from(
select job_reference, count(*) Clicks, sum(if(conversion2_time is null, 0, 1)) Conversion, sum(if(conversion3_time is null, 0, 1)) Conversion2
from clicks2
where campaign_id = 2806
and click_time >= '2017-7-11'
group by job_reference
union all
select job_reference, count(*) Clicks, sum(if(conversion2_time is null, 0, 1)) Conversion, sum(if(conversion3_time is null, 0, 1)) Conversion2
from affiliate_clicks
where campaign_id = 2806
and click_time >= '2017-7-11' and is_adv
group by job_reference
) A
order by ClickS desc;


--find the search results for a company this month by num of clicks
select q, count(click_time) Clicks,
from clicks2
where campaign_id = 7491
and click_time >= '2017-7-1'
order by clicks desc;


-- find performance for a segment compared to other segments in a Campaign for the month
select Campaign, Segment, SegName, sum(NumClicks) TotalClick, sum(conv2) totalConv2 from(
select a.campaign_id Campaign, a.segment_id Segment, b.name SegName, count(a.click_time) NumClicks, sum(if(conversion2_time is null, 0, 1)) conv2
from clicks2 a
join jobdb.job_segments b on a.segment_id = b.id
where a.campaign_id = 592 and a.click_time >= '2017-7-1'
group by Segment
union all
select a.campaign_id Campaign, a.segment_id Segment, b.name SegName, count(a.click_time) NumClicks, sum(if(conversion2_time is null, 0, 1)) conv2
from affiliate_clicks a
join jobdb.job_segments b on a.segment_id = b.id
where a.campaign_id = 592 and a.click_time >= '2017-7-1'
group by Segment
) A
group by Segment
order by TotalClick desc;




-- dedupe deduped by
-- jobsdb database
select id, job_reference, title, deduped, deduped_by
from jobs
where source_id = 3390
limit 50;



------------------------------------ Find out what traffic is mobile -- remember that affiliate 133 is jobs2careers
select sum(Spend), sum(Clicks), sum(Conversion), UserAgent from(
select
round(sum(price/100),2) Spend,
count(*) Clicks,
sum(if(conversion_time is null, 0, 1)) Conversion,
CASE category
when 0 then 'Unknown'
when 1 then 'Mobile'
when 2 then 'Desktop'
end as UserAgent
from affiliate_clicks a join platforms b on a.c6 = b.id
join jobdb.job_affiliates c on a.affiliate_id = c.id
where campaign_id = 21
and click_time between '2017-06-01' and '2017-06-30'
group by UserAgent
Union all
select
round(sum(price/100),2) Spend,
count(*) Clicks,
sum(if(conversion_time is null, 0, 1)) Conversion,
CASE category
when 0 then 'Unknown'
when 1 then 'Mobile'
when 2 then 'Desktop'
end as UserAgent
from clicks2 a join platforms b on a.c6 = b.id
where campaign_id = 21
and click_time between '2017-06-01' and '2017-06-30'
group by UserAgent
) A
group by UserAgent
order by conversion desc;

------ same as above -------
select
round(sum(price/100),2) Spend,
count(*) Clicks,
sum(if(conversion_time is null, 0, 1)) Conversion,
CASE category
when 0 then 'Unknown'
when 1 then 'Mobile'
when 2 then 'Desktop'
end as UserAgent
from affiliate_clicks a join platforms b on a.c6 = b.id
join jobdb.job_affiliates c on a.affiliate_id = c.id
where campaign_id = 21 and a.affiliate_id = 133
and is_adv
and click_time between '2017-06-01' and '2017-06-30'
group by UserAgent;
----------------------------------------------------


-- Pool and reload info
select id, pool_id, name, created, daily_process_time, processed, process_start_time, download_start_time,jobs_in_source,jobs_loaded,status
from job_sources
where pool_id = 2019 and process_start_time <= '2017-7-1'
order by process_start_time desc
limit 10;
--
select *
from job_source_reloads
where source_id in (2538, 2334, 2335);
--
select id, sum(TotalClicks) from(
select id, count(click_time) TotalClicks
from clicks2
where campaign_id in (7641,7644)
union all
select id, count(click_time) TotalClicks
from affiliate_clicks
where campaign_id in (7641,7644)
) A

-- is mobile traffic for job.com
select count(click_time), is_mobile
from affiliate_clicks
where campaign_id = 21
and click_time between '2017-6-1' and '2017-6-30'
and is_mobile = 1
group by is_mobile;

-- or use this in the jobsdb excluded affiliates from the campaign editor
select id, exclude_affiliate, exclude_affiliate_feed
from job_campaigns
where id = 691;
-- then use this to find the names of thes above excluded affiliates from the campaign editor
select id, name
from job_affiliates
where id in (1542,
727,
1998,
367,
518,
3357,
926,
3149,
2122,
1266,
1356,
2502
);

select id, name, exclude_cpgn_ids2, exclude_cpgn_ids2_hard
from job_affiliates
where exclude_cpgn_ids2 like "%691%"
or exclude_cpgn_ids2_hard like "%691%";
