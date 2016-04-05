---
--- All the queries here are extracted from the (re)creation scripts
--- in static_spatial_queries.sql and static_spatial_queries_add.sql.
--- They must be kept in sync. This version is run for a zero-downtime
--- global update after a major change.
---

begin;

delete from survey_range_intersections;
insert into survey_range_intersections select analysis_name, analysis_year, region, category, l.country, range_quality, ST_Intersection(ST_MakeValid(ST_Force2D(survey_geometry)),ST_MakeValid(ST_Force2D(range_geometry))) from survey_geometry_locator l join country_range c on ST_Intersects(survey_geometry,range_geometry) where range=1;

delete from survey_range_intersection_metrics;
insert into survey_range_intersection_metrics select analysis_name, analysis_year, region, range_quality, category, country, ST_Area(st_intersection::geography,true)/1000000 area_sqkm from survey_range_intersections;

delete from review_range;
insert into review_range select s.* from survey_geometry_locator s where analysis_name='2013_africa_final' and analysis_year='2013' and ((reason_change='NP' and population_estimate=0) or (reason_change='RS' and population_estimate=0) or (reason_change='NG' and population_estimate=0) or (reason_change='DA') or (reason_change='DD'));

delete from add_range;
insert into add_range select s.* from survey_geometry_locator s where analysis_name='2013_africa_final' and analysis_year='2013' and ((reason_change='NP' and population_estimate>0) or (reason_change='NG' and population_estimate>0) or (reason_change='NG' and population_estimate>0));

delete from survey_range_intersections_add;
insert into survey_range_intersections_add
  select analysis_name, analysis_year, region, category, l.country, range_quality,
    ST_Intersection(ST_MakeValid(ST_Force2D(survey_geometry)),ST_MakeValid(ST_Force2D(range_geometry)))
  from survey_geometry_locator_add l
  join country_range c on ST_Intersects(survey_geometry,range_geometry)
  where range=1;

delete from survey_range_intersection_metrics_add;
insert into survey_range_intersection_metrics_add
  select analysis_name, analysis_year, region, range_quality, category, country,
    ST_Area(st_intersection::geography,true)/1000000 area_sqkm
  from survey_range_intersections_add;
