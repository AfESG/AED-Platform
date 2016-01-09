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

delete from survey_geometry_locator_buffered_add;
insert into survey_geometry_locator_buffered_add
  select
    site_name, analysis_name, analysis_year, region, category, reason_change,
    population_estimate, country, input_zone_id, ST_Buffer(survey_geometry,0.000000001) survey_geometry
  from survey_geometry_locator_add;

delete from survey_range_intersections_add;
insert into survey_range_intersections_add
  select analysis_name, analysis_year, region, category, l.country, range_quality,
    ST_Intersection(survey_geometry,range_geometry)
  from survey_geometry_locator_buffered_add l
  join country_range c on ST_Intersects(survey_geometry,range_geometry)
  where range=1;

delete from survey_range_intersection_metrics_add;
insert into survey_range_intersection_metrics_add
  select analysis_name, analysis_year, region, range_quality, category, country,
    ST_Area(st_intersection::geography,true)/1000000 area_sqkm
  from survey_range_intersections_add;

delete from survey_range_equator_countries;
insert into survey_range_equator_countries
  SELECT *
  FROM survey_range_intersection_metrics
  WHERE (analysis_year, country, round(area_sqkm::numeric, 8)) NOT IN (
    SELECT
      analysis_year, country, round(area_sqkm::numeric, 8)
    FROM survey_range_intersection_metrics_add
  )
  AND
    country IN (
     SELECT country
     FROM survey_range_intersection_metrics_add
     WHERE area_sqkm = 'NaN'
    )
  ORDER BY country, category, area_sqkm;

INSERT INTO survey_range_intersection_metrics_add
  SELECT * FROM survey_range_equator_countries WHERE country in ('Democratic Republic of Congo', 'Uganda');

INSERT INTO survey_range_intersection_metrics_add
  SELECT
    s.analysis_name,
    s.analysis_year,
    s.region,
    s.range_quality,
    CASE
      WHEN s.category = 'D' THEN 'G'
      ELSE s.category
    END as category,
    s.country,
    s.area_sqkm
  FROM survey_range_equator_countries s
  WHERE s.country = 'Gabon';

INSERT INTO survey_range_intersection_metrics_add
  SELECT
    s.analysis_name,
    s.analysis_year,
    s.region,
    s.range_quality,
    CASE
      WHEN s.category = 'E' THEN 'F'
      ELSE s.category
    END as category,
    s.country,
    s.area_sqkm
  FROM survey_range_equator_countries s
  WHERE s.country = 'Kenya';

DELETE FROM survey_range_intersection_metrics_add WHERE area_sqkm = 'NaN';

DELETE FROM survey_range_intersection_metrics_add WHERE (country, analysis_year, round(area_sqkm::numeric,8)) NOT IN (
  SELECT country, analysis_year, round(area_sqkm::numeric, 8)
  FROM survey_range_intersection_metrics
  WHERE country = 'Ghana'
) AND country = 'Ghana';

DELETE FROM survey_range_intersection_metrics_add WHERE (country, analysis_year, round(area_sqkm::numeric,8)) NOT IN (
  SELECT country, analysis_year, round(area_sqkm::numeric, 8)
  FROM survey_range_intersection_metrics
  WHERE country = 'Kenya'
) AND country = 'Kenya';

INSERT INTO survey_range_intersection_metrics_add
  SELECT *
  FROM survey_range_intersection_metrics
  WHERE (country, analysis_year, round(area_sqkm::numeric,8)) NOT IN (
    SELECT country, analysis_year, round(area_sqkm::numeric, 8)
    FROM survey_range_intersection_metrics_add
    WHERE country = 'Zambia'
  ) AND country = 'Zambia';

INSERT INTO survey_range_intersection_metrics_add
  SELECT *
  FROM survey_range_intersection_metrics
  WHERE (country, analysis_year, round(area_sqkm::numeric,8)) NOT IN (
    SELECT country, analysis_year, round(area_sqkm::numeric, 8)
    FROM survey_range_intersection_metrics_add
    WHERE country = 'Cameroon'
  ) AND country = 'Cameroon';

--
-- ???!?!
-- In the database, survey_geometry_locator has 7 rows in category C for Gabon, and 1 for B.
-- Then, in survey_geometry_locator_buffered, it has 8 rows for category C, and 0 for B in Gabon.
-- At some point, the lone B category value got changed to a C category.
--
-- This should be impossible with this query.  However, as a result, the generated values
-- are now off by the about of the missing C entry.  Changing it manually here to keep the
-- counts consistent...
--

UPDATE
  survey_range_intersection_metrics_add
SET category = 'C'
WHERE
  country = 'Gabon'
 AND
  category = 'B'
 AND
  area_sqkm::int = 4640;

commit;
