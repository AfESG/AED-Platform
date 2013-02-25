delete from survey_geometries;
insert into survey_geometries (id,geometry) select distinct survey_geo::integer, geom from peter_step_3 where survey_geo::integer != 0;
select setval('survey_geometry_id_seq',max(id)+1) from survey_geometries;
insert into survey_geometries select nextval('survey_geometry_id_seq'), geom from (select distinct geom from peter_step_3 where survey_geo::integer = 0 and geom is not null) s;
update peter_step_3 set survey_geo=survey_geometries.id from survey_geometries where ST_Text(geom) = ST_Text(geometry) and survey_geo::integer =0;

create or replace view import_geometries as select unnest(regexp_split_to_array(input_zone::text, ','::text)) as input_zone, survey_geo::integer, geom from peter_step_3;
update survey_ground_total_count_strata s set survey_geometry_id=survey_geo from (select substr(input_zone,3)::integer id, survey_geo from import_geometries where input_zone like 'GT%' and survey_geo is not null) i where s.id=i.id;
update survey_dung_count_line_transect_strata s set survey_geometry_id=survey_geo from (select substr(input_zone,3)::integer id, survey_geo from import_geometries where input_zone like 'DC%' and survey_geo is not null) i where s.id=i.id;
update survey_aerial_total_count_strata s set survey_geometry_id=survey_geo from (select substr(input_zone,3)::integer id, survey_geo from import_geometries where input_zone like 'AT%' and survey_geo is not null) i where s.id=i.id;
update survey_aerial_sample_count_strata s set survey_geometry_id=survey_geo from (select substr(input_zone,3)::integer id, survey_geo from import_geometries where input_zone like 'AS%' and survey_geo is not null) i where s.id=i.id;
update survey_ground_sample_count_strata s set survey_geometry_id=survey_geo from (select substr(input_zone,3)::integer id, survey_geo from import_geometries where input_zone like 'GS%' and survey_geo is not null) i where s.id=i.id;
update survey_faecal_dna_strata s set survey_geometry_id=survey_geo from (select substr(input_zone,3)::integer id, survey_geo from import_geometries where input_zone like 'GD%' and survey_geo is not null) i where s.id=i.id;
update survey_individual_registrations s set survey_geometry_id=survey_geo from (select substr(input_zone,3)::integer id, survey_geo from import_geometries where input_zone like 'IR%' and survey_geo is not null) i where s.id=i.id;
update survey_others s set survey_geometry_id=survey_geo from (select substr(input_zone,2)::integer id, survey_geo from import_geometries where input_zone like 'O%' and survey_geo is not null) i where s.id=i.id;

###
###
###

drop table continental_simplified_range;
create table continental_simplified_range as select range, rangequali range_quality, ST_Union(geometry) range_geometry from range_geometries group by range, rangequali;

drop table continental_oversimplified_range;
create table continental_oversimplified_range as select ST_Union(range_geometry) range_geometry from continental_simplified_range where range=1;

drop table continental_range_metrics;
create table continental_range_metrics as select range, range_quality, SUM(ST_Area(range_geometry::geography,true))/1000000 area_sqkm from continental_simplified_range where range=1 group by range, range_quality;

drop table regional_simplified_range;
create table regional_simplified_range as select region, range, range_quality, ST_Intersection(ST_SetSRID(range_geometry,4326),ST_SetSRID(geom,4326)) range_geometry from continental_simplified_range, region;

drop table regional_range_metrics;
create table regional_range_metrics as select region, range, range_quality, SUM(ST_Area(range_geometry::geography,true))/1000000 area_sqkm from regional_simplified_range where range=1 group by region, range, range_quality;

drop table country_simplified_range;
create table country_simplified_range as select cntryname country, range, range_quality, ST_Intersection(ST_SetSRID(range_geometry,4326),ST_SetSRID(geom,4326)) range_geometry from continental_simplified_range, country;

