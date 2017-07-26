
select name, id, rev_share
from job_affiliates
order by rev_share desc
limit 20;

select title
from jobs
where campaign_id = 6151
order by title;



--average cpa seen in the clicks tab under a camapign over the year
SELECT campaign_id campID, clickTime, sum(Clicks) clicks, round(sum(Spend), 2) Spend, sum(C2) C2,round(sum(Spend)/sum(C2),2) avgcpa2
FROM
(
SELECT campaign_id, month(click_time) clickTime,count(click_time) Clicks,(sum(price)/100) Spend,sum(if(conversion2_time is null, 0, 1)) C2
FROM clicks2
WHERE campaign_id = 21 and click_time >='2017-1-1'
GROUP BY month(click_time)
UNION ALL
SELECT campaign_id,month(click_time) clickTime,count(click_time) Clicks,(sum(price)/100) Spend,sum(if(conversion2_time is null, 0, 1)) C2
FROM affiliate_clicks
WHERE campaign_id = 21 and click_time >='2017-1-1'
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
--
SELECT campaign_id campID, sum(Clicks) clicks, round(sum(Spend), 2) Spend, sum(C2) C2,round(sum(Spend)/sum(C2),2) avgcpa2
FROM
(
SELECT campaign_id,count(click_time) Clicks,(sum(price)/100) Spend,sum(if(conversion2_time is null, 0, 1)) C2
FROM clicks2
WHERE campaign_id = 1001 and click_time >= '2017-6-1' and click_time < '2017-7-1'
UNION ALL
SELECT campaign_id,count(click_time) Clicks,(sum(price)/100) Spend,sum(if(conversion2_time is null, 0, 1)) C2
FROM affiliate_clicks
WHERE campaign_id = 1001 and click_time >= '2017-6-1' and click_time < '2017-7-1'
and is_adv
) A
;

select date(last_upd) CreatedDay, count(*)
from jobs
where campaign_id = 21
and last_upd > '2017-7-1'
group by CreatedDay
;




-- is mobil traffic by day
select date(click_time) ClickDate, count(click_time), is_mobile
from affiliate_clicks
where campaign_id = 691
and click_time >= '2017-7-1'
and is_mobile = 0
group by ClickDate;



select segment_id, dayOfWeek, sum(Clicks) from(
select segment_id, date(click_time) dayOfWeek, count(click_time) Clicks
from clicks2
where campaign_id = 691 and click_time >= '2017-7-1' and segment_id = 9541
group by dayOfWeek
union all
select segment_id, date(click_time) dayOfWeek, count(click_time) Clicks
from affiliate_clicks
where campaign_id = 691 and click_time >= '2017-7-1' and segment_id = 9541
group by dayOfWeek
) A
group by dayOfWeek;


select fr_enable, name, fr_processed, fr_processed_time, fr_jobs_in_source, fr_jobs_loaded, jobs_loaded, cpc_in_cents
from job_sources
where id = 691;
