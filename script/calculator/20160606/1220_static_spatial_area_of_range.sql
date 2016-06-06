--
-- Area of range tables
--

drop view if exists area_of_range_extant cascade;
create or replace view area_of_range_extant as
select
  c.region,
  c.cntryname country,
  k.known,
  p.possible,
  COALESCE(k.known, 0) + COALESCE(p.possible, 0) total
from country c
left join (
  select
    m.region,
    m.country,
    sum(area_sqkm) known
  from country_range_metrics m
  where range=1 and range_quality='Known'
  group by m.region, m.country
) k on k.country = c.cntryname
left join (
  select
    m.region,
    m.country,
    sum(area_sqkm) possible
  from country_range_metrics m
  where range=1 and range_quality='Possible'
  group by m.region, m.country
) p on p.country = c.cntryname
order by region, country;

drop view if exists area_of_range_covered cascade;
create or replace view area_of_range_covered as
select
  k.analysis_name,
  k.analysis_year,
  k.region,
  k.country,
  k.surveytype,
  k.known,
  p.possible,
  COALESCE(k.known, 0) + COALESCE(p.possible, 0) total
from (
  select
    m.analysis_name,
    m.analysis_year,
    m.country,
    m.region,
    t.surveytype,
    sum(area_sqkm) known
  from survey_range_intersection_metrics m
  join surveytypes t on t.category = m.category
  where range_quality='Known'
  group by m.analysis_name, m.analysis_year, m.country, m.region, t.surveytype
) k
left join (
  select
    m.analysis_name,
    m.analysis_year,
    m.country,
    m.region,
    t.surveytype,
    sum(area_sqkm) possible
  from survey_range_intersection_metrics m
  join surveytypes t on t.category = m.category
  where range_quality='Possible'
  group by m.analysis_name, m.analysis_year, m.country, m.region, t.surveytype
) p on k.analysis_name = p.analysis_name and k.analysis_year = p.analysis_year and 
  k.country = p.country and k.surveytype = p.surveytype
order by analysis_name, analysis_year, region, country, surveytype;

drop view if exists area_of_range_covered_subtotals cascade;
create or replace view area_of_range_covered_subtotals as
select
  analysis_name,
  analysis_year,
  region,
  country,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered
group by analysis_name, analysis_year, region, country
order by analysis_name, analysis_year, region, country;

drop view if exists area_of_range_covered_unassessed cascade;
create or replace view area_of_range_covered_unassessed as
select
  n.analysis_name,
  n.analysis_year,
  x.region,
  x.country,
  x.known - n.known known,
  x.possible - n.possible possible,
  x.total - n.total total
from area_of_range_extant x join
area_of_range_covered_subtotals n on x.country = n.country
order by n.analysis_name, n.analysis_year, x.region, x.country;

drop view if exists area_of_range_covered_totals cascade;
create view area_of_range_covered_totals as
select
  analysis_name, analysis_year,
  region,
  country,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from (
  select * from area_of_range_covered_subtotals
  union
  select * from area_of_range_covered_unassessed
) t
group by analysis_name, analysis_year, region, country
order by analysis_name, analysis_year, region, country;

drop view if exists regional_area_of_range_covered;
create or replace view regional_area_of_range_covered as
select
  analysis_name, analysis_year,
  region,
  surveytype,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from
  area_of_range_covered
group by analysis_name, analysis_year, region, surveytype
order by analysis_name, analysis_year, region, surveytype;

drop view if exists regional_area_of_range_covered_unassessed;
create or replace view regional_area_of_range_covered_unassessed as
select
  analysis_name, analysis_year,
  region,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from
  area_of_range_covered_unassessed
group by analysis_name, analysis_year, region
order by analysis_name, analysis_year, region;

drop view if exists regional_area_of_range_covered_totals;
create or replace view regional_area_of_range_covered_totals as
select
  analysis_name, analysis_year,
  region,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered_totals
group by analysis_name, analysis_year, region
order by analysis_name, analysis_year, region;

drop view if exists continental_area_of_range_covered;
create or replace view continental_area_of_range_covered as
select
  analysis_name, analysis_year,
  surveytype,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from
area_of_range_covered
group by analysis_name, analysis_year, surveytype
order by analysis_name, analysis_year, surveytype;

drop view if exists continental_area_of_range_covered_unassessed;
create or replace view continental_area_of_range_covered_unassessed as
select
  analysis_name, analysis_year,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered_unassessed
group by analysis_name, analysis_year;

drop view if exists continental_area_of_range_covered_totals;
create or replace view continental_area_of_range_covered_totals as
select
  analysis_name, analysis_year,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered_totals
group by analysis_name, analysis_year;

