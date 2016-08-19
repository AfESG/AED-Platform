update range_geometries set geometry=ST_MakeValid(geometry) where not ST_IsValid(geometry);

drop table if exists country_range cascade;
create table base_country_range as
select
  c.cntryname country, g.range, g.rangequali range_quality,
  ST_MakeValid(ST_Multi(ST_CollectionExtract(ST_Intersection(geometry,geom),3))) range_geometry
from range_geometries g, country c where ST_Intersects(geometry,geom);

create table country_range as
select
  country, range, range_quality,
  ST_MakeValid(ST_Multi(ST_CollectionExtract(ST_MemUnion(range_geometry),3))) range_geometry
from base_country_range
group by country, range, range_quality;
create index si_country_range on country_range using gist (range_geometry);

DROP VIEW IF EXISTS estimate_locator_with_geometry_add CASCADE;
CREATE VIEW estimate_locator_with_geometry_add AS
 SELECT g.id,
    l.estimate_type,
    l.input_zone_id,
    l.population_submission_id,
    l.site_name,
    l.stratum_name,
    l.stratum_area,
    l.completion_year,
    l.analysis_name,
    l.analysis_year,
    l.age,
    l.replacement_name,
    l.reason_change,
    l.citation,
    l.short_citation,
    l.best_estimate as population_estimate,
    l.best_population_variance as population_variance,
    l.population_standard_error,
    l.population_confidence_interval,
    l.population_lower_confidence_limit,
    l.population_upper_confidence_limit,
    l.quality_level,
    l.actually_seen,
    l.lcl95,
    l.category,
    l.country,
    l.region,
    l.continent,
    g.geom
   FROM survey_geometries g
     JOIN estimate_factors f ON f.survey_geometry_id = g.id
     JOIN estimate_factors_analyses_categorized_for_add l ON l.input_zone_id = f.input_zone_id;

CREATE VIEW estimate_locator_areas_add AS
 SELECT e.input_zone_id,
    e.analysis_name,
    e.analysis_year,
    sum(st_area(e.geom::geography, true)) / 1000000::double precision AS area_sqkm
   FROM estimate_locator_with_geometry_add e
  GROUP BY e.input_zone_id, e.analysis_name, e.analysis_year
  ORDER BY e.input_zone_id, e.analysis_name, e.analysis_year;

drop table if exists survey_range_intersections cascade;
drop table if exists survey_range_intersections_add cascade;

create table survey_range_intersections as
  select analysis_name, analysis_year, region, category, reason_change, l.country, range_quality,
    ST_Intersection(ST_MakeValid(ST_Force2D(ST_SetSRID(geom,4326))),ST_MakeValid(ST_Force2D(ST_SetSRID(range_geometry,4326))))
  from estimate_locator_with_geometry l
  join country_range c on ST_Intersects(ST_SetSRID(geom,4326),ST_SetSRID(range_geometry,4326))
  where range=1;

create view survey_range_intersections_add as
  select analysis_name, analysis_year, region, category, reason_change, l.country, range_quality,
    ST_Intersection(ST_MakeValid(ST_Force2D(ST_SetSRID(geom,4326))),ST_MakeValid(ST_Force2D(ST_SetSRID(range_geometry,4326))))
  from estimate_locator_with_geometry_add l
  join country_range c on ST_Intersects(ST_SetSRID(geom,4326),ST_SetSRID(range_geometry,4326))
  where range=1;

drop table if exists survey_range_intersection_metrics cascade;
create table survey_range_intersection_metrics as
select analysis_name, analysis_year, region, range_quality, category, reason_change, country,
    ST_Area(st_intersection::geography,true)/1000000 area_sqkm
  from survey_range_intersections;

drop table if exists survey_range_intersection_metrics_add cascade;
create table survey_range_intersection_metrics_add as
select analysis_name, analysis_year, region, range_quality, category, reason_change, country,
    ST_Area(st_intersection::geography,true)/1000000 area_sqkm
  from survey_range_intersections_add;
