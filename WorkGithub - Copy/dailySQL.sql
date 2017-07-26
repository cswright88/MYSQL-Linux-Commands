--find day spend per campaign_id
-- USE EVERY MORNING
-- get campaign clicks spend for one day for all of my campaigns (or change to monthly to get total spend and clicks)
Select Customer_name, Campaign_Name, CampID, sum(Clicks) Total_Clicks, round(sum(Spend), 2) TotalSpend, Budget from
(
select e.name Customer_name, b.name Campaign_Name, a.campaign_id CampID, sum(a.clicks) Clicks, sum(a.cost/100) Spend, b.budget Budget
from clicks2_cache a
join jobdb.job_campaigns b on a.campaign_id = b.id
join jobdb.job_pools c on b.pool_id = c.id
join jobdb.admins d on c.acct_mgr_id = d.id
join jobdb.job_customers e on a.customer_id = e.id
where d.id = 168
and a.date between '2017-7-24' and '2017-7-25'
group by a.campaign_id
Union All
select e.name Customer_name, b.name Campaign_Name, a.campaign_id CampID, sum(a.clicks) Clicks, sum(a.cost/100) Spend, b.budget Budget
from affiliate_clicks_summary a
join jobdb.job_campaigns b on a.campaign_id = b.id
join jobdb.job_pools c on b.pool_id = c.id
join jobdb.admins d on c.acct_mgr_id = d.id
join jobdb.job_customers e on a.ad_customer_id = e.id
where d.id = 168
and a.date between '2017-7-24' and '2017-7-25'
group by a.campaign_id
) A
group by CampID;
 --this is a change
-- this iis another change
--get expired jobs JOBSDB DATABASE!
select id, title, created, expired
from expired_jobs
where campaign_id = 2840;

-- spend by day for the month of a campaign
select day, round(sum(Spend),2) spend from
(
select date(click_time) day, sum(price/100) Spend
from clicks2
where click_time between '2017-7-1' and '2017-7-31'
and campaign_id = 7516
group by day
union all
select date(click_time) day, sum(price/100) Spend
from affiliate_clicks
where click_time between '2017-7-1' and '2017-7-31'
and campaign_id = 7516 and is_adv
group by day
) A
group by day;

--Find the publishers that are spending a lot by the day for a campaign
Select a.affiliate_id id, b.name, count(a.click_time), a.campaign_id, round(sum(a.price/100), 2) spend
from affiliate_clicks a
join jobdb.job_affiliates b on a.affiliate_id = b.id
where a.campaign_id = 691
and a.click_time >= '2017-7-18' and a.click_time < '2017-7-19'
group by id
order by spend desc
limit 10;
