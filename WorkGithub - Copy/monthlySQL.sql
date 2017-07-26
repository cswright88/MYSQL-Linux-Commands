--jobsdb run to see when a campaign hit the budget last 
select * 
from job_campaigns_daily_cap_log 
where campaign_id = 6151
order by date(daily_capped_time) desc
limit 20;
-- TODO how to improve this to pull all my campaigns and get the cap for that particular day.  

--Is budget pacing on for my campaign
select b.acct_mgr_id, a.id, a.name, a.budget_pacing
from jobdb.job_campaigns a
join jobdb.job_pools b on a.pool_id= b.id
where b.acct_mgr_id = 168;


select day as 'July', job_reference 'JobID', Company, sum(Clicks) as 'Clicks', Sum(Spend) as 'Spend', sum(Conversion2) as 'Conversions' from 
(
select day(click_time) day, job_reference, b.name Company, count(*) Clicks, sum(price/100) Spend, sum(if(conversion2_time is null, 0, 1)) Conversion2
from clicks2 a join companies b on a.company_id = b.id
where campaign_id in (6151) 
and click_time >='2017-06-01' and click_time <'2017-07-01'
group by day(click_time), job_reference
UNION ALL
select day(click_time) day, job_reference, b.name Company, count(*) Clicks, sum(price/100) Spend, sum(if(conversion2_time is null, 0, 1)) Conversion2
from affiliate_clicks a join companies b on a.company_id = b.id
where campaign_id in (6151) 
and is_adv = 1
and click_time >='2017-06-01' and click_time <'2017-07-01'
group by day(click_time), job_reference
) A
group by day, job_reference
order by sum(Spend) desc;


-- find if there is budget pacing and what the number of month the pacing is set to
Select a.id, a.name, c.full_name, c.id, c.manager_id, a.budget_pacing, a.pacing_dom
From jobdb.job_campaigns a
join jobdb.job_pools b on a.pool_id = b.id
join jobdb.admins c on b.acct_mgr_id = c.id
where c.id = 168 and a.status in (1,5) and a.budget_pacing = 1
order by a.name;
