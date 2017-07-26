--job.com queries 



-- Find when mobile traffic was taken off of a campaign 
select mobile_friendly, last_updated
from job_campaigns 
where id = 21 and last_updated < '2017-5-1'
limit 10;

--jobsdb run to see when a campaign hit the budget last 
select * 
from job_campaigns_daily_cap_log 
where campaign_id = 21 
order by daily_capped_time 
desc limit 5;

 --Performance by Company (run query in Sales78 database)
select Company, JOBID, ID Company_ID, round(sum(Spend),2) Spend, sum(Clicks) Clicks, Sum(Conversion) Conversion,  round(sum(Spend)/Sum(Conversion),2) CPA from
(
select b.name Company, a.job_id JOBID,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion,
b.id ID
from clicks2 a join companies b on a.company_id = b.id
where a.campaign_id in (21) 
and click_time >='2017-07-01' 
group by b.name
UNION ALL
select b.name Company, a.job_id JOBID,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion,
b.id ID
from affiliate_clicks  a join companies b on a.company_id = b.id
where a.campaign_id in (21)
and click_time >='2017-07-01' 
group by b.name
) A
group by Company
having round(sum(Spend)/Sum(Conversion),2) > 5
order by sum(Spend) desc
limit 50;
-- get all the bad performing companies
select Company, ID Company_ID, round(sum(Spend),2) Spend, sum(Clicks) Clicks, Sum(Conversion) Conversion,  round(sum(Spend)/Sum(Conversion),2) CPA from
(
select b.name Company, b.id ID,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion
from clicks2 a join companies b on a.company_id = b.id
where a.campaign_id in (21) 
and click_time >='2017-07-01' 
group by ID
UNION ALL
select b.name Company, b.id ID,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion
from affiliate_clicks  a join companies b on a.company_id = b.id
where a.campaign_id in (21)
and click_time >='2017-07-01' 
group by ID
) A
group by Company_ID
order by sum(Spend) desc
limit 50;





--get all the bad performing jobs 
select Company, JOBID, Reference, ID Company_ID, round(sum(Spend),2) Spend, sum(Clicks) Clicks, Sum(Conversion) Conversion,  round(sum(Spend)/Sum(Conversion),2) CPA from
(
select b.name Company, a.job_id JOBID, a.job_reference Reference,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion,
b.id ID
from clicks2 a join companies b on a.company_id = b.id
where a.campaign_id in (21) 
and click_time >='2017-07-01' 
group by a.job_reference
UNION ALL
select b.name Company, a.job_id JOBID, a.job_reference Reference,
count(*) Clicks,
sum(price/100) Spend,
sum(if(conversion_time is null, 0, 1)) Conversion,
b.id ID
from affiliate_clicks  a join companies b on a.company_id = b.id
where a.campaign_id in (21)
and click_time >='2017-07-01' and is_adv
group by a.job_reference
) A
group by Reference
order by sum(Spend) desc
limit 200;






select id, title
from jobs
where campaign_id = 21 and id in (
)
limit 100;

-------------------get ip addresses that are spending alot 
select ip_address, job_id, sum(Clicks) TotalClicks, sum(Conv) Conversion affiliate_id from(
select ip_address, job_id, count(click_time) Clicks, sum(if(conversion_time is null, 0, 1)) Conv
from clicks2
where campaign_id = 21
and click_time between '2017-7-1' and '2017-7-15'
group by ip_address, job_id
union all 
select ip_address, job_id, count(click_time) Clicks, sum(if(conversion_time is null, 0, 1)) Conv
from affiliate_clicks
where campaign_id = 21
and click_time between '2017-7-1' and '2017-7-15' and is_adv
group by ip_address, job_id
) A 
group by ip_address, job_id
order by Clicks desc
limit 50;
------------------------------- get the affiliate id as well `
select ip_address, job_id, count(click_time) Clicks, sum(if(conversion_time is null, 0, 1)) Conv, affiliate_id
from affiliate_clicks
where campaign_id = 21
and click_time between '2017-7-1' and '2017-7-15'
group by ip_address, job_id
order by Clicks desc 
limit 50;
-----------------------------------end ip address sql