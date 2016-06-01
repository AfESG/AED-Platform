update range_geometries set geometry=ST_MakeValid(geometry) where not ST_IsValid(geometry);

--
-- static geo queries
--

drop table if exists country_range cascade;
create table country_range as 
select 
  c.cntryname country, g.range, g.rangequali range_quality, 
  ST_MakeValid(ST_Multi(ST_CollectionExtract(ST_Intersection(geometry,geom),3))) range_geometry 
from range_geometries g, country c where ST_Intersects(geometry,geom);
create index si_country_range on country_range using gist (range_geometry);

drop table if exists country_range_metrics cascade;
create table country_range_metrics as
select
  'Africa'::text continent, region, country, range, range_quality, 
  SUM(ST_Area(range_geometry::geography,true))/1000000 area_sqkm 
from country_range 
join country on cntryname=country 
where range=1 
group by region, country, range, range_quality 
order by region, country, range, range_quality;

--
-- derived metrics
--

drop view if exists regional_range_metrics;
create or replace view regional_range_metrics as 
select 
  continent, region, range, range_quality, 
  SUM(area_sqkm) area_sqkm
from country_range_metrics 
group by continent, region, range, range_quality;

drop view if exists continental_range_metrics;
create or replace view continental_range_metrics as 
select
  continent, range, range_quality, SUM(area_sqkm) area_sqkm 
from regional_range_metrics
group by continent, range, range_quality;


--
-- Regional and continental range tables
--

drop view if exists regional_range_table;
create or replace view regional_range_table as
select
  sm.analysis_name,
  sm.analysis_year,
  r.region,
  m.country,
  sum(m.area_sqkm) range_area,
  sum(r.area_sqkm) regional_range,
  (sum(m.area_sqkm)/sum(r.area_sqkm))*100 percent_regional_range,
  sum(sm.area_sqkm) range_assessed,
  (sum(sm.area_sqkm)/sum(m.area_sqkm))*100 percent_range_assessed
from (
  select country, sum(area_sqkm) area_sqkm 
  from country_range_metrics group by country
) m
join country c on c.cntryname = m.country
join (
  select region, sum(area_sqkm) area_sqkm 
  from regional_range_metrics 
  group by region
) r on r.region = c.region
join (
  select analysis_name, analysis_year, country, sum(area_sqkm) area_sqkm 
  from survey_range_intersection_metrics 
  group by analysis_name, analysis_year, country
) sm on sm.country = m.country
group by sm.analysis_name, sm.analysis_year, r.region, m.country
order by sm.analysis_name, sm.analysis_year, r.region, m.country;

drop view if exists regional_range_totals;
create or replace view regional_range_totals as
select
  analysis_name,
  analysis_year,
  region,
  sum(range_area) range_area,
  regional_range regional_range,
  sum(percent_regional_range) percent_regional_range,
  sum(range_assessed) range_assessed,
  (sum(range_assessed)/sum(range_area))*100 percent_range_assessed
from
regional_range_table
group by analysis_name, analysis_year, region, regional_range
order by analysis_name, analysis_year, region;

drop view if exists continental_range_table;
create or replace view continental_range_table as
select
  sm.analysis_name,
  sm.analysis_year,
  'Africa'::text continent,
  r.region,
  sum(m.area_sqkm) range_area,
  sum(n.area_sqkm) continental_range,
  (sum(m.area_sqkm)/sum(n.area_sqkm))*100 percent_continental_range,
  sum(sm.area_sqkm) range_assessed,
  (sum(sm.area_sqkm)/sum(m.area_sqkm))*100 percent_range_assessed
from (
  select region, sum(area_sqkm) area_sqkm 
  from regional_range_metrics group by region) m
  join region r on r.region = m.region
  join (
    select 'Africa'::text continent, sum(area_sqkm) area_sqkm 
    from continental_range_metrics
  ) n on n.continent = r.continent
  join (
    select analysis_name, analysis_year, region, sum(area_sqkm) area_sqkm 
    from survey_range_intersection_metrics 
    group by analysis_name, analysis_year, region
  ) sm on sm.region = m.region
group by sm.analysis_name, sm.analysis_year, n.continent, r.region
order by sm.analysis_name, sm.analysis_year, n.continent, r.region;

drop view if exists continental_range_totals;
create or replace view continental_range_totals as
select
  analysis_name,
  analysis_year,
  continent,
  sum(range_area) range_area,
  sum(continental_range) continental_range,
  sum(percent_continental_range) percent_continental_range,
  sum(range_assessed) range_assessed,
  (sum(range_assessed)/sum(range_area))*100 percent_range_assessed
from
continental_range_table
group by analysis_name, analysis_year, continent
order by analysis_name, analysis_year, continent;

