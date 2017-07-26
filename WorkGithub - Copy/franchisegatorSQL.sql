--query common from clicks 2 for a month
select q, count(*) as mostCommon
from clicks2
where campaign_id = 592
and date(click_time) >= '2017-06-01' and date(click_time) < '2017-7-1'
group by q
order by mostCommon desc 
limit 20;
--location from clicks2 for a month
select l, count(*) as mostCommon
from clicks2
where campaign_id = 592
and date(click_time) >= '2017-06-01' and date(click_time) < '2017-7-1'
group by l
order by mostCommon desc 
limit 20;
--location from affiliate clicks 
select city, count(*) as mostCommon
from affiliate_clicks
where campaign_id = 592
and date(click_time) >= '2017-06-01' and date(click_time) < '2017-7-1'
group by city
order by mostCommon desc 
limit 20;

--both together for location by month
select state, sum(num_of_conv) as Total_Num_of_Conv from
(
select b.state state, sum(if(a.conversion2_time IS null, 0, 1)) as num_of_conv
from clicks2 a
join states b on a.state_id = b.id 
where campaign_id = 592
and date(click_time) >= '2017-06-01' and date(click_time) < '2017-7-1'
group by state 
union all 
select b.state state, sum(if(a.conversion2_time IS null, 0, 1)) as num_of_conv
from affiliate_clicks a
join states b on a.state_id = b.id 
where campaign_id = 592
and date(click_time) >= '2017-06-01' and date(click_time) < '2017-7-1'
group by state 
) A
group by state 
order by Total_Num_of_Conv desc
limit 50;