drop table country_range_metrics;
create table country_range_metrics as select country, range, range_quality, SUM(ST_Area(range_geometry::geography,true))/1000000 area_sqkm from country_simplified_range where range=1 group by country, range, range_quality;

drop table survey_geometry_locator;
create table survey_geometry_locator as select site_name, analysis_name, analysis_year, region, category, country, input_zone_id, geom survey_geometry from estimate_locator, import_geometries where input_zone=input_zone_id and geom is not null;

drop table survey_range_intersections;
create table survey_range_intersections as select analysis_name, analysis_year, region, category, country, range_quality, ST_Intersection(ST_Union(ST_SetSRID(ST_Buffer(survey_geometry,0.0000001,'quad_segs=2, endcap=flat'),4326)),ST_SetSRID(range_geometry,4326)) from survey_geometry_locator, continental_simplified_range where range=1 group by analysis_name, analysis_year, region, category, country, range_quality, range_geometry;

drop table survey_range_intersection_metrics;
create table survey_range_intersection_metrics as select analysis_name, analysis_year, region, range_quality, category, country, ST_Area(st_intersection::geography,true)/1000000 area_sqkm from survey_range_intersections;

drop table area_of_range_extant;
create table area_of_range_extant as
select
  k.country,
  k.known,
  p.possible,
  (k.known+p.possible) total
from
(select
  m.country,
  sum(area_sqkm) known
from country_range_metrics m
where range=1 and range_quality='Known'
group by m.country) k
join
(select
  m.country,
  sum(area_sqkm) possible
from country_range_metrics m
where range=1 and range_quality='Possible'
group by m.country) p
on k.country = p.country
order by country;

drop table area_of_range_covered;
create table area_of_range_covered as
select
  k.country,
  k.surveytype,
  k.known,
  p.possible,
  (k.known+p.possible) total
from
(select
  m.country,
  t.surveytype,
  sum(area_sqkm) known
from survey_range_intersection_metrics m
join surveytypes t on t.category = m.category
where m.analysis_name='2013_africa' and m.analysis_year=2012 and range_quality='Known'
group by m.country, t.surveytype) k
join
(select
  m.country,
  t.surveytype,
  sum(area_sqkm) possible
from survey_range_intersection_metrics m
join surveytypes t on t.category = m.category
where m.analysis_name='2013_africa' and m.analysis_year=2012 and range_quality='Possible'
group by m.country, t.surveytype) p
on k.country = p.country and k.surveytype = p.surveytype
order by country, surveytype;

drop table area_of_range_covered_subtotals;
create table area_of_range_covered_subtotals as
select
  country,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from area_of_range_covered
group by country
order by country;

drop table area_of_range_covered_unassessed;
create table area_of_range_covered_unassessed as
select
  x.country,
  x.known - n.known known,
  x.possible - n.possible possible,
  x.total - n.total total
from area_of_range_extant x join
area_of_range_covered_subtotals n on x.country = n.country
order by x.country;

drop table area_of_range_covered_totals;
create table area_of_range_covered_totals as
select
  country,
  sum(known) known,
  sum(possible) possible,
  sum(total) total
from (
  select * from area_of_range_covered_subtotals
  union
  select * from area_of_range_covered_unassessed
) t
group by country
order by country;
drop table regional_range_table;
create table regional_range_table as
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
  join (select country, sum(area_sqkm) area_sqkm from survey_range_intersection_metrics where analysis_name='2013_africa' and analysis_year=2012 group by country) sm on sm.country = m.country
group by r.region, m.country
order by r.region, m.country;

drop table regional_range_totals;
create table regional_range_totals as
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

drop table continental_range_table;
create table continental_range_table as
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
  join (select region, sum(area_sqkm) area_sqkm from survey_range_intersection_metrics where analysis_name='2013_africa' and analysis_year=2012 group by region) sm on sm.region = m.region
group by n.continent, r.region
order by n.continent, r.region;

drop table continental_range_totals;
create table continental_range_totals as
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

