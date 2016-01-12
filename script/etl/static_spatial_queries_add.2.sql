drop view if exists survey_geometry_locator_add;
drop view if exists estimate_locator_add cascade;
CREATE VIEW estimate_locator_add as
  SELECT e.estimate_type,
    e.input_zone_id,
    e.population_submission_id,
    e.site_name,
    e.stratum_name,
    e.stratum_area,
    e.completion_year,
    e.analysis_name,
    e.analysis_year,
    e.age,
    e.replacement_name,
    e.reason_change,
    e.citation,
    e.short_citation,
    e.population_estimate,
    e.population_variance,
    e.population_standard_error,
    e.population_confidence_interval,
    e.population_lower_confidence_limit,
    e.population_upper_confidence_limit,
    e.quality_level,
    e.actually_seen,
    e.lcl95,
    e.category,
    countries.name AS country,
    regions.name AS region,
    continents.name AS continent
   FROM estimate_factors_analyses_categorized_for_add e
     JOIN population_submissions ON e.population_submission_id = population_submissions.id
     JOIN submissions ON population_submissions.submission_id = submissions.id
     JOIN countries ON submissions.country_id = countries.id
     JOIN regions ON countries.region_id = regions.id
     JOIN continents ON regions.continent_id = continents.id;

create or replace view survey_geometry_locator_add as 
  select distinct site_name, analysis_name, analysis_year, region, category, reason_change, 
    population_estimate, country, input_zone_id, geom as survey_geometry 
  from estimate_locator_add, import_geometries 
  where input_zone=input_zone_id and geom is not null;

---
--- survey range intersections: static, expensive
---

drop table if exists survey_geometry_locator_buffered_add cascade;

drop table if exists survey_range_intersections_add cascade;
create table survey_range_intersections_add as 
  select analysis_name, analysis_year, region, category, l.country, range_quality, 
    ST_Intersection(ST_MakeValid(ST_Force2D(survey_geometry)),ST_MakeValid(ST_Force2D(range_geometry)))
  from survey_geometry_locator_add l 
  join country_range c on ST_Intersects(survey_geometry,range_geometry) 
  where range=1;

drop table if exists survey_range_intersection_metrics_add cascade;
create table survey_range_intersection_metrics_add as 
  select analysis_name, analysis_year, region, range_quality, category, country,
    ST_Area(st_intersection::geography,true)/1000000 area_sqkm 
  from survey_range_intersections_add;

-- DROP TABLE IF EXISTS survey_range_equator_countries cascade;
-- CREATE TABLE survey_range_equator_countries AS 
  -- SELECT * 
  -- FROM survey_range_intersection_metrics
  -- WHERE (analysis_year, country, round(area_sqkm::numeric, 8)) NOT IN (
    -- SELECT
      -- analysis_year, country, round(area_sqkm::numeric, 8)
    -- FROM survey_range_intersection_metrics_add
  -- )
  -- AND
    -- country IN (
     -- SELECT country
     -- FROM survey_range_intersection_metrics_add
     -- WHERE area_sqkm = 'NaN'
    -- )
  -- ORDER BY country, category, area_sqkm;


-- INSERT INTO survey_range_intersection_metrics_add
  -- SELECT * FROM survey_range_equator_countries WHERE country in ('Democratic Republic of Congo', 'Uganda');

-- INSERT INTO survey_range_intersection_metrics_add
  -- SELECT
    -- s.analysis_name,
    -- s.analysis_year,
    -- s.region,
    -- s.range_quality,
    -- CASE
      -- WHEN s.category = 'D' THEN 'G'
      -- ELSE s.category
    -- END as category,
    -- s.country,
    -- s.area_sqkm
  -- FROM survey_range_equator_countries s
  -- WHERE s.country = 'Gabon';

-- INSERT INTO survey_range_intersection_metrics_add
  -- SELECT
    -- s.analysis_name,
    -- s.analysis_year,
    -- s.region,
    -- s.range_quality,
    -- CASE
      -- WHEN s.category = 'E' THEN 'F'
      -- ELSE s.category
    -- END as category,
    -- s.country,
    -- s.area_sqkm
  -- FROM survey_range_equator_countries s
  -- WHERE s.country = 'Kenya';

-- DELETE FROM survey_range_intersection_metrics_add WHERE area_sqkm = 'NaN';

-- DELETE FROM survey_range_intersection_metrics_add WHERE (country, analysis_year, round(area_sqkm::numeric,8)) NOT IN (
  -- SELECT country, analysis_year, round(area_sqkm::numeric, 8) 
  -- FROM survey_range_intersection_metrics
  -- WHERE country = 'Ghana'
-- ) AND country = 'Ghana';

-- DELETE FROM survey_range_intersection_metrics_add WHERE (country, analysis_year, round(area_sqkm::numeric,8)) NOT IN (
  -- SELECT country, analysis_year, round(area_sqkm::numeric, 8) 
  -- FROM survey_range_intersection_metrics
  -- WHERE country = 'Kenya'
-- ) AND country = 'Kenya';

-- INSERT INTO survey_range_intersection_metrics_add
  -- SELECT * 
  -- FROM survey_range_intersection_metrics
  -- WHERE (country, analysis_year, round(area_sqkm::numeric,8)) NOT IN (
    -- SELECT country, analysis_year, round(area_sqkm::numeric, 8) 
    -- FROM survey_range_intersection_metrics_add
    -- WHERE country = 'Zambia'
  -- ) AND country = 'Zambia';
 
-- INSERT INTO survey_range_intersection_metrics_add
  -- SELECT * 
  -- FROM survey_range_intersection_metrics
  -- WHERE (country, analysis_year, round(area_sqkm::numeric,8)) NOT IN (
    -- SELECT country, analysis_year, round(area_sqkm::numeric, 8) 
    -- FROM survey_range_intersection_metrics_add
    -- WHERE country = 'Cameroon'
  -- ) AND country = 'Cameroon';

--
-- UPDATE: Rob fixed this
--
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

-- UPDATE survey_range_intersection_metrics_add SET category = 'C'
-- WHERE country = 'Gabon' AND category = 'B' AND area_sqkm::int = 4640;


