
select click_time, l, q
from clicks2
where campaign_id = 592
and click_time >= '2017-7-1'
order by q desc
limit 50;

--query common from clicks 2 for a month
select q Query, count(*) as Num_of_Clicks
from clicks2
where campaign_id = 592
and date(click_time) >= '2017-01-01' 
group by q
order by Num_of_Clicks desc 
limit 10;
--query common from clicks 2 on conv for a month
select q Query, sum(if(conversion2_time IS null, 0, 1)) as Num_of_Clicks
from clicks2
where campaign_id = 592
and date(click_time) >= '2017-01-01' 
group by q
order by Num_of_Clicks desc 
limit 10;

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
--total num of conv by state for the whole year
select state, sum(num_of_conv) as Total_Num_of_Conv from
(
select b.state state, sum(if(a.conversion2_time IS null, 0, 1)) as num_of_conv
from clicks2 a
join states b on a.state_id = b.id 
where campaign_id = 592
and date(click_time) >= '2017-01-01' 
group by state 
union all 
select b.state state, sum(if(a.conversion2_time IS null, 0, 1)) as num_of_conv
from affiliate_clicks a
join states b on a.state_id = b.id 
where campaign_id = 592
and date(click_time) >= '2017-01-01' 
group by state 
) A
group by state 
order by Total_Num_of_Conv desc
limit 10;
--total num of clicks by state for the whole year
select state, sum(num_of_conv) as num_of_clicks from
(
select b.state state, count(click_time) as num_of_conv
from clicks2 a
join states b on a.state_id = b.id 
where campaign_id = 592
and date(click_time) >= '2017-01-01' 
group by state 
union all 
select b.state state, count(click_time) as num_of_conv
from affiliate_clicks a
join states b on a.state_id = b.id 
where campaign_id = 592
and date(click_time) >= '2017-01-01' 
group by state 
) A
group by state 
order by num_of_clicks desc
limit 10;




-- conversions and their locations and searches
select city, round(sum(if(conversion2_time IS null, 0, 1)),2) as conversion 
from affiliate_clicks
where campaign_id = 592
and date(click_time) >= '2017-06-01' and date(click_time) < '2017-7-1'
group by city
order by conversion desc
limit 20;