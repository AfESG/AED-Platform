update range_geometries set geometry=ST_MakeValid(geometry) where not ST_IsValid(geometry);

--
-- static geo queries
--

drop table if exists country_range;
create table country_range as select c.cntryname country, g.range, g.rangequali range_quality, ST_MakeValid(ST_Multi(ST_CollectionExtract(ST_Intersection(geometry,geom),3))) range_geometry from range_geometries g, country c where ST_Intersects(geometry,geom);
create index si_country_range on country_range using gist (range_geometry);

drop table if exists country_range_metrics cascade;
create table country_range_metrics as select 'Africa'::text continent, region, country, range, range_quality, SUM(ST_Area(range_geometry::geography,true))/1000000 area_sqkm from country_range join country on cntryname=country where range=1 group by region, country, range, range_quality order by region, country, range, range_quality;

--
-- derived metrics
--

drop view if exists regional_range_metrics;
create or replace view regional_range_metrics as select continent, region, range, range_quality, SUM(area_sqkm) area_sqkm from country_range_metrics group by continent, region, range, range_quality;

drop view if exists continental_range_metrics;
create or replace view continental_range_metrics as select continent, range, range_quality, SUM(area_sqkm) area_sqkm from regional_range_metrics group by continent, range, range_quality;

drop view if exists survey_geometry_locator;
create or replace view survey_geometry_locator as select distinct site_name, analysis_name, analysis_year, region, category, reason_change, population_estimate, country, input_zone_id, geom as survey_geometry from estimate_locator, import_geometries where input_zone=input_zone_id and geom is not null;

--
-- survey range intersections: static, expensive
--

drop table if exists survey_range_intersections;
create table survey_range_intersections as select analysis_name, analysis_year, region, category, l.country, range_quality, ST_Intersection(ST_MakeValid(ST_Force2D(survey_geometry)),ST_MakeValid(ST_Force2D(range_geometry))) from survey_geometry_locator l join country_range c on ST_Intersects(survey_geometry,range_geometry) where range=1;

drop table if exists survey_range_intersection_metrics cascade;
create table survey_range_intersection_metrics as select analysis_name, analysis_year, region, range_quality, category, country, ST_Area(st_intersection::geography,true)/1000000 area_sqkm from survey_range_intersections;

--
-- range study queries
--

drop table if exists review_range;
create table review_range as select s.* from survey_geometry_locator s where analysis_name='2013_africa_final' and analysis_year='2013' and ((reason_change='NP' and population_estimate=0) or (reason_change='RS' and population_estimate=0) or (reason_change='NG' and population_estimate=0) or (reason_change='DA') or (reason_change='DD'));

drop table if exists add_range;
create table add_range as select s.* from survey_geometry_locator s where analysis_name='2013_africa_final' and analysis_year='2013' and ((reason_change='NP' and population_estimate>0) or (reason_change='NG' and population_estimate>0) or (reason_change='NG' and population_estimate>0));

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
  ((CASE WHEN k.known IS NULL THEN 0 ELSE k.known END)
   +
   (CASE WHEN p.possible IS NULL THEN 0 ELSE p.possible END)) total
from
country c
left join
(select
  m.region,
  m.country,
  sum(area_sqkm) known
from country_range_metrics m
where range=1 and range_quality='Known'
group by m.region, m.country) k
on k.country = c.cntryname
left join
(select
  m.region,
  m.country,
  sum(area_sqkm) possible
from country_range_metrics m
where range=1 and range_quality='Possible'
group by m.region, m.country) p
on p.country = c.cntryname
order by region, country;

drop view if exists area_of_range_covered cascade;
create or replace view area_of_range_covered as
select
  k.region,
  k.country,
  k.surveytype,
  k.known,
  p.possible,
  ((CASE WHEN k.known IS NULL THEN 0 ELSE k.known END)
   +
   (CASE WHEN p.possible IS NULL THEN 0 ELSE p.possible END)) total
from
(select
  m.country,
  m.region,
  t.surveytype,
  sum(area_sqkm) known
from survey_range_intersection_metrics m
join surveytypes t on t.category = m.category
where m.analysis_name='2013_africa_final' and m.analysis_year=2013 and range_quality='Known'
group by m.country, m.region, t.surveytype) k
left join
(select
  m.country,
  m.region,
  t.surveytype,
  sum(area_sqkm) possible
from survey_range_intersection_metrics m
join surveytypes t on t.category = m.category
where m.analysis_name='2013_africa_final' and m.analysis_year=2013 and range_quality='Possible'
group by m.country, m.region, t.surveytype) p
on k.country = p.country and k.surveytype = p.surveytype
order by region, country, surveytype;

drop view if exists area_of_range_covered_subtotals cascade;
create or replace view area_of_range_covered_subtotals as
select
  region,
  country,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered
group by region, country
order by region, country;

drop view if exists area_of_range_covered_unassessed cascade;
create or replace view area_of_range_covered_unassessed as
select
  x.region,
  x.country,
  x.known - n.known known,
  x.possible - n.possible possible,
  x.total - n.total total
from area_of_range_extant x join
area_of_range_covered_subtotals n on x.country = n.country
order by x.region, x.country;

drop view if exists area_of_range_covered_totals cascade;
create view area_of_range_covered_totals as
select
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
group by region, country
order by region, country;

drop view if exists regional_area_of_range_covered;
create or replace view regional_area_of_range_covered as
select
  region,
  surveytype,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from
area_of_range_covered
group by region, surveytype
order by region, surveytype;

drop view if exists regional_area_of_range_covered_unassessed;
create or replace view regional_area_of_range_covered_unassessed as
select
  region,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered_unassessed
group by region
order by region;

drop view if exists regional_area_of_range_covered_totals;
create or replace view regional_area_of_range_covered_totals as
select
  region,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered_totals
group by region
order by region;

drop view if exists continental_area_of_range_covered;
create or replace view continental_area_of_range_covered as
select
  surveytype,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from
area_of_range_covered
group by surveytype
order by surveytype;

drop view if exists continental_area_of_range_covered_unassessed;
create or replace view continental_area_of_range_covered_unassessed as
select
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered_unassessed;

drop view if exists continental_area_of_range_covered_totals;
create or replace view continental_area_of_range_covered_totals as
select
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered_totals;

--
-- Regional and continental range tables
--

drop view if exists regional_range_table;
create or replace view regional_range_table as
select
  r.region,
  m.country,
  sum(m.area_sqkm) range_area,
  sum(r.area_sqkm) regional_range,
  (sum(m.area_sqkm)/sum(r.area_sqkm))*100 percent_regional_range,
  sum(sm.area_sqkm) range_assessed,
  (sum(sm.area_sqkm)/sum(m.area_sqkm))*100 percent_range_assessed
from
  (select country, sum(area_sqkm) area_sqkm from country_range_metrics group by country) m
  join country c on c.cntryname = m.country
  join (select region, sum(area_sqkm) area_sqkm from regional_range_metrics group by region) r on r.region = c.region
  join (select country, sum(area_sqkm) area_sqkm from survey_range_intersection_metrics where analysis_name='2013_africa_final' and analysis_year=2013 group by country) sm on sm.country = m.country
group by r.region, m.country
order by r.region, m.country;

drop view if exists regional_range_totals;
create or replace view regional_range_totals as
select
  region,
  sum(range_area) range_area,
  regional_range regional_range,
  sum(percent_regional_range) percent_regional_range,
  sum(range_assessed) range_assessed,
  (sum(range_assessed)/sum(range_area))*100 percent_range_assessed
from
regional_range_table
group by region, regional_range
order by region;

drop view if exists continental_range_table;
create or replace view continental_range_table as
select
  'Africa'::text continent,
  r.region,
  sum(m.area_sqkm) range_area,
  sum(n.area_sqkm) continental_range,
  (sum(m.area_sqkm)/sum(n.area_sqkm))*100 percent_continental_range,
  sum(sm.area_sqkm) range_assessed,
  (sum(sm.area_sqkm)/sum(m.area_sqkm))*100 percent_range_assessed
from
  (select region, sum(area_sqkm) area_sqkm from regional_range_metrics group by region) m
  join region r on r.region = m.region
  join (select 'Africa'::text continent, sum(area_sqkm) area_sqkm from continental_range_metrics) n on n.continent = r.continent
  join (select region, sum(area_sqkm) area_sqkm from survey_range_intersection_metrics where analysis_name='2013_africa_final' and analysis_year=2013 group by region) sm on sm.region = m.region
group by n.continent, r.region
order by n.continent, r.region;

drop view if exists continental_range_totals;
create or replace view continental_range_totals as
select
  continent,
  sum(range_area) range_area,
  sum(continental_range) continental_range,
  sum(percent_continental_range) percent_continental_range,
  sum(range_assessed) range_assessed,
  (sum(range_assessed)/sum(range_area))*100 percent_range_assessed
from
continental_range_table
group by continent
order by continent;
